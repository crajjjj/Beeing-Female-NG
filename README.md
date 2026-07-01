# Beeing Female NG

<p align="center">
  <a href="https://www.nexusmods.com/skyrimspecialedition/mods/168434"><img src="https://img.shields.io/badge/⬇%20Download-Nexus%20Mods-d9782d?style=for-the-badge" alt="Download on Nexus"></a>
</p>

<p align="center">
  <a href="https://crajjjj.github.io/Beeing-Female-NG/"><img src="https://img.shields.io/badge/docs-GitHub%20Pages-brightgreen?logo=readthedocs&logoColor=white" alt="Documentation"></a>
  <a href="https://github.com/crajjjj/Beeing-Female-NG/actions/workflows/docs.yml"><img src="https://github.com/crajjjj/Beeing-Female-NG/actions/workflows/docs.yml/badge.svg" alt="Deploy docs"></a>
  <a href="https://github.com/crajjjj/Beeing-Female-NG/releases/latest"><img src="https://img.shields.io/github/v/release/crajjjj/Beeing-Female-NG?label=release" alt="Latest release"></a>
  <img src="https://img.shields.io/badge/Skyrim-SE%2FAE%2FVR-orange" alt="Skyrim SE/AE/VR">
  <img src="https://img.shields.io/badge/plugin-SKSE%20(CommonLibSSE--NG)-8A2BE2" alt="SKSE plugin">
  <img src="https://img.shields.io/badge/content-18%2B-black" alt="18+ content"><br>
  <a href="https://github.com/crajjjj/Beeing-Female-NG/releases"><img src="https://img.shields.io/github/downloads/crajjjj/Beeing-Female-NG/total" alt="Total downloads"></a>
  <img src="https://img.shields.io/github/last-commit/crajjjj/Beeing-Female-NG" alt="Last commit">
  <img src="https://img.shields.io/badge/license-GPL--3.0-blue" alt="License: GPL-3.0">
  <img src="https://img.shields.io/github/repo-size/crajjjj/Beeing-Female-NG" alt="Repo size">
</p>

A Skyrim SE/AE/VR mod that simulates a female reproductive cycle — menstruation, fertility, conception, pregnancy, birth, and interactive children — for the player and for NPCs. Hybrid SKSE C++ plugin (CommonLibSSE-NG) plus a Papyrus script system.

## Documentation

Full documentation lives on the docs site: **https://crajjjj.github.io/Beeing-Female-NG/**

**For players**
- [Getting Started](https://crajjjj.github.io/Beeing-Female-NG/players/getting-started/) — requirements, installation, MCM troubleshooting
- [Troubleshooting & Logs](https://crajjjj.github.io/Beeing-Female-NG/players/troubleshooting/) — log locations and enabling Papyrus logging
- [Cycle, Sex & Conception](https://crajjjj.github.io/Beeing-Female-NG/players/cycle-and-conception/)
- [Pregnancy & Birth](https://crajjjj.github.io/Beeing-Female-NG/players/pregnancy-and-birth/)
- [Children](https://crajjjj.github.io/Beeing-Female-NG/players/children/)
- [HUD Widgets](https://crajjjj.github.io/Beeing-Female-NG/players/hud-widgets/), [Tattoos](https://crajjjj.github.io/Beeing-Female-NG/players/tattoos/), [NPC Pregnancy & Couples](https://crajjjj.github.io/Beeing-Female-NG/players/npc-pregnancy/), [Couples Import](https://crajjjj.github.io/Beeing-Female-NG/players/couples-import/)
- [Mod Integrations & Patches](https://crajjjj.github.io/Beeing-Female-NG/players/integrations/), [MCM Reference](https://crajjjj.github.io/Beeing-Female-NG/players/mcm-reference/)

**For mod authors**
- [Add-on Framework](https://crajjjj.github.io/Beeing-Female-NG/authors/add-on-framework/)
- [Papyrus ModEvents](https://crajjjj.github.io/Beeing-Female-NG/authors/modevents/)
- [StorageUtil & State Data](https://crajjjj.github.io/Beeing-Female-NG/authors/state-data/)
- [Pregnancy Ranks (Factions)](https://crajjjj.github.io/Beeing-Female-NG/authors/pregnancy-ranks/)
- [Item Slots & Conflicts](https://crajjjj.github.io/Beeing-Female-NG/authors/item-slots/)
- [Building from Source](https://crajjjj.github.io/Beeing-Female-NG/authors/building/)

## Building

See [Building from Source](https://crajjjj.github.io/Beeing-Female-NG/authors/building/). In short: `xmake f -m release && xmake` builds the C++ plugin into `dist/Core/skse/plugins`; Papyrus sources in `dist/Core/source/scripts/*.psc` compile via `skyrimse.ppj`.

## Changelog

Release notes are published on the [GitHub releases page](https://github.com/crajjjj/Beeing-Female-NG/releases).
