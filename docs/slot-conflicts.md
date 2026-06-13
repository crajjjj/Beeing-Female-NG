# Item Slots & Resolving Conflicts

This page explains which body slots Beeing Female's hygiene items use, why they
sometimes conflict with other mods (bikini armor, SOS, backpacks, Devious
Devices…), how to diagnose it, and how to permanently move an item to a free
slot. If an outfit keeps knocking your tampon/pad off — or the pad won't show
during menstruation — this is for you.

## What slots does Beeing Female use?

Only the hygiene items occupy a body slot:

| Item | EditorID | Biped slot |
|------|----------|-----------|
| Sanitary pad / panty (normal & bloody) | `_BFArmorPantyNormal` / `_BFArmorPantyBloody` | **52** |
| Tampon (normal & bloody) | `_BFTamponNormal` / `_BFTamponBloody` | **54** |

That's it — nothing else in BF takes a wearable slot.

## How slots work (quick primer)

Every piece of armor/clothing equips into a **biped slot** — an attachment point
on the body. Skyrim has 32 of them, numbered **30–61**. The engine tracks them as
a bitmask: **equipping an item unequips whatever else is in the same slot.** That
is the entire conflict mechanism.

Slots 30–43 are the vanilla ones (body 32, hands 33, feet 37, amulet 35, ring 36,
circlet 42, etc.). Slots **44–60** are mostly unused by vanilla, so mods grab them
for *extra* gear — underwear, piercings, capes, backpacks, and BF's hygiene items.

## Why conflicts happen

A clash occurs whenever **two mods use the same free slot**. The usual offenders
against BF:

- **Slot 52 (pad/panty) is heavily contested.** Schlongs of Skyrim (**SOS**) uses
  slot **52** by default, as do many underwear/body mods, some **bikini armor**
  accessory pieces, and certain **Devious Devices** items. Equipping any of those
  can pop the BF pad off, and BF may keep re-equipping it — the visible "fighting."
- **Slot 54 (tampon) is rarely used** by other mods, so tampons almost never
  conflict.

!!! tip "Quick workaround"
    If you run SOS or bikini armor and get pad conflicts, **use tampons instead of
    pads** — slot 54 sidesteps the whole problem with no patching.

Backpacks (slot **47**) and cloaks (slot **46**) do **not** overlap BF's 52/54, so
those coexist fine.

## Diagnose it (find the real culprit)

Don't guess — read the slot from the conflicting mod:

1. Open the other mod's `.esp`/`.esm` in **SSEEdit (xEdit)**.
2. Expand its **Armor (ARMO)** records, select the item that's fighting BF.
3. Look at **`BOD2` → "First Person Flags."** Every slot it lists is a slot it
   occupies.
4. If you see **52** there, that's your conflict with the BF pad.

## Permanent fix — move an item to a free slot

A slot is declared in **two** places that must agree, so a proper fix edits
**both**:

- **The ARMO record's `BOD2` flags** — what the engine uses for occupancy/conflict.
- **The mesh's (`.nif`) partitions** — what actually renders.

Editing only one desyncs them (item won't show, or won't hide/occupy correctly).

### Part A — the record (SSEEdit)

1. Decide which item to move. Moving the **BF pad off 52** (e.g. onto a free slot)
   is usually easiest, or move the *other* mod's item — your choice.
2. In xEdit, right-click the plugin → **Create a patch** (don't edit BF or the
   other mod directly).
3. Drag the ARMO record into your patch, open **`BOD2` → First Person Flags**,
   untick the old slot, tick a **free** slot, and save.
4. Also retarget the matching **ARMA (Armor Addon)** record's slot the same way if
   it lists the old slot.

!!! note "Finding a free slot"
    In xEdit, check what slots your load order already uses. Slots like **49, 55,
    56, 58, 59, 60** are commonly free, but verify — picking another occupied slot
    just moves the conflict.

### Part B — the mesh (NifSkope)

The `.nif` carries its own copy of the slot in the skin partitions:

1. Open the item's `.nif` in **NifSkope**.
2. Find the **`BSDismemberSkinInstance`** block attached to the shape
   (`BSTriShape`/`NiTriShape`).
3. Expand its **`Partitions`** array.
4. In each partition, change **`Body Part`** from the old slot enum (e.g.
   `SBP_52_UNNAMED`) to the new one (e.g. `SBP_55_UNNAMED`). The number in the
   enum **is** the slot.
5. If the mesh has **multiple partitions** on that slot, change **every** one, or
   part of it stays behind.
6. Leave the partition flags (`PF_EDITOR_VISIBLE`, `PF_START_NET_BONESET`) alone.
   Save.

Now the record (BOD2) and the mesh (partitions) name the same new slot, and the
item coexists with whatever was on the old one.

## What about changing the slot "dynamically"?

People ask whether a script can just switch slots at runtime to dodge conflicts.
**In practice, no.** Vanilla Papyrus has no slot setter, and even SKSE extenders
that can flip a record's slot mask **can't repartition the mesh** — so the item
would occupy the new slot for conflict purposes but still render per its old
partitions. Slot changes are a **static** edit (record + nif), as above. There is
no reliable on-the-fly version.

## TL;DR

- BF pad/panty = **slot 52**, tampon = **slot 54**.
- Slot 52 collides with **SOS / bikini accessories / some underwear & DD items**;
  slot 54 is usually clean.
- Easiest fix: **use tampons.**
- Real fix: repatch the item to a free slot in **xEdit (BOD2)** *and* **NifSkope
  (BSDismemberSkinInstance partitions)** — both, or it breaks.
