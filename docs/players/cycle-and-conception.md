# Cycle, Sex & Conception

This page covers everything from the menstrual cycle through the moment of conception: how the cycle phases work, how sperm gets deposited, how contraception and wash-out fight it, and the two-gate conception roll that decides whether a pregnancy starts.

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

Playing a **male** character? Virility and fathering children work a little differently — see [Playing as a Male Character](male-player.md).

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

At 98% contraception, each sperm entry has roughly a 98% chance of being eliminated per tick. However, this is **per entry, per tick** -- with multiple donors or high sperm amounts, some may survive a single check. The check runs once per cycle update (roughly hourly in game time), so surviving sperm will face additional checks on subsequent ticks.

!!! important
    Contraception and the "Can get pregnant this cycle" flag are independent systems. The cycle flag is rolled once at the start of each cycle and determines whether conception checks happen at all. If the flag is off, you cannot get pregnant regardless of sperm. If it is on, contraception must defeat the sperm probabilistically.

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

## Conception

Conception is only checked when:

- There is viable sperm present (i.e. not washed out or killed by contraception)
- The female is in her **fertile window** -- the **ovulation** phase, or the early **luteal** phase at a declining chance (or any phase, if an addon enables any-period conception)
- **Both** conception gates below pass

### How the Roll Works

Conception uses **two independent gates**, not a single roll:

**Gate 1 -- "Is this a fertile cycle?"** Rolled **once per cycle**, at the cycle boundary (when menstruation ends and the follicular phase begins). This sets the *Can get pregnant this cycle* flag. The chance is:

| Who | Default Chance |
|-----|---------------|
| Player | 40% |
| Followers | 40% |
| Other NPCs | 40% |

These can be adjusted in the MCM and scaled per-actor or per-race via addons. If this roll fails, **no conception is possible for the whole cycle** -- regardless of how much sperm is present -- and it is **not** re-rolled until the next cycle.

**Gate 2 -- the fertile-window roll.** If the cycle is fertile, the game then rolls **on each cycle update** while she is in the fertile window. At the ovulation peak this is roughly a **44%** chance per update; in the luteal phase it starts high and declines toward zero. Because the window spans many updates, these per-update chances compound over the window. When a roll passes, conception succeeds **only if viable sperm survives** the contraception sperm-kill (see [Contraception](#contraception) above).

The two dials therefore act on different stages: **ConceiveChance** governs Gate 1 (how often a cycle is fertile at all), while **contraception** acts after Gate 2 (by killing the sperm). They are independent.

If multiple males have deposited sperm, the father is chosen randomly, weighted by how much sperm each has.

### Fertility Tonics

Fertility Tonics are the counterpart to contraception: drinking one raises your conception odds for a few in-game days, then fades. Two strengths exist, and like the contraception fluids they can be crafted or found on merchants/loot.

- **Mild tonic** -- nudges the **fertile-window roll (Gate 2)**, strongest during **ovulation** (a smaller nudge in luteal). It also gently nudges **Gate 1**: if the current cycle rolled infertile, drinking it grants one extra fertility roll at your normal **ConceiveChance** (about 40%), so an infertile cycle gets a chance -- but no guarantee -- to flip fertile (roughly 40% becomes ~64% over the cycle). Unlike the potent tonic it cannot *force* fertility, and it does nothing if the cycle is already fertile.
- **Potent tonic** -- applies the same Gate 2 boost **and** forces the current cycle to count as fertile (Gate 1), so a cycle that rolled infertile becomes fertile for the rest of its window. Drink it before or during ovulation; it does nothing once the fertile window has already passed.
- Either way the boost is **temporary** -- it lasts a few in-game days at full strength, then wears off; the forced fertile flag also clears at the next cycle boundary.
- Tonics **stack with diminishing returns** up to an internal ceiling -- re-drinking soon after a dose adds only a little and refreshes the timer rather than pushing the chance ever higher.
- Neither tonic **guarantees** pregnancy, and neither cancels contraception -- if you are actively dosed, that still kills the sperm first, so let it lapse before relying on a tonic.
- While a tonic is active, the MCM **Info** page shows its approximate ovulation conception chance.

### Twins and Multiples

After conception, the system may roll for multiples if total sperm is high enough. The maximum is 3 babies per pregnancy by default.

---

Conceived? Continue to [Pregnancy & Birth](pregnancy-and-birth.md).
