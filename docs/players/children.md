# Children

Spawned children are interactive NPCs that can:

- **Follow** you, **wait**, or **go home** via dialogue
- **Grow** over time from baby to full size
- **Learn spells** from spell books given to them
- **Level up** as the player levels (capped at player level or the configured max)

Children inherit their race from the father (configurable per-race via addons) and are named randomly from the name database in `Data/BeeingFemale/Names/`.

## Growth System

Children start small and grow linearly to their final size over a configurable period.

- **Starting scale**: small baby size (set per-race via addon, typically ~0.3--0.6)
- **Final scale**: full size (set per-race via addon, typically 1.0)
- **Growth duration**: controlled by the MCM slider "Mature Time in Days" (default 50 days), scaled by the addon `MatureTimeScale` multiplier for the parent's race
- Growth is checked every 5 in-game hours
- Once fully grown, the child is registered with SexLab/BF if applicable and stops growing
- **Tracking**: the MCM Children tab shows each child's remaining time to maturity next to their name ("Grown" once they reach full size, their current location once they have grown into an adult), and the child's info window shows their age in days

The growth formula is linear interpolation:

```
current_scale = starting_scale + ((final_scale - starting_scale) / growth_duration) * age_in_days
```

## Scale Growth vs. Model Appearance

Growth in Beeing Female's **core** is **scale-based** -- on its own the mod only changes the child's size over time, not its underlying actor model. Visual changes to the model itself come from the **add-ons and features described below** (staged child model packs, and the grow-into-adults option). What the child looks like as it grows depends on which actor base was used at birth:

- **With a child model pack** (BFACCA_SE_Opt, BFASE_RSChildren_SE_Opt, or similar): the child is spawned using a proper child-race actor base from the pack. These packs are designed so that at full scale the child looks appropriately grown. Some packs provide staged models that swap appearance at growth milestones.

- **Without a child model pack**: the mod falls back to using the parent's adult actor base scaled down small. As the child grows, the scale increases and at scale 1.0 they look like a normal adult NPC. This works but the child will look like a small adult during the growth period rather than an actual child.

- **With the base BeeingFemale.esm fallback actors**: the ESP ships default child actor bases (child-race NPCs). These will always look like children regardless of scale -- reaching scale 1.0 means a normal-sized child, not an adult. On their own they will **not** visually transform into adults -- for that, see "Growing Into Adults" below.

If you want children that visibly grow from child to adult appearance, install a child model addon pack and/or enable the grow-up feature described below. Without either, the growth system only affects the actor's scale, not their visual model.

## Growing Into Adults

With **"Children grow into adults"** enabled on the MCM Children page (off by default), a child that finishes growing becomes a real adult NPC instead of staying a child forever. What happens at that moment depends on what the child looks like:

- **Children using an adult-race base** (the "small adult" fallback case above) simply graduate in place: the same actor keeps their name, inventory, and relationships. They stop being adoptable, and player children become potential followers.
- **Children using a real child-race model** (child model packs) are replaced by a new adult NPC at the same spot. Their name, inventory, and family relationships carry over; the child actor is removed.

Where the adult's appearance comes from:

- The shipped **"BF Adult Pack"** add-on (`Data/BeeingFemale/AddOn/Default Adult Actors.ini` plus the ESL-flagged `BeeingFemaleAdultPack.esp`) gives each of the 10 vanilla races 10 dedicated adult bases per sex. They are generated from Skyrim's character-creation presets, so the engine computes their faces live (no FaceGen files, no dark-face bug), but unlike the raw presets they carry proper names, a real class, a race-fitting follower voice, a farm-clothes outfit, and a sandbox AI package so unrecruited adults wander around instead of standing frozen. Delete or disable that INI and the adult will instead be spawned as a copy of their same-sex parent -- but only when that parent uses a generic actor base. The player and unique NPCs (named followers, spouses) are never cloned; if no usable base remains, the transition is skipped and the child stays a grown child (add an `AdultActor_*` INI entry for the race to cover this).
- Add-on authors can supply their own adult bases, voices, and clothing with `AdultActor_Male/Female`, `AdultActorVoice_Male/Female`, and `AdultOutfit_Male/Female` keys in race or actor add-on INIs -- same format as the existing `BabyActor_*` keys, resolving from any installed plugin. Without an outfit key, add-on adults get a basic roughspun tunic. See the [Add-on Framework](../authors/add-on-framework.md#adult-actor-add-ons-grow-up-feature) for the full key reference.

What grown adults can and cannot do:

- **Their upbringing carries over**: skills you trained through the child skill menu (weapons, magic schools, health, sneak, and so on) are applied to the adult, so a child you raised as a fighter grows into one.
- The primary way to manage a grown adult is the **native follower system**: at transition they are added to the vanilla Potential/Current Follower factions, so the standard "Follow me" dialogue works (with a follower-capable voice -- all Adult Pack bases have one), and follower frameworks like NFF/EFF/AFT treat them like any other NPC.
- The BF child command **dialogue** does not carry over: it belongs to the child-race actors, which are replaced at transition (and "small adult" children never had it in the first place). The parent **"order children" powers** still target grown adults of both kinds, but only the teleport orders (come here, go home, meet point) do anything meaningful -- the BF follow order merely marks the adult as a combat teammate, the same limited handling plain-actor children always had. To actually have a grown adult follow you, recruit them with the normal "Follow me" dialogue.
- They no longer count as children for scene-blocking integrations.
- They are **not marriage candidates** unless you set `Global_AllowAdultMarriage=1` in a global add-on INI.

Notes:

- The automatic transition only covers children that finish growing **after** the toggle is enabled. Children that were already fully grown can be converted at any time with the **"Grow up children now"** button on the MCM Cheat page.
- You can also force a **single** child or carried baby item: on the MCM Children page, pick it from the **"Select child / baby"** dropdown and press **"Grow up / hatch now"** -- the child becomes an adult (or the baby item hatches into its recorded child) immediately, skipping the growth timer and all gates. A confirmation is asked first.
- You get a notification when one of your children grows up, and grown adults show their current location in the MCM Children tab.
- To keep a specific NPC's children (or a whole race) from ever growing up, set `GrowUpToAdult=-1` in an actor or race add-on INI -- it overrides the MCM toggle.
- **Protected status:** controlled by `Global_ProtectGrownAdult` in a global add-on INI: `1` = Protected (survive combat like vanilla followers), `-1` = fully killable (clears Protected and Essential), `0` = leave the actor base's own ESP setting untouched (the default — BF doesn't change protection). It's a single **global** setting (protection is a base-level flag and all grown children share one base pool, so per-actor control isn't meaningful). Adults that fall back to a copy of a parent's own actor base are always left untouched, so a parent NPC never inherits the flag.
- Creature children never transition -- they simply reach full size and keep responding to child commands as before.
- If the transition cannot complete (for example, both parents are unavailable and no adult base is configured for the race), the child stays fully grown and the mod retries on later updates -- up to 10 attempts (roughly two game days). After that it gives up and the child permanently remains a fully grown child.

## Baby Items Growing to Children

When the baby spawn mode is set to "Item/Actor" (mode 2), humanoid babies are spawned as inventory items (carried by the mother). Once the growth time has elapsed, the item converts into a child actor NPC. The item is auto-equipped at birth, but it only needs to be **carried** -- simply having it in inventory is enough, and unequipping it does not pause growth.

> **Keep the baby equipped, though.** A baby item only "comes alive" while it is worn. An *equipped* baby drinks milk and makes sounds -- cooing, babbling, giggling, hiccups, crying -- and reacts to the world around it: the weather, nearby objects it likes, fears, or finds surprising, items you pick up, spells you cast, and taking a hit in combat. Stuffed away in your inventory it is silent and inert; it still grows on schedule, but you miss all of that. (Baby sounds require **Children May Cry** on the Children page.)

Who hatches the baby depends on the parents:

- **Player mother:** the baby item hatches into your child.
- **Player father + NPC mother:** if you (a male player) are the recorded father, the NPC mother hatches the baby she is carrying into **her** child, spawned next to her. This child belongs to the mother -- it is a normal NPC, **not** a player follower or an adoptable child. (The mother must be loaded/nearby for it to hatch.)
- **NPC mother + non-player father:** the baby item stays an item -- NPC-only families do not spawn child actors from items.

The baby's identity is fixed at birth: the name and sex announced when the baby is born are the ones the hatched child will have, and the growth clock starts at birth, not when you first equip the item. Twins hatch in birth order, each with their own name and timer. If you **sell, drop, or destroy** a baby item before it hatches, that baby is lost -- no child is produced for the missing item, though a surviving twin still hatches normally. (Baby items born in older versions of the mod predate this tracking -- they still hatch, but with a newly rolled name and sex, the old behavior.)

## Child Commands

Talk to a child to give orders:

| Command | What It Does |
|---------|-------------|
| Follow me | Child follows you as a teammate |
| Wait here | Child stays in place |
| Go home | Child returns to their home location |
| Stay close / Stay back | Adjusts follow distance |
| Pick that up | Child loots a nearby container or item |
| Sleep | Child goes to bed if one is nearby |

## MCM Settings (Children Page)

| Setting | Default | What It Does |
|---------|---------|-------------|
| Baby Spawn (Player) | Actor | How babies appear: none, actor, item/actor, or gem |
| Baby Spawn (NPC) | Actor | Same for NPCs |
| Mature Time | 50 days | How long until a child reaches full size |
| Children grow into adults | Off | At full size, children become real adult NPCs (see "Growing Into Adults") |
| Children May Cry | On | Children make crying sounds |
| BabyTracker Tattoos | Off | SlaveTats tally marks for babies born |
| Semen Circle Tattoos | Off | SlaveTats indicator when sperm is present |
| Womb State Tattoo | Off | SlaveTats womb diagram that follows the whole cycle |

The three tattoo options are covered in detail on the [Tattoos (SlaveTats)](tattoos.md) page.
