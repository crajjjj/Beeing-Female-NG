# Pregnancy Ranks (Factions)

Tracked actors (those in `FW.SavedNPCs`) get their `ParentFaction` rank updated when their state changes. You can read this rank to drive animations (OAR/DAR conditions) or other external logic without any scripting.

- Rank is set to the actor's current `FW.CurrentState` value.
- Recovery (`FW.CurrentState` = `8`) is mapped to `-1` in the faction rank.
- If no valid state is present, rank is set to `-2`.

Rank (as read from `ParentFaction`) — Description — State ID:

| Rank | Description | State ID |
|------|-------------|----------|
| `-1` | Replenish (recovery) | `8` |
| `0` | Follicular | `0` |
| `1` | Ovulation | `1` |
| `2` | Luteal | `2` |
| `3` | Menstruation | `3` |
| `4` | 1st Trimester | `4` |
| `5` | 2nd Trimester | `5` |
| `6` | 3rd Trimester | `6` |
| `7` | Labor Pains | `7` |

Papyrus example:

```papyrus
Faction ParentFaction = Game.GetFormFromFile(0x008448, "BeeingFemale.esm") as Faction
int state = ParentFaction.GetFactionRank(SomeActor)
```

!!! tip
    This is exactly how the bundled P.A.I.A patches gate their pregnant idles — e.g. "rank >= 5" plays a 2nd-trimester-onward animation. See [Add-on Framework → Bundled Optional Patches](add-on-framework.md#bundled-optional-patches).
