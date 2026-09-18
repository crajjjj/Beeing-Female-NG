#!/usr/bin/env python3
"""Package the Beeing Female NG integration kit -> dist/Release/BeeingFemaleNG-API-<version>+.zip

The kit is what another mod needs to integrate with BF NG, and nothing else:
the docs, a compile-verified example consumer, the add-on INI templates, and
the Papyrus sources a *script* add-on must compile against.

Versions in VERSIONS.txt are read straight out of the version INI that the
game itself reads at runtime, so they cannot drift from what BF reports.

Usage:  python tools/pack-api-kit.py
"""
import os
import re
import shutil
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "dist", "Core", "source", "scripts")
ADDON = os.path.join(ROOT, "dist", "Core", "BeeingFemale", "AddOn")
KIT = os.path.join(ROOT, "tools", "api-kit")
RELEASE = os.path.join(ROOT, "dist", "Release")

# The compile closure for a script add-on: every FW* script reachable from the
# FWAddOn_* base classes. Computed, not hand-listed, so it cannot go stale.
SEEDS = ["FWAddOn_Misc", "FWAddOn_Race", "FWAddOn_CycleMagicEffect", "FWVersion"]


def read_versions():
    ini = os.path.join(ROOT, "dist", "Core", "BeeingFemale", "Version",
                       "0 Beeing Female version.ini")
    with open(ini, encoding="ascii") as fh:
        text = fh.read()
    out = {}
    for key in ("BF_Version", "BF_VersionInt", "BF_VersionMCM",
                "BF_VersionNative", "BF_VersionAnimation"):
        m = re.search(r"^%s\s*=\s*(\S+)\s*$" % key, text, re.M)
        if not m:
            raise SystemExit("pack-api-kit: %s missing from %s" % (key, ini))
        out[key] = m.group(1)
    return out


def script_closure():
    avail = {f[:-4].lower(): f[:-4] for f in os.listdir(SRC) if f.endswith(".psc")}

    def deps(name):
        path = os.path.join(SRC, avail[name] + ".psc")
        with open(path, encoding="utf-8-sig", errors="replace") as fh:
            text = fh.read()
        text = re.sub(r";/.*?/;", "", text, flags=re.S)   # block comments
        text = re.sub(r";.*", "", text)                    # line comments
        found = {m.lower() for m in re.findall(r"\b(FW[A-Za-z0-9_]*|BFA_[A-Za-z0-9_]*)\b", text)}
        return {f for f in found if f in avail and f != name}

    seen = {s.lower() for s in SEEDS}
    queue = list(seen)
    while queue:
        for dep in deps(queue.pop()):
            if dep not in seen:
                seen.add(dep)
                queue.append(dep)
    return sorted(avail[s] for s in seen)


def main():
    versions = read_versions()
    scripts = script_closure()

    staging = os.path.join(ROOT, "build", "api-kit")
    shutil.rmtree(staging, ignore_errors=True)
    os.makedirs(os.path.join(staging, "papyrus"))
    os.makedirs(os.path.join(staging, "examples"))

    for name in scripts:
        shutil.copy2(os.path.join(SRC, name + ".psc"),
                     os.path.join(staging, "papyrus"))

    shutil.copy2(os.path.join(KIT, "README.md"), staging)
    shutil.copy2(os.path.join(KIT, "BFConsumer.psc"),
                 os.path.join(staging, "examples"))
    for folder, ini in (("CustomRaceExample", "AddOn CustomRace Settings Example.ini"),
                        ("CustomActorExample", "AddOn CustomActor Settings Example.ini"),
                        ("AdultGrowUpExample", "AddOn Adult GrowUp Settings Example.ini")):
        shutil.copy2(os.path.join(ADDON, folder, ini),
                     os.path.join(staging, "examples"))

    with open(os.path.join(staging, "VERSIONS.txt"), "w", newline="\n") as fh:
        fh.write("\n".join([
            "Beeing Female NG integration kit",
            "",
            "Mod version       : %s  (FWVersion.GetVersion() == %s)"
            % (versions["BF_Version"], versions["BF_VersionInt"]),
            "MCM version       : %s  (FWVersion.GetMCMVersion())" % versions["BF_VersionMCM"],
            "Native/DLL version: %s  (FWVersion.GetNativeVersion())" % versions["BF_VersionNative"],
            "Animation version : %s  (FWVersion.GetAnimationVersionRequired())"
            % versions["BF_VersionAnimation"],
            "",
            "Gate an optional integration on presence first",
            "(Game.GetModByName(\"BeeingFemale.esm\") != 255), then on the mod version",
            "if you need a feature added in a specific release.",
            "",
            "Packaged from Beeing Female NG %s, and good for that version and later:"
            % versions["BF_Version"],
            "the mod-event commands and StorageUtil keys are append-only, so a newer",
            "BF still answers everything described here.",
            "",
        ]))

    os.makedirs(RELEASE, exist_ok=True)
    out = os.path.join(RELEASE, "BeeingFemaleNG-API-%s+.zip" % versions["BF_Version"])
    if os.path.exists(out):
        os.remove(out)
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
        for base, _, files in os.walk(staging):
            for name in sorted(files):
                full = os.path.join(base, name)
                zf.write(full, os.path.relpath(full, staging))

    print("%s  (%d scripts, %.1f KB)"
          % (os.path.relpath(out, ROOT), len(scripts), os.path.getsize(out) / 1024.0))


if __name__ == "__main__":
    main()
