# Pregnancy & Birth

## Pregnancy

Pregnancy has three trimesters, each defaulting to 10 in-game days (30 days total).

| Trimester | Default | Visual Changes |
|-----------|---------|---------------|
| First (State 4) | 10 days | Slight belly growth |
| Second (State 5) | 10 days | Noticeable belly and breast growth |
| Third (State 6) | 10 days | Full belly, maximum scaling |

### Belly & Breast Scaling

How the growth is *displayed* is picked on the **Pregnancy page → Visual scaling type**:

| Type | How it works | Needs |
|------|--------------|-------|
| Node scaling (two variants) | Scales the `NPC Belly` / breast skeleton bones | XPMSSE skeleton |
| Weight gain | Raises the actor's weight slider | -- |
| SLIF | Hands scaling to SexLab Inflation Framework | SLIF |
| BodyMorph | Applies BodySlide morphs via RaceMenu/NiOverride | RaceMenu, body meshes built with **Build Morphs** checked |

**BodyMorph profiles.** The BodyMorph type reads its slider set from an INI profile chosen right below the scaling type (**"Body morph profile"**). Profiles live in `Data/BeeingFemale/BodyMorph/`:

- `default.ini` -- the classic Beeing Female sliders (`PregnancyBelly`, `BreastsSH`, `BreastsNewSH`); works everywhere
- `CBBE 3BA.ini` -- a blend tuned for CBBE / 3BA bodies (fuller, heavier breast shape)
- `BHUNP.ini` -- for BHUNP, which uses `BreastsSSH` instead of the CBBE breast sliders

Each profile lists up to 16 sliders per section with the value applied at full scale (negative values allowed), so you can edit them -- or copy one to a new `.ini` and build your own; new files appear in the MCM menu automatically. The MCM *Maximum belly/breast size* sliders multiply on top of the profile values. Other mods can ship their own profiles the same way (BF UBE Support ships `UBE.ini`, for example).

Only the `[Belly]` and `[Breasts]` sections exist -- they are the two channels the pregnancy simulation drives. Sliders for other body parts (hips, butt, ...) can be listed under `[Belly]` to grow with it; if you think a region deserves its own growth channel, [request it on GitHub](https://github.com/crajjjj/Beeing-Female-NG/issues) rather than editing scripts -- channels are added centrally so all profiles keep working (see the [author guide](../authors/add-on-framework.md#bodymorph-slider-profiles)).

> If the belly doesn't grow in BodyMorph mode, your body meshes were built without morph data -- rebuild in BodySlide with **Build Morphs** checked.

### Baby Health

The unborn baby has a health value (0--100, starting at 100). It is reduced by **combat damage** taken by the mother while pregnant. If health drops too low and the miscarriage system is enabled, a miscarriage may occur.

**Restoring baby health:** drink a **Restore Health potion** (stronger = more healing), **sleep**, or **sit/rest** in furniture; health also **regenerates slowly on its own** over time (faster in later trimesters). Drinking a *harmful/poison* potion hurts the baby instead. Note: once a miscarriage has actually started, healing no longer works -- act *before* health gets critically low.

### Miscarriage

When enabled (MCM toggle), low baby health can trigger miscarriage at any point during pregnancy. The chance increases as health decreases. Miscarriage ends the pregnancy and returns the mother to the normal cycle.

**Post-miscarriage complications (player only).** After a miscarriage or abortion, the game rolls for aftermath conditions whose likelihood depends on the type of loss (an incomplete abortion is the most dangerous, at roughly a 60% infection chance):

- **Infection** -- an escalating affliction that deals steadily increasing health damage to the **mother** every game-hour until treated. **Drink any healing potion to cure it.** It also clears on its own at the next cycle, or if she becomes pregnant again.
- **Fever** -- a companion affliction rolled the same way.

These damage the mother *after* the pregnancy has ended -- they are not a cause of unborn baby health loss. Higher difficulty increases the damage; on the *Painless* difficulty there is none.

### Switching Babies ("NTR")

An optional, **off-by-default** mechanic: while a female is *already* pregnant, sex with another male can reassign an unborn child's father to that new male. The pregnancy does not restart -- only the recorded father changes, which is what determines the child's inherited race and traits at birth. The roll is repeated on each pregnancy tick throughout all three trimesters, but never once labor has begun.

It is gated by **two** independent switches that must *both* be on:

1. The MCM toggle **"Allow switching babies in belly"** (Pregnancy page), default **off**. With it off, every add-on's swap setting is ignored.
2. An installed add-on that marks a male (by actor or race) as able to swap -- `Allow_NTR_baby` with a non-zero chance (see the [author guide](../authors/add-on-framework.md#switching-babies-ntr)). With the toggle on but no such add-on present, nothing happens.

When both are active, each eligible male's configured chance is rolled per child, *reduced* by the current father's own swap setting -- so a father configured the same way "defends" his child. Estrus Chaurus impregnation always takes priority and is never overridden.

## Baby Sex

A baby's sex is **not** fixed in advance -- it is a weighted random roll made **at the moment of birth**, rolled independently for each child. There is no way to know it while pregnant (no in-game ultrasound). By default there is a **53% chance of a boy** (so 47% of a girl).

**Where to change it:** MCM → **Beeing Female → Pregnancy page → "Child sex determinator"**. The slider is the **percent chance the baby is a boy**:

- `100` -- always a boy
- `0` -- always a girl
- `53` -- the default

> The same roll applies to **both** the **Actor** and **Item/Actor** baby-spawn modes (Children page). **Gem** mode produces a soul gem rather than a child, so no sex is decided there. (The in-game slider tooltip still says "Actor only," but that text is outdated — current versions roll Item/Actor babies the same way.)

The chance is read from the **father**, so a mod author can bias or fix it for a specific NPC or race with the `ProbChildSexDetermMale` add-on key (see the [author guide](../authors/add-on-framework.md#child-sex)).

Once born, the sex is permanent: it is announced in the birth message and shown afterward in the **MCM Children** tab / the child's info window. For *Item* spawn mode, the announced sex is what the baby item hatches into.

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

Born a child? See how they grow up in [Children](children.md).
