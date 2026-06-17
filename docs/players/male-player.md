# Playing as a Male Character

Beeing Female simulates a **female** reproductive cycle, so a male character does not menstruate, ovulate, or get pregnant. Instead the mod tracks you as a potential **father**: your sperm can inseminate tracked female NPCs, and the children that result are theirs to carry and raise. This page covers everything that applies when the player is male.

Your character's sex is detected automatically. A male character is given the male tracking effect (virility) instead of the female cycle effect; if you change sex mid-game, the mod swaps which effect applies on the next update.

## Virility (sperm potency)

When you have sex, the amount of viable sperm you deposit depends on your **virility**:

- Virility starts at 100% and drops after each act, recovering over time (default **24 hours** to full potency, set by *Male Virility Recovery* on the MCM Male page).
- The deposited sperm is stored on the female and stays viable for the *Sperm Duration* (default 2 days), then washes out — faster with bathing/water.
- **Lore-friendly mode** (on by default) blocks conception between incompatible species: the sperm is stored but cannot lead to pregnancy.

The full conception flow, sperm settings, and father-selection weighting are described on [Cycle, Sex & Conception](cycle-and-conception.md).

## Fathering children

For a male player to actually produce children, the **mother** must be tracked and able to conceive and give birth:

1. Enable **NPCs Can Become Pregnant** and **NPC Born Child** (see [NPC Pregnancy & Couples](npc-pregnancy.md)).
2. Have sex with a tracked female (or use the [NPC auto-insemination / Couples system](npc-pregnancy.md#npc-auto-insemination-couples-system) to let it happen in the background).
3. If conception succeeds during her fertile window, she becomes pregnant and her pregnancy progresses on game time like any tracked female.

When the baby is born, what happens next depends on the **Baby Spawn (NPC)** mode on the MCM Children page (none / actor / item-actor / gem).

## Baby items and your NPC partners

When the baby spawn mode is **Item/Actor**, the newborn is an inventory item the mother carries. With **you as the recorded father**, the NPC mother will grow and hatch that baby — while it is simply carried (equipped or in her inventory) and she is loaded near you — into **her own child, spawned next to her**.

That child is a normal NPC living with its mother:

- It is **not** a player follower and **not** flagged for Hearthfire adoption — it stays with the mother.
- It still grows and behaves like any other child, and because you are its biological father it carries the player surname.
- It is the mother who carries the baby; you do not need to take or hold the item yourself. A baby whose father is *not* the player never hatches this way — that item stays an item.

See [Baby Items Growing to Children](children.md#baby-items-growing-to-children) for the full hatch rules (carrying vs. equipping, twins, and what happens if a baby item is sold or destroyed).

> If you want a child that lives and travels with **you** instead of its mother, play (or temporarily switch to) a female character and carry the baby item yourself — player-carried baby items hatch into your own followable, adoptable children.

## What you will not see

As a male character you do not get the female-only systems:

- No menstrual cycle, ovulation, contraception, or pregnancy states, and none of the cycle/pregnancy [HUD widgets](hud-widgets.md).
- No belly/breast scaling, labor, or birth on your own character.
- The PMS, hygiene-item, and abortus systems do not apply to you.

## MCM Settings (Male Page)

| Setting | Default | What It Does |
|---------|---------|-------------|
| Male Virility Recovery | 24 hours | Time for a male to return to full potency after sex |
| Creature Sperm | Off | Whether creatures (and you, against creature partners) can deposit viable sperm |

Conception chances, sperm duration, and lore-friendly mode live on the **Impregnate** page — see [Cycle, Sex & Conception](cycle-and-conception.md) and the [MCM Reference](mcm-reference.md).
