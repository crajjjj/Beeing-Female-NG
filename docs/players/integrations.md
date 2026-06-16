# Mod Integrations & Patches

## Integration with Other Mods

### SexLab

Hooks orgasm events to add sperm. Supports both legacy SexLab and SexLab P+ (2.17.1+). Recognizes vaginal/anal/oral tags and Devious Devices keywords (chastity belts block insemination).

### OStim

Uses OStim's Fertility Mode compatibility event to add sperm on orgasm. Requires OStim API 23+. Condom detection is supported.

### Bathing in Skyrim

Bathing triggers sperm wash-out using the configured fluid wash-out chance.

## Optional Patches (FOMOD Installer)

The installer offers ready-made patches that hook other mods to Beeing Female. Select them only when you use the mod in question:

- **SPID item distribution** -- seeds BF's tampons, contraception, fertility tonics, and pregnancy-test items into vendors and loot via Spell Perk Item Distributor. Strongly recommended; without it BF items have to be consoled in.
- **Fertility Adventures Redux** -- wires FAR's pregnancy quests, child-support storylines, and announcement dialogue to BF cycle events instead of Fertility Mode.
- **P.A.I.A** (base) -- adds the Beeing Female detection the base P.A.I.A animation mod is missing, so the pregnant idle plays from the 2nd trimester of a BF pregnancy. Requires the SE/OAR variant of P.A.I.A.
- **P.A.I.A Expansion** -- repoints the Expansion's trimester-aware idles, sit/sleep adjustments, and inflation poses onto BF's pregnancy tracking.
- **FMR-Immersive Effects** -- removes FMR-IE's Fertility Mode requirement and drives its stretchmark/areola overlays, morning sickness, cravings, fetal kicks, Braxton-Hicks, and lactation effects from BF pregnancy progress, including a gradual fade-out during recovery.
- **RS Children child actors** -- BF-born children use RS Children Overhaul's look, matching other children in your game.
- **Creature child actors** -- species-matched offspring from creature impregnations (dog pup, falmer child, and so on).
- **SlaveTats Tattoo Packs** -- the womb-state and BabyTracker overlay textures used by the SlaveTats tattoo features. Shown and pre-selected only when SlaveTats is installed; skip it if you do not use SlaveTats. See [Tattoos (SlaveTats)](tattoos.md).

!!! note
    Patches that integrate via the add-on framework (RS Children child actors, creature child actors) install into `BeeingFemale/AddOn/`. Mod authors can find the technical details of each bundled patch in [Add-on Framework](../authors/add-on-framework.md).
