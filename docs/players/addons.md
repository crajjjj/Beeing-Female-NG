# Bundled Add-ons

Beeing Female is driven by **INI add-ons** in `Data/BeeingFemale/AddOn/`. The mod ships with a set of them that enable integrations, cycle effects, content, and global tuning — all without editing scripts. You turn them on or off on the **MCM AddOn page**; this page explains what each shipped add-on does and whether it starts enabled.

This is different from two related pages:

- [Mod Integrations & Patches](integrations.md) covers **external-mod** hooks and the FOMOD patches (some of which *install extra* add-on INIs, like RS Children or creature children).
- [Add-on Framework](../authors/add-on-framework.md) is the **author** guide for writing your own add-ons (and documents the example templates listed at the bottom of this page).

Add-ons have a **type** that decides what they affect: `misc` (integration/feature hooks), `cme` (cycle magic effects — spells tied to cycle states), `race` (per-race content and tuning), `actor` (per-NPC overrides), and `global` (one settings file for everything).

## Integration & feature add-ons (`misc`)

| Add-on | Default | What it does |
|--------|---------|--------------|
| **SexLab** | On | Hooks SexLab orgasm events to add sperm. Only does anything if SexLab is installed. See [Integrations](integrations.md#sexlab). |
| **OStim** | On | Adds sperm on OStim orgasm (API 23+, condom-aware). Only active with OStim installed. See [Integrations](integrations.md#ostim). |
| **Bathing in Skyrim** | On | Makes the original *Bathing in Skyrim* wash out sperm when you bathe. |
| **Bathing in Skyrim Renewed** | On | Same wash-out hook for the *Renewed* version of Bathing in Skyrim. |
| **FreeCam** | On | Switches to a free camera during the birth sequence so you can watch it. |
| **Contraception-Reminder** | On | Reminds you when your contraception is wearing off and it is time for the next dose. |
| **Visual effects** | On | Adds screen/visual effects whenever a woman is in pain (cramps, labor, etc.). |
| **Hunger AddOn** | Off | Adds a "hungry" ability during PMS and pregnancy (cravings-style effect). Enable for extra immersion. |

The integration hooks above are safe to leave enabled even if you do not have the target mod — they simply do nothing until it is present.

### How the Contraception-Reminder works

When enabled it watches your active contraception and updates a **quest objective in your Journal** (the Quest menu) telling you when to take the next dose — so Skyrim shows its usual "objective updated" on-screen cue as the state changes. It checks every ~2 in-game hours and again immediately whenever your contraception changes, and it only tracks the **player** while she is a tracked female — it never alters your contraception, it just notifies.

It compares the current time against when you last dosed plus your contraception's configured duration (the pill/fluid duration):

- **No reminder** while you are covered — either you have effectively no active contraception (level below ~5%), or less than about three-quarters of the dose's duration has passed.
- **"Take it soon"** once you enter the final stretch — roughly the last quarter of the dose's duration, before it lapses.
- **"Overdue"** once the dose has fully worn off (a few in-game hours past its duration).

The objectives clear automatically when you take a fresh dose (or lose all contraception). This add-on uses a quest from `BeeingFemaleBasicAddOn.esp`, which is therefore required.

### How the Hunger AddOn works

This add-on applies a **"Hungry" ability** during the cycle phases where appetite changes: **always** in the 1st trimester, and **sometimes** during PMS and the 2nd trimester.

While the ability is active it tracks when you last ate — vanilla food counts, and it also listens for a needs-mod "consume" event. Once enough time passes since your last meal (roughly a minute and a half of real play, or about two in-game days), the woman gets hungry and one of two things happens:

- **She auto-eats from your inventory** — the add-on finds food you are carrying and consumes 1–4 items at random, applying their restore effects. So being pregnant quietly nibbles through your rations.
- **She growls if there's no food** — with an empty larder it plays a stomach-growl sound and creates a detection event, which can give away your position while sneaking.

The growl is player-only (an NPC with the ability still eats, just silently). It ships **disabled** by default. This add-on also uses `BeeingFemaleBasicAddOn.esp`, which is therefore required.

## Cycle effects (`cme`)

These assign buff/debuff spells to cycle phases. Both ship **disabled** so they never surprise you; enable them for gameplay effects tied to the cycle.

| Add-on | Default | What it does |
|--------|---------|--------------|
| **Basic Buffs 1** | Off | Sample buffs and debuffs applied across cycle phases. |
| **Basic Effects 2** | Off | A set of basic **PMS** effects during menstruation. |

## Content add-ons (`race`)

| Add-on | Default | What it does |
|--------|---------|--------------|
| **BF Adult Pack** | On | Adult NPC bases (from `BeeingFemaleAdultPack.esp`) used when children grow into adults — proper names, class, follower voice, outfit, and a sandbox AI package, with live-computed vanilla-preset faces (no FaceGen). See [Growing Into Adults](children.md#growing-into-adults). |
| **Default Baby Items** | On | The default baby-item armors used when baby spawn mode is set to item. See [Baby Items Growing to Children](children.md#baby-items-growing-to-children). |
| **Creature specifications** | On | Per-creature settings for creature pregnancies/offspring. |
| **Race Specific Values** | Off | Per-race tuning — some races get more/less pain, longer/shorter phases, etc. Off by default to avoid conflicting with other race add-ons. |
| **Vampire Race** | Off | Makes vampire races unable to become pregnant. Off by default to avoid conflicts. |

## Global settings (`global`)

| Add-on | Default | What it does |
|--------|---------|--------------|
| **Default Global Settings** | Off | A single file holding **every** global option at its default value. Ships disabled so it never silently overrides anything (the values already match the system defaults). To change a setting for all races, edit the value **and** set `enabled=true`. Only one active `global` add-on may exist at a time. |

## Author example templates

Three commented templates ship under `BeeingFemale/AddOn/` subfolders as starting points for your own add-ons — they are not meant to be enabled as-is:

- **CustomRace Settings Example** — a `race` add-on skeleton.
- **CustomActor Settings Example** — an `actor` (per-NPC) add-on skeleton.
- **Adult GrowUp Settings Example** — shows the grow-into-adult keys.

See the [Add-on Framework](../authors/add-on-framework.md) for the full key reference.

## Managing add-ons

- Open the **MCM → AddOn** page to see every loaded add-on with its name, description, and author, and to enable or disable each one (see the [MCM Reference](mcm-reference.md)).
- Add-ons are read from `Data/BeeingFemale/AddOn/` (including subfolders). The mod hashes that folder on each game load and reloads the INIs when anything changes, so dropping in or editing a file is picked up automatically.
- Disabling an add-on stops its effects without deleting the file; deleting the file removes it on the next load.
