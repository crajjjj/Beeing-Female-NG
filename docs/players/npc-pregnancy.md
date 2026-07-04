# NPC Pregnancy & Couples

NPCs can go through the same cycle and pregnancy system as the player. Key settings:

| Setting | Default | What It Does |
|---------|---------|-------------|
| NPCs Can Become Pregnant | On | Global toggle |
| NPC Feel Pain | Off | NPCs get pain effects |
| NPC Born Child | On | NPCs actually spawn child actors |
| NPC Have Items | Off | NPCs receive hygiene/contraception items via scripts |

NPCs near the player are scanned periodically and given the cycle tracking spell. Their pregnancies progress in the background based on game time. Only NPCs that actually exist in a plugin are picked up this way -- runtime-spawned generics (leveled bandits and similar temporary actors the engine later deletes) are skipped, which keeps long saves free of orphaned script data. Spawned actors serving as your followers are the exception: they stay fully tracked.

To keep the tracked-NPC list from growing without bound over a long playthrough, an NPC the player has not been near for **3 in-game days** is quietly dropped from active tracking, and re-discovered with a fresh cycle the next time you meet her. Cleanup never touches a woman with anything in progress -- she is kept while **pregnant, in labor, recovering, miscarrying, on contraception, or carrying sperm**. The only visible effect is that an idle, non-pregnant NPC's exact cycle position is not remembered across a long absence; pregnancies and conceptions are always preserved.

When baby spawn mode is "Item/Actor" and **you are the father**, an NPC mother will hatch the baby item she carries into her own child (a normal NPC near her, not your follower) once it matures while she is loaded -- see [Baby Items Growing to Children](children.md#baby-items-growing-to-children).

## NPC Auto-Insemination (Couples System)

When enabled in MCM (Impregnate page), the mod can automatically inseminate tracked NPCs in the background -- even when the player is not around. This models background conception between paired NPCs so their cycles progress without the player present.

**How it works:** Once per in-game day (at a configurable time), the system queues several random tracked females (the **Count** setting) and works through them a few per game-hour rather than all in one frame. This is best-effort -- any not reached before the next day's check are simply skipped.

**Partner selection is weighted by relationship:**

| Source | Weight | Description |
|--------|--------|-------------|
| Husband | 10x | Vanilla spouse or manually assigned via Couple Widget |
| Affairs | 4x | Assigned via Couple Widget |
| Partners | 2x | Assigned via Couple Widget |
| Last Seen NPCs | 1x | Males the female was recently near (automatic) |

A male is picked randomly from this weighted pool (e.g. a husband is 10 times more likely to be chosen than a random nearby NPC). The system tries up to 3 times to find a valid male.

**Fallback when no partner is known:** if a female's pool is empty (no husband, affairs, partners, or recently-seen males) and **Last Seen NPCs** is enabled, the mod falls back to a random valid male in **her own** current location -- so an NPC with no configured relationships can still be inseminated by whoever happens to be nearby, subject to the same validity rules below.

**A male is valid if:**

- Not in the player's current location
- Not a player follower
- Had sex more than ~7 hours ago (cooldown)
- Relationship rank is neutral or better (not an enemy)
- Not a creature (unless creature sperm is enabled)

**Couple data** is stored in JSON files at `Data/BeeingFemale/Couples/`. Each file is named `ModName_FormID.json` and contains husband, affairs, and partners for one female NPC. You can edit these manually or use the in-game Couple Widget. The exact file format and bulk-import behavior are documented in [Couples Import](couples-import.md).

## Couple Widget

The Couple Widget is a debug/editing tool for managing NPC relationships in-game. Enable it in MCM under the System page.

| Hotkey | Action |
|--------|--------|
| E (hold 1.5s) | Select a female NPC as subject |
| H (hold 1.5s) | Assign or clear husband |
| G (hold 1.5s) | Add or remove affair partner |
| P (hold 1.5s) | Add or remove regular partner |

The widget auto-detects existing vanilla spouses (relationship rank 4+ or Spouse association).

## Couples Import

You can bulk-import couple data from JSON files via MCM (first page, "Couples Import"). This scans `Data/BeeingFemale/Couples/` and applies stored partner data to matching NPCs.

## MCM Settings (Impregnate Page)

| Setting | Default | What It Does |
|---------|---------|-------------|
| Active | Off | Master toggle for NPC auto-insemination |
| Husband | On | Include husbands in partner pool |
| Affairs | On | Include affairs in partner pool |
| Partners | On | Include regular partners in partner pool |
| Last Seen NPCs | Off | Include recently nearby males |
| Time | Configurable | What time of day the daily check runs |
| Count | 3 | How many NPCs to queue per daily check (spread across game-hour ticks) |

> The recently-seen-males list (the 1x pool source) is populated using [powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854); without it installed, that list stays empty. The husband/affairs/partners pools and the same-location fallback do not need it.
