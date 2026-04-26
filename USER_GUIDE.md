# Beeing Female NG -- User Guide

- [The Menstrual Cycle](#the-menstrual-cycle)
- [Insemination](#insemination)
- [Contraception](#contraception)
- [Conception](#conception)
- [Pregnancy](#pregnancy)
- [Birth](#birth)
- [Children](#children)
- [HUD Widgets](#hud-widgets)
- [SlaveTats Integration](#slavetats-integration)
- [NPC Pregnancy](#npc-pregnancy)
- [Integration with Other Mods](#integration-with-other-mods)
- [MCM Pages at a Glance](#mcm-pages-at-a-glance)

---

## The Menstrual Cycle

Every tracked female goes through a repeating cycle with four phases:

| Phase | Default Duration | What Happens |
|-------|-----------------|--------------|
| Follicular | 5 days | Early cycle, low fertility |
| Ovulation | 2 days | Peak fertility -- conception is possible |
| Luteal | 5 days | Post-ovulation, PMS may trigger in the last 25% |
| Menstruation | 2 days | Bleeding phase, hygiene items matter |

The full cycle takes about 14 in-game days by default. Each phase duration can be adjusted in the MCM under the Cycle page.

### PMS

During the late luteal or menstruation phase there is a chance (default 25%) that PMS effects kick in. There are 10 possible effects ranging from headaches and fatigue to mood swings. Only one PMS type is active at a time and it clears when the next phase begins.

---

## Insemination

Sperm is deposited during sex events (SexLab or OStim) or manually via mod events. Here is what happens:

1. The male's **virility** determines sperm amount. Virility starts at 100% and drops after sex, recovering over time (default 24 hours to full recovery).
2. **Lore-friendly mode** (on by default) blocks conception between incompatible species -- the sperm is stored but cannot lead to pregnancy.
3. Sperm stays viable for a limited time (default 2 in-game days).
4. Freshly deposited sperm needs about 6 in-game hours to "travel" before it can participate in conception or be washed out.

### MCM Settings

| Setting | Default | What It Does |
|---------|---------|-------------|
| Sperm Duration | 2 days | How long sperm remains viable |
| Male Virility Recovery | 24 hours | Time for a male to return to full potency |
| Creature Sperm | Off | Whether creatures can deposit viable sperm |
| Lore Friendly | On | Only allow same-species conception |
| Wash-Out Delay | 6 hours | How long before sperm "arrives" and can be affected |

---

## Contraception

Contraception is a percentage (0--98%) that reduces your chance of getting pregnant. It comes from consumable pills found on merchants or looted from NPCs.

- **Taking a pill** increases your contraception level.
- **Contraception decays** over time (typically 1--2 in-game days).
- **Maximum is 98%** -- there is always a small chance.
- **NPCs auto-consume pills** if they have them in inventory.

### How Contraception Actually Works

Contraception does **not** directly block pregnancy. Instead, it attacks stored sperm each time a conception check runs:

1. For each sperm entry, the system rolls a random threshold (varies between 1--100).
2. If your contraception level meets or exceeds the threshold, that sperm entry is killed.
3. If it misses the kill but contraception is above 20%, it still reduces the sperm amount slightly.
4. If all sperm is reduced below the minimum threshold, conception cannot occur.

At 98% contraception, each sperm entry has roughly a 96% chance of being eliminated per tick. However, this is **per entry, per tick** -- with multiple donors or high sperm amounts, some may survive a single check. The check runs once per cycle update (roughly hourly in game time), so surviving sperm will face additional checks on subsequent ticks.

**Important:** Contraception and the "Can get pregnant this cycle" flag are independent systems. The cycle flag is rolled once at the start of each cycle and determines whether conception checks happen at all. If the flag is off, you cannot get pregnant regardless of sperm. If it is on, contraception must defeat the sperm probabilistically.

**Tips for maximum protection:**
- Keep contraception topped up by taking pills regularly (before the effect expires).
- Use **Wash-Out Fluids** to directly remove sperm -- this stacks with contraception.
- At 98%, pregnancy is rare but not impossible. This is by design.

### Washing Out Sperm

You can remove sperm before it leads to conception:

| Method | Default Chance |
|--------|---------------|
| No assistance | 0% |
| Swimming / water | 2% |
| Anti-sperm fluid (potion) | 75% |
| Bathing in Skyrim (mod) | Uses WashOutSperm integration |

---

## Conception

Conception is only checked when:
- There is viable sperm present
- The female is in the **ovulation** phase (or an addon allows any-period conception)
- The conception roll passes

### How the Roll Works

Each eligible cycle, the game rolls against the conception chance:

| Who | Default Chance |
|-----|---------------|
| Player | 40% |
| Followers | 40% |
| Other NPCs | 40% |

These can be adjusted per-actor or per-race via addons. Contraception reduces the effective chance.

If multiple males have deposited sperm, the father is chosen randomly, weighted by how much sperm each has.

### Twins and Multiples

After conception, the system may roll for multiples if total sperm is high enough. The maximum is 3 babies per pregnancy by default.

---

## Pregnancy

Pregnancy has three trimesters, each defaulting to 10 in-game days (30 days total).

| Trimester | Default | Visual Changes |
|-----------|---------|---------------|
| First (State 4) | 10 days | Slight belly growth |
| Second (State 5) | 10 days | Noticeable belly and breast growth |
| Third (State 6) | 10 days | Full belly, maximum scaling |

### Baby Health

The unborn baby has a health value (0--100, starting at 100). It can be reduced by:
- **Combat damage** to the mother
- **Infection spells** (curable by drinking healing potions)

If health drops too low and the miscarriage system is enabled, a miscarriage may occur.

### Miscarriage

When enabled (MCM toggle), low baby health can trigger miscarriage at any point during pregnancy. The chance increases as health decreases. Miscarriage ends the pregnancy and returns the mother to the normal cycle.

---

## Birth

When the third trimester ends, labor begins (State 7). Birth is a multi-stage process:

1. **Early contractions** -- mild pain
2. **Opening contractions** -- increasing pain and damage
3. **Pushing** -- strongest pain, each baby is delivered one at a time
4. **Afterpains** -- final stage before recovery

For each child, a health check determines if the birth is successful:
- **Live birth** -- a child actor is spawned in the world
- **Stillbirth** -- the child is not spawned (only if miscarriage system is enabled)

### Baby Spawn Modes

| Mode | Player Default | Description |
|------|---------------|-------------|
| None (0) | -- | No child spawned |
| Actor (1) | Yes | A child NPC is placed near the mother |
| Item/Actor (2) | -- | Items for creatures, actors for humanoids |
| Gem (3) | -- | A soul gem item is given |

NPCs have their own spawn mode setting.

### After Birth

After all children are delivered, the mother enters the **Replenish** phase (State 8, default 30 days) before returning to the normal menstrual cycle.

---

## Children

Spawned children are interactive NPCs that can:
- **Follow** you, **wait**, or **go home** via dialogue
- **Grow** over time from baby to full size
- **Learn spells** from spell books given to them
- **Level up** as the player levels (capped at player level or the configured max)

Children inherit their race from the father (configurable per-race via addons) and are named randomly from the name database in `Data/BeeingFemale/Names/`.

### Growth System

Children start small and grow linearly to their final size over a configurable period.

- **Starting scale**: small baby size (set per-race via addon, typically ~0.3--0.6)
- **Final scale**: adult size (set per-race via addon, typically 1.0)
- **Growth duration**: controlled by the MCM slider "Mature Time in Days" (default 50 days), scaled by the addon `MatureTimeScale` multiplier for the parent's race
- Growth is checked every 5 in-game hours
- Once fully grown, the child is registered with SexLab/BF if applicable and stops growing

The growth formula is linear interpolation:

```
current_scale = starting_scale + ((final_scale - starting_scale) / growth_duration) * age_in_days
```

### Baby Items Growing to Children

When the baby spawn mode is set to "Item/Actor" (mode 2), humanoid babies are spawned as inventory items (carried by the mother). For the **player character only**, these baby items will automatically convert into child actor NPCs once the growth time has elapsed. This does not apply to NPC mothers -- their baby items remain as items.

### Child Commands

Talk to a child to give orders:

| Command | What It Does |
|---------|-------------|
| Follow me | Child follows you as a teammate |
| Wait here | Child stays in place |
| Go home | Child returns to their home location |
| Stay close / Stay back | Adjusts follow distance |
| Pick that up | Child loots a nearby container or item |
| Sleep | Child goes to bed if one is nearby |

### MCM Settings (Children Page)

| Setting | Default | What It Does |
|---------|---------|-------------|
| Baby Spawn (Player) | Actor | How babies appear: none, actor, item/actor, or gem |
| Baby Spawn (NPC) | Actor | Same for NPCs |
| Mature Time | 50 days | How long until a child reaches full size |
| Children May Cry | On | Children make crying sounds |
| BabyTracker Tattoos | Off | SlaveTats tally marks for babies born |
| Semen Circle Tattoos | Off | SlaveTats indicator when sperm is present |

---

## HUD Widgets

Beeing Female provides several on-screen widgets. Toggle visibility with the configured hotkey (tap = show 5 seconds, hold = keep visible).

| Widget | Shows |
|--------|-------|
| State | Current cycle/pregnancy phase, progress bar, elapsed time |
| Baby Health | Pregnancy chance (cycle) or unborn health (pregnant) |
| Contraception | Active contraception level and time remaining |
| Panty | Hygiene reminder during menstruation |

Widget layout can be customized via profiles in `Data/BeeingFemale/HUD/`. Copy `default.ini` to create your own layout.

---

## SlaveTats Integration

If SlaveTats and the BabyTracker tattoo pack are installed, two optional tattoo features are available (enable in MCM under Children):

### Baby Tracker Tattoos

Shows tally marks for total babies born. Uses denominations (1, 2, 3, 4, 8, 12) to compose the count. Updates after each birth and when toggling the MCM option.

### Semen Circle Tattoo

Shows a circle tattoo when viable sperm is present. Two variants:
- **Regular circle** -- sperm is inside but not during fertile window
- **Hearts circle** -- sperm is inside during ovulation (conception possible)

The tattoo automatically clears when all sperm expires or is washed out.

---

## NPC Pregnancy

NPCs can go through the same cycle and pregnancy system as the player. Key settings:

| Setting | Default | What It Does |
|---------|---------|-------------|
| NPCs Can Become Pregnant | On | Global toggle |
| NPC Feel Pain | Off | NPCs get pain effects |
| NPC Born Child | On | NPCs actually spawn child actors |
| NPC Have Items | Off | NPCs receive hygiene/contraception items via scripts |

NPCs near the player are scanned periodically and given the cycle tracking spell. Their pregnancies progress in the background based on game time.

### NPC Auto-Insemination (Couples System)

When enabled in MCM (Impregnate page), the mod can automatically inseminate tracked NPCs in the background -- even when the player is not around. This simulates NPCs having an ongoing intimate life with their partners.

**How it works:** Once per in-game day (at a configurable time), the system picks several random tracked females and attempts to inseminate them with a suitable male partner.

**Partner selection is weighted by relationship:**

| Source | Weight | Description |
|--------|--------|-------------|
| Husband | 10x | Vanilla spouse or manually assigned via Couple Widget |
| Affairs | 4x | Assigned via Couple Widget |
| Partners | 2x | Assigned via Couple Widget |
| Last Seen NPCs | 1x | Males the female was recently near (automatic) |

A male is picked randomly from this weighted pool (e.g. a husband is 10 times more likely to be chosen than a random nearby NPC). The system tries up to 3 times to find a valid male.

**A male is valid if:**
- Not in the player's current location
- Not a player follower
- Had sex more than ~7 hours ago (cooldown)
- Relationship rank is neutral or better (not an enemy)
- Not a creature (unless creature sperm is enabled)

**Couple data** is stored in JSON files at `Data/BeeingFemale/Couples/`. Each file is named `ModName_FormID.json` and contains husband, affairs, and partners for one female NPC. You can edit these manually or use the in-game Couple Widget.

### Couple Widget

The Couple Widget is a debug/editing tool for managing NPC relationships in-game. Enable it in MCM under the System page.

| Hotkey | Action |
|--------|--------|
| E (hold 1.5s) | Select a female NPC as subject |
| H (hold 1.5s) | Assign or clear husband |
| G (hold 1.5s) | Add or remove affair partner |
| P (hold 1.5s) | Add or remove regular partner |

The widget auto-detects existing vanilla spouses (relationship rank 4+ or Spouse association).

### Couples Import

You can bulk-import couple data from JSON files via MCM (first page, "Couples Import"). This scans `Data/BeeingFemale/Couples/` and applies stored partner data to matching NPCs.

### MCM Settings (Impregnate Page)

| Setting | Default | What It Does |
|---------|---------|-------------|
| Active | Off | Master toggle for NPC auto-insemination |
| Husband | On | Include husbands in partner pool |
| Affairs | On | Include affairs in partner pool |
| Partners | On | Include regular partners in partner pool |
| Last Seen NPCs | Off | Include recently nearby males |
| Time | Configurable | What time of day the daily check runs |
| Count | 3 | How many NPCs to attempt per daily check |

---

## Integration with Other Mods

### SexLab

Hooks orgasm events to add sperm. Supports both legacy SexLab and SexLab P+ (2.17.1+). Recognizes vaginal/anal/oral tags and Devious Devices keywords (chastity belts block insemination).

### OStim

Uses OStim's Fertility Mode compatibility event to add sperm on orgasm. Requires OStim API 23+. Condom detection is supported.

### Bathing in Skyrim

Bathing triggers sperm wash-out using the configured fluid wash-out chance.

---

## MCM Pages at a Glance

| Page | What You Configure |
|------|--------------------|
| Settings | Core toggles, message mode, hotkeys |
| Cycle | Phase durations, PMS chance |
| Pregnancy | Trimester durations, belly/breast scaling, miscarriage |
| Impregnate | Conception chances, sperm settings, lore-friendly, NPC impregnation |
| Male | Virility recovery, creature sperm |
| Children | Baby spawn mode, growth settings, SlaveTats tattoos |
| AddOn | Enable/disable loaded addons |
| Info | View current state, sperm donors, pregnancy status |
| Cheat | Force state changes, debug tools |
| System | Mod reset, profile save/load |
