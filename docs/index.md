# Beeing Female NG

A Skyrim SE/AE/VR mod that simulates a female reproductive cycle: menstruation, fertility, conception, pregnancy, birth, and interactive children — for the player and for NPCs. It is a hybrid SKSE C++ plugin plus Papyrus script system built on CommonLibSSE-NG.

These docs are split into two tracks. Pick the one that fits you:

## For Players

Install it, play it, configure it. Start here if you just want to use the mod.

- [Getting Started](players/getting-started.md) — requirements, installation, and "it doesn't show up in the MCM" fixes
- [Cycle, Sex & Conception](players/cycle-and-conception.md) — the menstrual cycle, insemination, contraception, conception, and Fertility Tonics
- [Pregnancy & Birth](players/pregnancy-and-birth.md) — trimesters, baby health, miscarriage, and labor
- [Children](players/children.md) — growth, growing into adults, baby items, and commands
- [HUD Widgets](players/hud-widgets.md) — the on-screen widgets and how to reposition them
- [Tattoos (SlaveTats)](players/tattoos.md) — baby tracker, semen circle, and womb-state overlays
- [NPC Pregnancy & Couples](players/npc-pregnancy.md) — background NPC cycles and auto-insemination
- [Couples Import](players/couples-import.md) — the JSON couple-file format and the MCM import button
- [Mod Integrations & Patches](players/integrations.md) — SexLab, OStim, Bathing, and the optional FOMOD patches
- [MCM Reference](players/mcm-reference.md) — every MCM page at a glance

## For Mod Authors

Extend or integrate with Beeing Female without touching its core scripts.

- [Add-on Framework](authors/add-on-framework.md) — INI-driven race/actor/cme/misc/global add-ons, including the grow-up adult pack
- [Papyrus ModEvents API](authors/modevents.md) — the events BF listens for and emits
- [StorageUtil & State Data](authors/state-data.md) — reading cycle/sperm/pregnancy state from `FW.*` keys
- [Pregnancy Ranks (Factions)](authors/pregnancy-ranks.md) — driving animations from the `ParentFaction` rank
- [Item Slots & Conflicts](authors/item-slots.md) — diagnosing and repatching hygiene-item slot clashes (SOS, bikini armor, DD…) in xEdit/NifSkope
- [Building from Source](authors/building.md) — xmake, the Papyrus compiler, and repo layout

---

The changelog lives on the [GitHub releases page](https://github.com/crajjjj/Beeing-Female-NG/releases).
