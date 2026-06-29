# Beeing Female NG vs. Fertility Mode Reloaded

Beeing Female and Fertility Mode are the two best-known female reproductive-cycle / pregnancy frameworks for Skyrim. They cover the same broad ground — menstrual cycle, conception, pregnancy, birth, and born children for the player and NPCs — but they're built on different foundations, with different design priorities.

This page is a neutral, technical comparison of the two **current, actively-maintained** versions: **Beeing Female NG** (this project) and **Fertility Mode Reloaded** (FMR). It focuses on what each does today — architecture, features, requirements — not their origins. Architecture and feature claims are drawn from the Papyrus/C++ sources both ship; hosting and requirements are cited from public pages. Specific version references are **BF NG 3.5.x** and **FMR 1.0.3** — both mods evolve, so re-check current pages before deciding.

!!! note "Why this page exists"
    People routinely ask which of the two to run, or whether they can coexist. They generally **should not run together** — both track the same NPCs and apply belly scaling, so they fight over the same state. Pick one. This page lays out the trade-offs honestly, including where the other mod is the better fit.

## At a glance

| | **Beeing Female NG** | **Fertility Mode Reloaded** |
|---|---|---|
| Foundation | Hybrid SKSE C++ plugin (CommonLibSSE-NG) + Papyrus | Papyrus, built on JContainers + PO3 |
| Hosting | [Nexus](https://www.nexusmods.com/skyrimspecialedition/mods/168434) · [GitHub](https://github.com/crajjjj/Beeing-Female-NG) (GPL-3.0) | [Nexus](https://www.nexusmods.com/skyrimspecialedition/mods/165569) |
| Platforms | Skyrim SE / AE / VR | Skyrim SE / AE / VR |
| Status | Actively maintained | Actively maintained |
| Core philosophy | Deep simulation + broad features, with active performance engineering (distributed ticking, idle cleanup, load-gating) | Leaner and bounded by design (hard cap, batched throttles) |

## Architecture & performance

This is the deepest difference between the two, and it shapes everything else. The two mods take **opposite approaches** to ticking the cycle.

### The loop

**Beeing Female NG — decentralized, per-actor.** Each tracked female carries an ability (`BeeingFemaleSpell`) whose effect script *is* her cycle state machine. She ticks herself via a self-rescheduling game-time update; the interval changes per state (≈1 game-day for most phases, 0.2 day during labor). There is no central loop iterating every woman. Discovery is a magic-effect "cloak" that tags nearby valid actors.

**Fertility Mode Reloaded — centralized, single loop.** One quest-alias script ticks on a fixed game-time interval (default 1 hour, MCM 1–24h) and then iterates the entire tracked array, updating each woman in one pass. Discovery is event-driven through powerofthree's Papyrus Extender (`RegisterForObjectLoaded`), so there is no cell scan.

| Aspect | **BF NG** | **FMR** |
|---|---|---|
| Tick model | Per-actor self-scheduling magic effect | One central loop over an array |
| Interval | Dynamic per state (1 day / 0.2 labor) | Fixed (default 1 game-hour) |
| Discovery | Cloak magic effect | PO3 `RegisterForObjectLoaded` (no cell scan) |
| State storage | Explicit states 0–8 persisted (StorageUtil) | Derived from timestamps each tick |
| Tracked-actor cap | Soft — bounded by idle cleanup | Hard cap **256** |

### Discovery — how each mod finds NPCs to track

**BF NG — cloak magic effect.** BF casts a Skyrim *cloak spell* on the player: a constant ability with an area effect that the engine continuously applies to every actor who comes within range. The first time an actor enters that radius, the cloak's effect script (`FWCloaking`) runs once for them — it validates the actor (sex, race, uniqueness, and the mod's tracking rules) and, if eligible, adds the cycle ability (`BeeingFemaleSpell` for women, `BeeingMaleSpell` for men, plus an items spell for non-unique females when enabled). A dedup list (`BF_CloakEffectList`) makes sure each actor is processed only once, and once an actor is untracked their marker is cleared so the cloak can re-add them later.

There is a **single cloak, on the player only** — no cloak runs on NPCs. The appeal: the engine handles proximity for free, with no scan loop or load-event plumbing to maintain. The catch is twofold. First, reach is limited to the *player's* vicinity: an NPC is discovered only when the player comes within the cloak's radius, so a woman elsewhere in the loaded area isn't tracked until the player gets near her. Second, cloaks have a general overhead reputation — but BF's is **deduped** (`BF_CloakEffectList`): a newly-seen actor pays a one-time validation (sex/faction/race checks) the first time, and every re-application after that is a cheap early-out. So the real cost is **front-loaded per new actor** and concentrated where the player is — a burst when first entering a packed city, near-free walking among already-known NPCs.

**FMR — PO3 object-loaded events.** FMR instead registers for powerofthree's Papyrus Extender `RegisterForObjectLoaded` (form type NPC), which fires whenever a relevant actor's 3D loads in. There is no proximity cloak and no cell scan. The catch is that **entering a cell loads many actors at once**, so the event fires in a burst — a discovery spike at the exact moment of a cell transition, when the engine is already busy streaming in the new area. FMR's answer is the batched queue: incoming actors are buffered and drained only ~10 per 0.1s, spreading that burst across several frames instead of landing it in one. So the spike is mitigated rather than absent, and the approach makes **PO3 a hard requirement**.

In other words, neither approach is free — they just put the cost in different places. The cloak pays a one-time validation per newly-seen actor (cheap deduped re-checks thereafter), bursting only when the player enters a new crowd; PO3 events pay in a cell-entry burst that has to be batched away. They also differ in **reach**: the player-only cloak finds women within its radius around the player, while object-loaded events fire for any NPC the game streams into the loaded area. Both mods require PO3 regardless, so this is a difference in discovery *mechanism*, not in dependencies.

**A BF NG plus — couple simulation.** Discovery only decides *who* gets tracked. On top of it, BF NG lets you *author* relationships: an in-game **Couple Widget** (hotkey-driven, with optional bulk JSON import) assigns each woman a husband, affairs, and partners. Background auto-insemination then simulates those couples over time — assigned NPCs conceive with their partners even when the player is elsewhere, weighted so a husband is far likelier to be the father than a passing stranger. It turns a flat tracking list into an authored social layer.

### Performance trade-offs

Neither approach is strictly "faster" — they fail differently under load:

- **BF NG** spreads cost across many self-scheduled ticks, so there is no single hot loop; it degrades gracefully with very large tracked populations. Tracking is kept in check by **idle-NPC untracking** — a non-pregnant, idle woman the player hasn't been near for several in-game days is dropped (and re-discovered later), which bounds the population and stops her ticks. Heavy per-actor work (belly morphs, instant-born) is gated on `Is3DLoaded`.
- **FMR** pays for one synchronous loop but layers explicit throttles on top: a **batched discovery queue** (~10 actors per 0.1s), **staggered belly rescaling** on cell change (a few actors per tick), and **milestone-gated mod-events** to avoid VM spam. Its safety nets are the **256 cap** and a **location-based auto-cleanup** that drops NPCs the player left ~48 game-hours ago with nothing in progress. Its main cost center is the fertility loop itself, which is unbatched and scales linearly toward the cap.

In short: **BF NG distributes work (graceful, soft-capped via idle cleanup); FMR centralizes it (hard-capped, with explicit throttles).** Both gate heavy visual work on whether the actor is loaded.

## Feature comparison

Both cover the core loop; they diverge in breadth and depth.

| Feature | **Beeing Female NG** | **Fertility Mode Reloaded** |
|---|---|---|
| Menstrual cycle | ✅ Full 4-phase (follicular/ovulation/luteal/menstruation) | ✅ Cycle-day phases, per-actor offset to desync NPCs |
| Conception | ✅ Sperm decay + fertile-window gates; "any period" overrides | ✅ Dual system (cycle-day **+** egg-age) to survive fast-travel |
| Contraception | ✅ Items + widget countdown | ✅ Potion + effect clamping fertility |
| Pregnancy scaling | ✅ **5 backends** (NiOverride, b3lisario nodes, weight, SLIF) | ✅ NiOverride morphs |
| Miscarriage | ✅ Rich **6-stage** system (fever, infection, bleed-out) | ✅ Simpler, player-focused baby-health damage |
| Birth / labor | ✅ Multi-stage (4 phases), water-break, DHLP suspend/resume | ✅ Event-threaded labor with anim + lock |
| Labor pain & expressions | ✅ Graduated **pain effects** (screen-blur / iMod, per-race & per-actor magnitude) + **facial expressions** during birth (via SexLab or SexLab-independent) | Labor animation (idle) |
| Born children | ✅ Actors with growth, **skill/perk menu**, grow-to-adult | ✅ Baby grows into spawned NPC |
| Child race / species | ✅ Vanilla, **races from other installed mods, and real creatures as children** (via race + creature-child add-ons) | Vanilla races + vampire variants; creature *fathers* only |
| Child → follower | ✅ Grow-up to adult, **summonable**, marriage/follower factions | ✅ **Class-based training**, summonable |
| Baby models & sounds | ✅ Custom carried-baby models (slings, UBE / worn-item add-ons) + baby crying **sounds** | Baby item at birth (item / soul gem / none) |
| NPC tracking | ✅ Player + NPC; **in-game couple-simulation menu** (husband/affairs/partners) + auto-insemination | ✅ Player + NPC, creature fathers, unique-only filters |
| PMS effects | ✅ 10 variants | ❌ |
| Menstrual hygiene | ✅ Pads/tampons, soiling, blood FX | ❌ |
| Tattoos | ✅ SlaveTats (semen/womb) | ❌ |
| HUD widgets | ✅ 6 widgets | ✅ Single widget |
| Add-on framework | ✅ **INI-driven** (race/actor/CME/misc), no scripting | Faction-rank + mod-event hooks |
| Mod-event API | ✅ `BeeingFemale*` events | ✅ `FMR_*` events; **DAR/OAR faction ranks 0–120** |

**Where each pulls ahead:**

- **BF NG** has the broader, deeper surface: hygiene, PMS, a 6-stage miscarriage system, tattoos, five scaling backends, Devious Devices awareness, and an INI add-on framework that lets patchers extend it without editing scripts — including children of **races from other installed mods** and **real creatures as children** (creature-child add-ons), driven by per-race/per-actor INI overrides. It's a simulation.
- **FMR** is the more focused, defensively-engineered mod. Its standout gameplay features are the **class-based child-training** system and a DAR/OAR faction-rank API that animation add-ons hook directly.

## Requirements & integrations

| | **Beeing Female NG** | **Fertility Mode Reloaded** |
|---|---|---|
| Always required | SKSE64, SkyUI, **PapyrusUtil**, **PO3**, Address Library | SKSE64, SkyUI, **JContainers**, **PO3**, UIExtensions, Address Library |
| PO3 (Papyrus Extender) | **Required** — nearby-NPC scans, hit events | **Required** — discovery, death cleanup |
| Recommended (both) | BodySlide (body morphs) · Papyrus Tweaks NG (script performance) | BodySlide · Papyrus Tweaks NG |
| Data storage | StorageUtil / JsonUtil (PapyrusUtil) | JContainers |
| SexLab | ✅ SLSO, SexLab P+ cum events, hentairim tags, **Devious Devices** chastity awareness | ✅ SLSO |
| OStim | ✅ player **and NPC↔NPC** | ✅ player **and NPC↔NPC** |
| Estrus family | ✅ Defers its cycle to active **Estrus Chaurus / Spider / Dwemer** pregnancies | ❌ |
| DHLP | ✅ Respects & emits `dhlp-Suspend` / `dhlp-Resume` around birth | ❌ |
| Other | Bathing in Skyrim, SlaveTats (optional) | DAR/OAR "Immersive Effects" add-ons |

## Which should you run?

There is no universal "better." A reasonable way to choose:

- **Choose Beeing Female NG if** you want the deepest simulation — menstrual hygiene, PMS, detailed miscarriage, tattoos, multiple body-scaling backends, Devious Devices integration, or an INI-driven add-on ecosystem — and you don't mind a larger feature surface.
- **Choose Fertility Mode Reloaded if** you want a leaner, bounded system with a hard tracked-actor cap, the class-based child-training progression, or tight DAR/OAR animation integration — and you're comfortable with its JContainers + UIExtensions dependency stack.
- **Don't run both.** They track the same actors and both drive belly scaling; pick one per playthrough.

## Sources & further reading

- Beeing Female NG: [Nexus](https://www.nexusmods.com/skyrimspecialedition/mods/168434) · [GitHub](https://github.com/crajjjj/Beeing-Female-NG) (GPL-3.0) · these docs.
- Fertility Mode Reloaded: [Nexus](https://www.nexusmods.com/skyrimspecialedition/mods/165569).
- powerofthree's Papyrus Extender: [Nexus](https://www.nexusmods.com/skyrimspecialedition/mods/22854).

For BF NG specifically, see [Getting Started](players/getting-started.md), [NPC Pregnancy & Couples](players/npc-pregnancy.md), and the author-facing [Add-on Framework](authors/add-on-framework.md) and [StorageUtil & State Data](authors/state-data.md).
