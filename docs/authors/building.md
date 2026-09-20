# Building from Source

Beeing Female NG is a hybrid project: a C++ SKSE plugin (built with CommonLibSSE-NG and xmake) plus a set of Papyrus scripts compiled with the Skyrim SE compiler.

## Requirements

- Visual Studio 2022 (MSVC v143)
- xmake 3.0+
- CommonLibSSE-NG v7+ ([alandtse fork](https://github.com/alandtse/CommonLibSSE-NG)) checked out at `lib/commonlibsse-ng` — v7.0.0 adds Skyrim AE 1.7.99 runtime support

## Setup

To fetch the submodule in a fresh clone:

```sh
git submodule update --init --recursive
```

## Build the C++ plugin

Debug:

```sh
xmake f -m debug
xmake
```

Release:

```sh
xmake f -m release
xmake
```

The plugin and PDB (debug only) are copied to `dist/Core/skse/plugins`.

## Papyrus scripts

Papyrus sources live in `dist/Core/source/scripts/*.psc` and compile to `dist/Core/scripts/*.pex`. The project file is `skyrimse.ppj`.

## Repo layout

```
src/                            C++ SKSE plugin (CommonLibSSE-NG)
dist/Core/
  source/scripts/               Papyrus source files (.psc)
  scripts/                      Compiled bytecode (.pex)
  BeeingFemale.esm              Main plugin (quests, forms, factions)
  BeeingFemale/
    AddOn/                      INI add-ons (race, actor, cme, misc, global)
    Couples/                    JSON couple data for import
    HUD/                        Widget layout profiles
    Names/                      Baby name databases
  Interface/translations/       Localized strings
  skse/plugins/                 Compiled .dll output
dist/Patches/                   Optional compatibility patches (FOMOD components)
tools/xedit/                    xEdit generator scripts (adult pack, fertility potion, …)
lib/commonlibsse-ng/            SKSE framework (submodule)
```

## Notes

- `xmake-requires.lock` is tracked to keep dependency versions stable.
- `SSEEDIT_locations/` is for reference only — don't compile or import it.
- The changelog is published on the [GitHub releases page](https://github.com/crajjjj/Beeing-Female-NG/releases).
