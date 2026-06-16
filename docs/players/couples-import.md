# Couples Import

Beeing Female NG can auto-import sperm donors from JSON couple files and apply them to the matching female actor. This is the background system behind the [NPC Couples feature](npc-pregnancy.md#npc-auto-insemination-couples-system).

## How it works

- It scans `Data/BeeingFemale/Couples/*.json` (via `FWUtility.GetFileNames("Couples","json")`).
- Each filename should be `ModName_FormHex.json`. The split uses the last `_`, so mod names may contain underscores.
- The female actor is resolved from the filename as `ModName:FormHex`.
- Donors are pulled from the JSON keys `husband` (single form), `partners` (form list), and `affairs` (form list).
- One donor is chosen at random and applied via `SendModEvent("BeeingFemale", "AddSpermImpregnate", donorFormID)`.

## How to run it

- MCM: First page, `Couples Import`.

## Notes

- The `.json` extension check is case-insensitive.
- Errors are logged with `FW_log.WriteLog` if the file name is invalid, the female cannot be resolved, or no donor is found.
- Female validation rejection codes (from `System.IsValidateFemaleActor`):
    - `-10`: actor is `None` or has no `ActorBase`.
    - `-3`: actor sex is male.
    - `-2`: actor is dead OR has ghost keyword (when ghosts are not allowed).
    - `-1`: actor is summoned (when summoned females aren't allowed) OR in a forbidden faction/keyword.
    - `-5`: actor is the player but player relevance is disabled.
    - `-6`: actor is a follower but follower relevance is disabled.
    - `-7`: actor is an NPC (non-follower) but NPC relevance is disabled.
    - `-11`: actor is a creature and creature sperm is disabled.
    - `-8`: actor is a child race or in forbidden races.
    - `-9`: actor is an elder race and elder females are disabled.
