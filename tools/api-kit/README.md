# Beeing Female NG integration kit

Everything another mod needs to talk to Beeing Female NG, and nothing else. Shipped as
`BeeingFemaleNG-API-<version>+.zip` (built with `python tools/pack-api-kit.py`); the same
files live in the BF NG repo, so you can also copy them from there.

The **`+`** means what it looks like: the kit describes that BF NG version *and later*. The
mod-event commands and StorageUtil keys are append-only, so a kit stays valid for every newer
release. `VERSIONS.txt` carries the numbers to gate an optional integration on.

```
README.md                  this file
VERSIONS.txt               the versions to gate on
examples/BFConsumer.psc    a complete, compile-verified consumer (needs no BF sources)
examples/AddOn *.ini       add-on INI templates (race / actor / adult grow-up)
papyrus/*.psc              BF's own sources - only for script add-ons, see below
```

## Start here: most integrations need none of these files

BF NG's API is **mod events plus StorageUtil keys**. Both are reachable with vanilla Papyrus
and PapyrusUtil, which your mod already has, so the common integration adds **no build
dependency on BF at all** - nothing to copy, nothing in your import path, no load-order
requirement, and your script compiles on a machine where BF is not installed.

`examples/BFConsumer.psc` is exactly that, and it compiles against nothing but PapyrusUtil and
the vanilla sources. Start from it.

```papyrus
; listen for BF telling you something happened
RegisterForModEvent("BeeingFemaleConception", "OnBFConception")
RegisterForModEvent("BeeingFemaleLabor", "OnBFLabor")

; tell BF to do something (SendModEvent is a vanilla Form method)
FemaleActor.SendModEvent("BeeingFemale", "AddSperm", MaleActor.GetFormID())
FemaleActor.SendModEvent("BeeingFemale", "AddContraception", 100)

; read her state (PapyrusUtil - no BF scripts involved)
int iState = StorageUtil.GetIntValue(FemaleActor, "FW.CurrentState")
```

Detect BF the same dependency-free way, and treat "absent" as "skip the integration":

```papyrus
bool Function IsBFInstalled() global
	return Game.GetModByName("BeeingFemale.esm") != 255
EndFunction
```

The full command list, the emitted events and their payloads, and every `FW.` StorageUtil key
are in the docs linked below - that reference is the actual API surface, not these files.

## Extending BF without scripting: add-on INIs

Race, actor, cycle-magic-effect and misc add-ons are **INI files** dropped in
`Data/BeeingFemale/AddOn/`, paired with forms in your own ESP. No code, no compiling, and BF
picks them up on load. The three templates in `examples/` are the shipped, fully commented
references - copy one and edit it.

This is the right extension point for per-race or per-NPC pregnancy tuning, custom baby items,
assigning spells to cycle states, and the child grow-up pool.

## Papyrus (script add-ons only)

`papyrus/` holds BF's own sources, and you need them **only** if you are writing a *script*
add-on - a quest script that extends `FWAddOn_Misc`, `FWAddOn_Race` or
`FWAddOn_CycleMagicEffect` to receive BF's hooks (`OnGiveBirthStart`, `OnLaborPain`,
`OnBabySpawn`, `OnUpdateFunction`, ...). Everything else on this page is a better first choice.

Be aware of what this costs, because it is not like a normal SDK header:

- **It is the whole cluster, not a shim.** BF's scripts are mutually referential, so the
  compile closure of any one add-on base class is ~34 sources - all of `papyrus/`. There is no
  smaller subset; a trimmed copy will not compile.
- **It pulls BF's own optional dependencies into your import path.** BF holds typed properties
  for the mods it integrates with, and Papyrus resolves property types at compile time whether
  or not the feature is used. To compile `papyrus/` you need sources for: PapyrusUtil, SkyUI
  SDK, RaceMenu (NiOverride), JContainers, SexLab, Devious Devices, OStim, SlaveTats, FNIS,
  MFG Fix (`MfgConsoleFuncExt`), PO3 Papyrus Extender, ConsoleUtil. BF NG's own
  `skyrimse.ppj` lists the exact set it builds against.
- **These are sources, not a stable ABI.** Adding a parameter to a public BF function breaks
  every pre-compiled caller, add-ons included. Rebuild your add-on against the BF version you
  ship for, and gate on `FWVersion.GetVersion()`.

The same sources also ship inside the mod itself (`Data/Source/Scripts`), so an add-on author
who already has BF installed can point at those instead of this folder.

## Where the documentation is

- Author guide: <https://crajjjj.github.io/Beeing-Female-NG/authors/overview/>
- **ModEvents** (the command list and emitted payloads):
  <https://crajjjj.github.io/Beeing-Female-NG/authors/modevents/>
- **StorageUtil & state data** (every `FW.` key, cycle state numbers):
  <https://crajjjj.github.io/Beeing-Female-NG/authors/state-data/>
- Add-on framework (INI keys):
  <https://crajjjj.github.io/Beeing-Female-NG/authors/add-on-framework/>
- Pregnancy ranks, item slots, building from source: same site.
- Source and issues: <https://github.com/crajjjj/Beeing-Female-NG>

Beeing Female NG is GPL-3.0. Integrating over mod events creates no licensing obligation;
copying BF source into your mod does.
