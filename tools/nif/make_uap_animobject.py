"""Build the in-hand mesh Ultimate Animated Potions NG shows while a BF potion is drunk.

UAP NG swaps the drink animation's AnimObject (Skyrim.esm AnimObjectDrinkPotion) to
meshes\\AnimObjects\\<file name of the potion's model> when that file exists LOOSE,
else back to the vanilla AnimObjectDrinkPotion.nif, which hangs off the hand bone at
an offset and leaves the hand looking empty in UAP's animation. UAP's own meshes are
the potion's world mesh, geometry untouched, minus collision, BSX and the inventory
marker, plus Prn = AnimObjectR on the root. This makes the same from a BF potion.

usage: make_uap_animobject.py <potion.nif> <out.nif>
Skyrim SE nifs only; the input may hold BSTriShapes with their shader, texture set
and alpha blocks, and nothing else beyond the dropped blocks.
"""
import struct
import sys

DROP = {"BSInvMarker", "BSXFlags", "bhkConvexVerticesShape", "bhkRigidBody", "bhkCollisionObject"}
KEEP = {"BSFadeNode", "BSTriShape", "BSLightingShaderProperty", "BSShaderTextureSet", "NiAlphaProperty"}


def sized(d, pos):
    n, = struct.unpack_from("<I", d, pos)
    return d[pos + 4:pos + 4 + n].decode("latin1"), pos + 4 + n


def read(data):
    d = bytes(data)
    pos = d.index(b"\n") + 1 + 4 + 1 + 4
    nblocks, bsver = struct.unpack_from("<II", d, pos)
    if bsver != 100:
        raise SystemExit("not a Skyrim SE nif (BS version %d)" % bsver)
    nblocks_at = pos
    pos += 8
    for _ in range(3):  # author, process script, export script
        pos += 1 + d[pos]
    prefix = bytearray(d[:pos])
    ntypes, = struct.unpack_from("<H", d, pos); pos += 2
    types = []
    for _ in range(ntypes):
        s, pos = sized(d, pos); types.append(s)
    tidx = struct.unpack_from("<%dH" % nblocks, d, pos); pos += 2 * nblocks
    sizes = struct.unpack_from("<%dI" % nblocks, d, pos); pos += 4 * nblocks
    nstrings, _ = struct.unpack_from("<II", d, pos); pos += 8
    strings = []
    for _ in range(nstrings):
        s, pos = sized(d, pos); strings.append(s)
    ngroups, = struct.unpack_from("<I", d, pos)
    if ngroups:
        raise SystemExit("block groups not handled")
    pos += 4
    blocks = []
    for size in sizes:
        blocks.append((types[tidx[len(blocks)] & 0x7FFF], bytearray(d[pos:pos + size]))); pos += size
    nroots, root = struct.unpack_from("<Ii", d, pos)
    if nroots != 1 or root != 0 or len(d) != pos + 8:
        raise SystemExit("expected one root, block 0")
    return prefix, nblocks_at, blocks, strings


def write(prefix, nblocks_at, blocks, strings):
    out = bytearray(prefix)
    struct.pack_into("<I", out, nblocks_at, len(blocks))
    types = list(dict.fromkeys(kind for kind, _ in blocks))
    out += struct.pack("<H", len(types))
    for t in types:
        e = t.encode("latin1"); out += struct.pack("<I", len(e)) + e
    out += struct.pack("<%dH" % len(blocks), *[types.index(kind) for kind, _ in blocks])
    out += struct.pack("<%dI" % len(blocks), *[len(b) for _, b in blocks])
    out += struct.pack("<II", len(strings), max(len(s) for s in strings))
    for s in strings:
        e = s.encode("latin1"); out += struct.pack("<I", len(e)) + e
    out += struct.pack("<I", 0)  # block groups
    for _, b in blocks:
        out += b
    return bytes(out + struct.pack("<Ii", 1, 0))


def build(src):
    prefix, nblocks_at, blocks, strings = read(src)
    if blocks[0][0] != "BSFadeNode":
        raise SystemExit("root is %s, not BSFadeNode" % blocks[0][0])
    for i, (kind, _) in enumerate(blocks):
        if kind not in DROP | KEEP:
            raise SystemExit("block %d is %s, not handled" % (i, kind))

    # New order: root, the Prn extra data, then every kept block in its old order.
    old = [i for i, (kind, _) in enumerate(blocks) if kind in KEEP]
    remap = {o: n + (1 if n else 0) for n, o in enumerate(old)}
    remap[-1] = -1

    def ref(r):
        if r not in remap:
            raise SystemExit("a kept block points at dropped block %d" % r)
        return remap[r]

    used = []

    def string(idx):
        if idx < 0:
            return -1
        if strings[idx] not in used:
            used.append(strings[idx])
        return used.index(strings[idx])

    def plain_net(b, at=0):
        """NiObjectNET with no extra data and no controller: remap the name"""
        name, nextra = struct.unpack_from("<iI", b, at)
        ctrl, = struct.unpack_from("<i", b, at + 8 + 4 * nextra)
        if nextra or ctrl != -1:
            raise SystemExit("extra data or a controller on a kept block, not handled")
        struct.pack_into("<i", b, at, string(name))

    # Root: one extra data (Prn), no collision, children remapped.
    rb = blocks[0][1]
    name, nextra = struct.unpack_from("<iI", rb, 0)
    p = 8 + 4 * nextra
    ctrl, = struct.unpack_from("<i", rb, p); p += 4
    av = rb[p:p + 56]; p += 56  # flags + translation + rotation + scale
    p += 4  # collision ref, dropped
    nkids, = struct.unpack_from("<I", rb, p); p += 4
    kids = struct.unpack_from("<%di" % nkids, rb, p); p += 4 * nkids
    neff, = struct.unpack_from("<I", rb, p)
    if ctrl != -1 or neff or p + 4 != len(rb):
        raise SystemExit("root has a controller or effects, not handled")
    root = bytearray(struct.pack("<iIii", string(name), 1, 1, -1)) + av + struct.pack("<i", -1)
    root += struct.pack("<I", nkids) + struct.pack("<%di" % nkids, *[ref(k) for k in kids]) + struct.pack("<I", 0)
    out = [("BSFadeNode", root), ("NiStringExtraData", bytearray(8))]  # filled in by main()
    for o in old[1:]:
        kind, b = blocks[o][0], bytearray(blocks[o][1])
        if kind == "BSTriShape":
            plain_net(b)
            p = 12 + 56
            coll, = struct.unpack_from("<i", b, p)
            if coll != -1:
                raise SystemExit("a shape carries its own collision, not handled")
            p += 4 + 16  # collision, bounding sphere
            skin, shader, alpha = struct.unpack_from("<3i", b, p)
            if skin != -1:
                raise SystemExit("skinned shape, not handled")
            struct.pack_into("<3i", b, p, -1, ref(shader), ref(alpha))
        elif kind == "BSLightingShaderProperty":
            plain_net(b, 4)
            p = 4 + 12 + 8 + 16  # shader type, NiObjectNET, flags, uv offset + scale
            texset, = struct.unpack_from("<i", b, p)
            struct.pack_into("<i", b, p, ref(texset))
        elif kind == "NiAlphaProperty":
            plain_net(b)
        elif kind == "BSFadeNode":
            raise SystemExit("a BSFadeNode below the root, not handled")
        out.append((kind, b))
    return prefix, nblocks_at, out, used


def main():
    src, dst = sys.argv[1], sys.argv[2]
    prefix, nblocks_at, blocks, used = build(open(src, "rb").read())
    # Prn's name and value strings go last, after every name the kept blocks use.
    for s in ("Prn", "AnimObjectR"):
        if s not in used:
            used.append(s)
    struct.pack_into("<ii", blocks[1][1], 0, used.index("Prn"), used.index("AnimObjectR"))
    open(dst, "wb").write(write(prefix, nblocks_at, blocks, used))


if __name__ == "__main__":
    main()
