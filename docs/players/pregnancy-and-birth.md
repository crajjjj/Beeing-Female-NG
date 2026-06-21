# Pregnancy & Birth

## Pregnancy

Pregnancy has three trimesters, each defaulting to 10 in-game days (30 days total).

| Trimester | Default | Visual Changes |
|-----------|---------|---------------|
| First (State 4) | 10 days | Slight belly growth |
| Second (State 5) | 10 days | Noticeable belly and breast growth |
| Third (State 6) | 10 days | Full belly, maximum scaling |

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
