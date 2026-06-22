# Add-on Framework

Beeing Female NG ships an INI-driven add-on framework that lets external mods extend or override pregnancy/cycle behavior without editing core scripts. Add-ons are discovered from `dist/Core/BeeingFemale/AddOn/*.ini` and loaded at runtime. Example folders in `dist/Core/BeeingFemale/AddOn` have detailed explanations of every parameter — use them as templates.

## Add-on Types

- `misc`: scripted hooks (camera, birth effects, integrations like SexLab/OStim, Bathing in Skyrim).
- `race`: per-race tuning (durations, scales, pregnancy chance, protected/PC dialogue, custom baby actors/items).
- `actor`: per-actor overrides (same knobs as race, but scoped to a single actor).
- `cme`: cycle magic effect lists for each stage (Always/Sometimes).
- `global`: global defaults and `Global_*` settings (see `Default Global Settings.ini`); only one global add-on may be active at a time.

## Capabilities

- Global/default tunables for cycle timings, pregnancy chance, belly/breast scaling, pain, multiple births, and baby spawn pacing.
- Per-race or per-actor overrides (pregnancy scales, duration multipliers, protected child flags, etc.).
- Custom baby actor/item/armor selection for parent race/actor (with fallback behavior).
- Per-race/per-actor "switching babies" (NTR) settings that let a male reassign an already-pregnant female's child (see [Switching Babies (NTR)](#switching-babies-ntr)).
- Per-race/per-actor child-sex bias via `ProbChildSexDetermMale` (see [Child Sex](#child-sex)).
- Custom adult actor/voice selection for the grow-up feature (`AdultActor_*` — see [Adult Actor Add-ons](#adult-actor-add-ons-grow-up-feature) below).
- Integration hooks via misc add-ons (SexLab/OStim/Bathing in Skyrim).
- Add-on event hooks: `OnGiveBirthStart/End`, `OnLaborPain`, `OnBabySpawn`, `OnMagicEffectApply`, camera start/stop.

## Default Behaviors

- Uses global defaults from `Default Global Settings.ini` (or internal defaults if not set).
- If no custom baby actor is found, falls back to the parent actor base.
- Pregnancy visuals are driven by trimester scales plus `BellyMaxScale` and respect the selected visual scaling mode.
- Add-on lists refresh on game load when the AddOn directory hash changes or cached data is invalid.

## Custom Race Add-ons

Use a race add-on INI to customize pregnancy/cycle behavior per custom race.

1. Copy `dist/Core/BeeingFemale/AddOn/CustomRace AddOn Example.ini` and rename it.
2. In `[AddOn]`:
   - Set `name`, `description`, `author`, and `type=race`.
   - Set `required=YourRacePlugin.esp` (optional but recommended. Races for ActorTypeNPC should have "child" as part of the name).
   - Set `enabled=true` if you want it active by default (or enable it in MCM later).
3. Set `races=N`, then add `[Race1]...[RaceN]` sections.
4. In each `[RaceN]`, set `id=PluginName:FormID` (hex FormID without `0x`; commas allowed).
5. Edit the per-race settings you need (durations, pain scales, pregnancy chance, etc.).
6. (Optional) If you need custom baby actors/items, follow `dist/Core/BeeingFemale/AddOn/ChildActor AddOn Example.ini`.

After saving the INI, enable the add-on in the BeeingFemale MCM if it is not enabled by default.

## Custom Actor Add-ons

Use an actor add-on INI to customize pregnancy/cycle behavior for specific actors.

1. Copy `dist/Core/BeeingFemale/AddOn/CustomActor AddOn Example.ini` and rename it.
2. In `[AddOn]`:
   - Set `name`, `description`, `author`, and `type=actor`.
   - Set `required=YourPlugin.esp` (optional but recommended).
   - Set `enabled=true` if you want it active by default (or enable it in MCM later).
3. Set `actors=N`, then add `[Actor1]...[ActorN]` sections.
4. In each `[ActorN]`, set `id=PluginName:FormID` (hex FormID without `0x`; commas allowed).
5. Edit the per-actor settings you need (durations, pain scales, pregnancy chance, etc.).

After saving the INI, enable the add-on in the BeeingFemale MCM if it is not enabled by default.

## Switching Babies (NTR)

A male marked in a race or actor add-on can reassign an already-pregnant female's unborn child to himself when he deposits sperm -- the player-facing "switching babies in belly" mechanic. The keys go on the **male's** entry (per actor takes precedence over per race).

| Key | Meaning |
|-----|---------|
| `Allow_NTR_baby` | `true` lets this male swap an already-pregnant female's child to his own. Default `false`. **Gated by the player's "Allow switching babies in belly" MCM toggle** (Pregnancy page, off by default): with that toggle off, this key is ignored entirely. |
| `Sperm_NTR_baby_Prob` | Swap chance (used only when `Allow_NTR_baby=true`). A `0-99` roll succeeds if it lands below `Sperm_NTR_baby_Prob` minus the *current* father's own `Sperm_NTR_baby_Prob` -- so a father with his own value resists being swapped out. `0` or negative disables the swap. Default `0`. |

Behavior notes:

- The roll runs **per child** on each pregnancy tick across all three trimesters; once the female is in labor pains, no swap occurs.
- Only the father record (`FW.ChildFather`) changes -- the pregnancy is *not* restarted. The new father determines the child's inherited race/traits at birth.
- Estrus Chaurus impregnation (and the Spider / Dwemer add-ons) takes priority and is never overridden by an NTR swap.

See the commented `Allow_NTR_baby` / `Sperm_NTR_baby_Prob` block in `dist/Core/BeeingFemale/AddOn/CustomActor AddOn Example.ini` for a ready-to-copy template.

## Child Sex

A race or actor add-on can bias — or fully fix — the sex of children fathered by that NPC/race. The key goes on the **male's** entry.

| Key | Meaning |
|-----|---------|
| `ProbChildSexDetermMale` | Percent chance (0–100) that a child fathered by this actor/race is **male**. `100` = always a boy, `0` = always a girl. Resolution: actor entry → race entry → the global MCM **"Child sex determinator"** slider (default `53`). Rolled per child **at birth**, for both the **Actor** and **Item/Actor** spawn modes (not **Gem**, which produces no child). |

> Edge case: in Actor mode the rolled sex is used to pick the child's `ActorBase`, then re-read from that base. If a custom `BabyActor_*` pool for the chosen race offers only one sex, the available base's sex can override the roll.

The `CustomActor AddOn Example.ini` template illustrates this key (its sample `Dragonborn:1FB99` actor block uses `ProbChildSexDetermMale=100`), but that file ships **disabled** (`enabled=false`) — it has no effect until a player enables it in the MCM.

## Adult Actor Add-ons (Grow-Up Feature)

When **"Children grow into adults"** is enabled (MCM Children page), a child that finishes growing transitions into a real adult NPC. The adult's actor base is resolved from add-on INI lists, using the same mechanics and INI format as the `BabyActor_*` keys. The keys can be declared per race, per actor, or globally (resolution order: actor add-on, then race add-on, then global; if no list provides a base, the adult is spawned as a copy of the same-sex parent's base -- generic bases only: the player's base and unique NPC bases are never cloned, and with no usable base the transition aborts and retries).

| Key | Meaning |
|-----|---------|
| `AdultActor_Male` / `AdultActor_Female` | Comma-separated `PluginName:FormID` list of adult ActorBases. One entry is picked at random per transition, so longer lists give more variety. |
| `AdultActor_MalePlayer` / `AdultActor_FemalePlayer` | Optional dedicated lists for the player's own children; checked before the generic lists. |
| `AdultActorVoice_Male` / `AdultActorVoice_Female` | VoiceType (`PluginName:FormID`) applied to resolved bases that ship without a voice (such as the vanilla chargen presets). Bases that already have a voice keep it. Pick a follower-capable voice if you want the adult recruitable. |
| `AdultOutfit_Male` / `AdultOutfit_Female` | Outfit (`PluginName:FormID`) applied to adults spawned from add-on bases (entry 0; actor -> race -> global). Without it those adults get the roughspun-tunic fallback. Parent-base copies keep their base's own outfit. |
| `GrowUpToAdult` | Per-race/per-actor explicit override: `1` = always grow (even with the MCM toggle off), `-1` = never grow (even with it on). `Global_GrowUpToAdult` in a global add-on INI enables the feature globally. Legacy `GrowUpToAdult=true` still reads as `1`. |
| `Global_AllowAdultMarriage` | Global add-on INI only (`=1`): grown adults join the vanilla marriage pool (voice permitting). Off by default; no MCM equivalent. |
| `Global_ProtectGrownAdult` | Global add-on INI only: `1` = Protected, `-1` = fully killable (clears Protected and Essential), `0` = leave the actor base's own ESP setting untouched (default). Base-level flag, so parent-base copies are never touched. |

The shipped `dist/Core/BeeingFemale/AddOn/Default Adult Actors.ini` maps all 10 vanilla races (including vampire variants) to the **BF Adult Pack** bases (`BeeingFemaleAdultPack.esp`, ESL-flagged): 10 dedicated adults per race and sex, generated from Skyrim's chargen presets so their faces are computed live (no FaceGen files, no dark-face), with proper names, a real class, baked-in follower voices, a farm-clothes outfit, and a sandbox AI package. Delete or disable the INI to fall back to parent-base copies. A copyable template showing all grow-up keys ships in `AddOn/AdultGrowUpExample/`; the pack itself can be regenerated with the xEdit script in `tools/xedit/BFAP_GenerateAdultPack.pas`.

### Shipping adult NPCs with their own dialogue ("Mom"/"Dad" lines)

BF's spoken parent-child greetings come from the HearthFires adoption dialogue, which only exists for child voice types -- grown adults lose them. An add-on plugin can bring them back, because `AdultActor_*` bases resolve from **any** installed plugin, including one that also contains dialogue:

1. Create a plugin with your adult ActorBases (custom faces, or duplicates of vanilla presets).
2. Add a faction to the plugin and put it in each base's faction list -- actors spawned from the base inherit it, so your dialogue can be conditioned on `GetInFaction` with no scripting. (Conditioning on a custom VoiceType assigned to your bases works too; BF never overrides a voice the base already has.)
3. Add dialogue topics conditioned on that faction. Useful extra conditions:
   - `GetRelationshipRank >= 3` toward the player -- BF sets rank 3 on the player's grown children at transition, so only *your* children greet you as a parent.
   - `GetPCIsSex` -- picks "Mom" vs "Dad" lines for the player.
4. Reference the bases from an `AdultActor_*` INI (`AdultActor_Female=YourPlugin.esp:FormID,...`). When your plugin is not installed the forms resolve to none and the normal fallback applies, so the INI is safe to ship.
5. Voice the lines, or leave them silent with subtitles (players can use Fuz Ro D-oh for readable timing).

Everything else -- spawning, follower factions, relationships, persistence across saves -- is handled by BF at transition time.

## Bundled Optional Patches

`dist/Patches/` ships compatibility patches exposed as optional FOMOD components (`dist/fomod/ModuleConfig.xml`):

| Patch | What it does |
|-------|--------------|
| `SPID` | Spell Perk Item Distributor INI seeding BF's hygiene / contraception / fertility-tonic / pregnancy-test items into vendor and container loot. |
| `Fertility Adventures Redux` | Wires FAR's pregnancy quests, child-support storylines, and announcement dialogue to BF NG cycle events (Conception / Labor / state ticks) instead of Fertility Mode. |
| `PAIA` | Adds the Beeing Female OAR submod the base P.A.I.A is missing (the author reserved priority 91044062 for it but only shipped a legacy DAR condition). Pregnant idle plays at `ParentFaction` rank >= 5 (2nd trimester onward). Mesh-only. |
| `PAIAExpansion` | Repoints P.A.I.A Expansion's OAR conditions onto BF's `ParentFaction` so trimester idles, sit/sleep adjustments, and inflation poses follow BF pregnancies. Mesh-only. |
| `FMR-Immersive Effects` | Drops FMR-IE's hard `Fertility Mode.esm` master; a replacement bridge script derives FMR's 0..115 pregnancy rank from BF state and drives the overlays / random pregnancy effects from it. See the patch folder's README for the full design and build steps. |

Patches that integrate via the add-on framework (RS Children child actors, creature child actors) live in the FOMOD as well but install into `BeeingFemale/AddOn/`.
