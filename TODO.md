# Beeing Female NG — TODO

## Open

_(none)_

## Resolved / not needed

- **Grown-up adult protection — global toggle, default ON**
  Done. Single global add-on key `Global_ProtectGrownAdult` (INI-only, no MCM,
  no per-actor/race): **matured adults are Protected by default** (survive combat
  like followers); set `Global_ProtectGrownAdult=false` to make them killable.
  Resolved by `FWAddOnManager.ShouldProtectGrownAdult` and applied in
  `FWSystem.ApplyAdultFactions` (both grow-up paths). `SetProtected` is a
  base-level flag, so the apply site **skips any adult whose base is shared with
  a living parent** (the parent-clone fallback when no dedicated adult base
  exists) -- otherwise it would flip protection on the parent and same-base NPCs.
