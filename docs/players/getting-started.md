# Getting Started

## Requirements and Installation

Beeing Female NG runs on Skyrim Special Edition / Anniversary Edition / VR, including the AE 1.7.99 update (SKSE64 2.3.0+). These mods are hard requirements -- each one must match your exact game version:

- **SKSE64** -- and the game must be started through the SKSE loader (or the SKSE entry in your mod manager), not the vanilla launcher.
- **SkyUI** -- the full mod; it provides the MCM where all settings live.
- **PapyrusUtil** -- the 1.5.97 and 1.6.x builds are different downloads. If another mod bundles an older copy, make sure PapyrusUtil wins the file conflict (the file to watch is `StorageUtil.dll`).
- **Address Library for SKSE Plugins** -- needed by the bundled `BeeingFemale.dll`.

Install the archive with a mod manager (MO2 / Vortex) so the FOMOD installer runs, then make sure `BeeingFemale.esm` is enabled in your plugin list. SexLab, OStim, Bathing in Skyrim, SlaveTats, and the bundled patches are all optional.

## The Mod Does Not Show Up in the MCM?

Work through this list -- it covers nearly every case:

1. **Is `BeeingFemale.esm` active?** Installing the mod adds the files, but the plugin still has to be ticked in your plugin list.
2. **Was it installed through a mod manager?** The game files live in a `Core` subfolder that the FOMOD installer maps into `Data`. If you extracted the archive by hand and ended up with `Data\Core\BeeingFemale.esm`, the game never sees it -- install through MO2/Vortex, or copy the *contents* of `Core` into `Data`.
3. **Are you launching through SKSE?** Start the game via `skse64_loader.exe` (`sksevr_loader.exe` on VR) or the SKSE entry in your mod manager, not the Steam play button.
4. **Do SkyUI and PapyrusUtil match your game version?** A wrong-version PapyrusUtil is the most common silent killer. Check which mod wins the conflict on `StorageUtil.dll`.
5. **Give SkyUI a moment, then force a rescan.** New MCM menus can take a minute to register after loading a save. Open and close the journal a few times, save, reload. If it still does not appear, open the console and run `setstage SKI_ConfigManagerInstance 1`, then close the console and wait for the "Registered new menus" notification.
6. **Remove leftovers of the original Beeing Female.** The old LE/SE-ported mod shares script file names; an old copy overriding the NG files breaks loading. Uninstall it completely and ideally test on a save that never had it.
7. **Confirm the SKSE plugin loaded.** Look for `BeeingFemale.log` in `Documents\My Games\Skyrim Special Edition\SKSE\` (`Skyrim VR` on VR). If it is missing, open `skse64.log` (`sksevr.log` on VR) in the same folder and search for "BeeingFemale" -- it will say why the DLL was rejected (usually a wrong game version or missing Address Library).

If none of that helps, report the issue together with `SKSE\BeeingFemale.log` (or `skse64.log` if it is absent) and `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` -- a missing requirement shows up there as `Failed to load script FWSystemConfig` or "is not a valid type" lines. See [Troubleshooting & Logs](troubleshooting.md) for the full log paths and how to enable Papyrus logging.

## Where to next?

- New to the systems? Read [Cycle, Sex & Conception](cycle-and-conception.md).
- Want every toggle in one table? See the [MCM Reference](mcm-reference.md).
- Something not working? See [Troubleshooting & Logs](troubleshooting.md).
- Hygiene item getting knocked off by other gear? See [Item Slots & Conflicts](../authors/item-slots.md) (quick fix: switch to tampons).
