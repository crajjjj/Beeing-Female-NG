# Beeing Female NG

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
