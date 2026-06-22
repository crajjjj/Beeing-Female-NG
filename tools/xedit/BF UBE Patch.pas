{
  BF_UBE_ArmorPatch
  -----------------
  Generates a patch plugin that makes Beeing Female NG's worn items -
  baby slings/baby items, menstrual panties, tampons, pads, etc - render
  on UBE (UBE_AllRace.esp) mothers.

  WHY: a worn armor's mesh only shows on races listed in its Armor Addon
  (ARMA) "Additional Races". BF's armatures list the vanilla races only,
  so these items are invisible when the wearer is a UBE custom race. This
  script sweeps EVERY wearable armor in BeeingFemale.esm, copies their
  armatures into a patch, and adds every UBE race to their Additional
  Races. Shared armatures are de-duped (patched once).

  HOW TO RUN (SSEEdit / xEdit):
    1. Copy this file into your xEdit "Edit Scripts" folder
       (next to SSEEdit.exe), OR use Apply Script -> paste.
    2. Launch xEdit, load your full load order. Both
       BeeingFemale.esm and UBE_AllRace.esp MUST be ticked.
    3. Wait for "Background Loader: finished".
    4. Right-click any record in the left pane -> "Apply Script...".
    5. Select "BF UBE Patch", click OK.
    6. When prompted to create a new file, name it
       BF_UBESupport_Patch.esp (or accept the default).
       If asked to add masters, click Yes.
    7. Ctrl+S, tick BF_UBESupport_Patch.esp, Save.
    8. In your mod manager, enable BF_UBESupport_Patch.esp and let it
       load AFTER BeeingFemale.esm and UBE_AllRace.esp.

  NOTE: this is the ONE piece that needs a plugin. The INI add-on
  (BF_UBESupport) stays plugin-less; this patch only adds race coverage
  to BF's worn-item armatures. It does NOT edit BeeingFemale.esm itself.
}
unit BF_UBE_Patch;

const
  BF_PLUGIN  = 'BeeingFemale.esm';
  UBE_PLUGIN = 'UBE_AllRace.esp';
  PATCH_NAME = 'BF_UBESupport_Patch.esp';

var
  bfFile, ubeFile, patchFile, ubeRaceGrp : IInterface;
  armaDone : TStringList;

function FindFile(aName: string): IInterface;
var
  i: Integer;
  f: IInterface;
begin
  Result := nil;
  for i := 0 to FileCount - 1 do begin
    f := FileByIndex(i);
    if SameText(GetFileName(f), aName) then begin
      Result := f;
      Break;
    end;
  end;
end;

function RecByLocalID(f: IInterface; sig: string; localID: Cardinal): IInterface;
var
  grp, r: IInterface;
  i: Integer;
begin
  Result := nil;
  grp := GroupBySignature(f, sig);
  if not Assigned(grp) then Exit;
  for i := 0 to ElementCount(grp) - 1 do begin
    r := ElementByIndex(grp, i);
    if (GetLoadOrderFormID(r) and $00FFFFFF) = (localID and $00FFFFFF) then begin
      Result := r;
      Break;
    end;
  end;
end;

procedure AddRacesToArma(arma: IInterface);
var
  armaOvr, addRaces, entry, raceRec: IInterface;
  i, j: Integer;
  key, fidHex: string;
  already: Boolean;
begin
  key := IntToHex(GetLoadOrderFormID(arma), 8);
  if armaDone.IndexOf(key) >= 0 then Exit;
  armaDone.Add(key);

  armaOvr := wbCopyElementToFile(arma, patchFile, False, True);
  if not Assigned(armaOvr) then begin
    AddMessage('  ! could not copy ARMA ' + key);
    Exit;
  end;

  addRaces := ElementByPath(armaOvr, 'Additional Races');
  if not Assigned(addRaces) then
    addRaces := Add(armaOvr, 'Additional Races', True);

  for i := 0 to ElementCount(ubeRaceGrp) - 1 do begin
    raceRec := ElementByIndex(ubeRaceGrp, i);
    if Signature(raceRec) <> 'RACE' then Continue;
    fidHex := IntToHex(GetLoadOrderFormID(raceRec), 8);

    already := False;
    for j := 0 to ElementCount(addRaces) - 1 do begin
      entry := ElementByIndex(addRaces, j);
      if SameText(IntToHex(GetNativeValue(entry), 8), fidHex) then begin
        already := True;
        Break;
      end;
    end;
    if already then Continue;

    entry := ElementAssign(addRaces, HighInteger, nil, False);
    SetEditValue(entry, fidHex);
  end;

  AddMessage('  patched ARMA ' + key + '  (' + GetElementEditValues(armaOvr, 'EDID') + ')');
end;

function Initialize: Integer;
var
  i, j, armoCount, patchedArma: Integer;
  armoGrp, armo, armature, armaRef, arma: IInterface;
  edid: string;
begin
  Result := 0;

  bfFile  := FindFile(BF_PLUGIN);
  ubeFile := FindFile(UBE_PLUGIN);
  if not Assigned(bfFile) then begin
    AddMessage('ERROR: ' + BF_PLUGIN + ' is not loaded.'); Result := 1; Exit;
  end;
  if not Assigned(ubeFile) then begin
    AddMessage('ERROR: ' + UBE_PLUGIN + ' is not loaded.'); Result := 1; Exit;
  end;

  ubeRaceGrp := GroupBySignature(ubeFile, 'RACE');
  if not Assigned(ubeRaceGrp) or (ElementCount(ubeRaceGrp) = 0) then begin
    AddMessage('ERROR: no RACE records found in ' + UBE_PLUGIN); Result := 1; Exit;
  end;

  patchFile := FindFile(PATCH_NAME);
  if not Assigned(patchFile) then
    patchFile := AddNewFile; // name it BF_UBESupport_Patch.esp in the dialog
  if not Assigned(patchFile) then begin
    AddMessage('ERROR: no patch file created.'); Result := 1; Exit;
  end;
  AddMasterIfMissing(patchFile, BF_PLUGIN);
  AddMasterIfMissing(patchFile, UBE_PLUGIN);
  // The sling/panty armatures list vanilla (and possibly DLC) races in their
  // Additional Races. Add those game masters up front so the deep copy can
  // map them (otherwise: "FileID [00] can not be mapped"). Only added if the
  // master is actually loaded; run "Clean Masters" later to trim any unused.
  if Assigned(FindFile('Skyrim.esm'))      then AddMasterIfMissing(patchFile, 'Skyrim.esm');
  if Assigned(FindFile('Update.esm'))      then AddMasterIfMissing(patchFile, 'Update.esm');
  if Assigned(FindFile('Dawnguard.esm'))   then AddMasterIfMissing(patchFile, 'Dawnguard.esm');
  if Assigned(FindFile('HearthFires.esm')) then AddMasterIfMissing(patchFile, 'HearthFires.esm');
  if Assigned(FindFile('Dragonborn.esm'))  then AddMasterIfMissing(patchFile, 'Dragonborn.esm');

  armaDone := TStringList.Create;
  armoCount := 0;
  try
    // Sweep EVERY wearable armor in BeeingFemale.esm (slings/baby items,
    // panties, tampons, pads, etc). Any ARMO with an Armature gets its
    // armor addons opened up to the UBE races. Shared armatures are
    // de-duped, so each ARMA is patched once.
    armoGrp := GroupBySignature(bfFile, 'ARMO');
    if not Assigned(armoGrp) then begin
      AddMessage('ERROR: no ARMO group in ' + BF_PLUGIN); Result := 1; Exit;
    end;
    for i := 0 to ElementCount(armoGrp) - 1 do begin
      armo := ElementByIndex(armoGrp, i);
      if Signature(armo) <> 'ARMO' then Continue;
      armature := ElementByPath(armo, 'Armature');
      if not Assigned(armature) or (ElementCount(armature) = 0) then Continue;
      edid := GetElementEditValues(armo, 'EDID');
      // Skip child/baby-actor clothing and naked-body armatures. Those are
      // worn by the CHILD, not the mother; their winning overrides live in
      // other patches (e.g. BeeingFemale_RS_PatchSE_ESPFE.esp) and pull in
      // masters we don't want. We only need the mother-worn reproductive
      // items: baby slings, panties, tampons, bleed/fluid effects.
      if (Pos('CHILD', UpperCase(edid)) > 0) or (Pos('NAKED', UpperCase(edid)) > 0) then begin
        AddMessage('  skip ' + edid + '  (child/naked - not needed)');
        Continue;
      end;
      AddMessage('ARMO ' + IntToHex(GetLoadOrderFormID(armo) and $00FFFFFF, 6)
        + '  (' + edid + ')');
      for j := 0 to ElementCount(armature) - 1 do begin
        armaRef := ElementByIndex(armature, j);
        arma := LinksTo(armaRef);
        if Assigned(arma) then
          AddRacesToArma(WinningOverride(arma));
      end;
      Inc(armoCount);
    end;
    patchedArma := armaDone.Count;
  finally
    armaDone.Free;
  end;

  AddMessage('DONE. Swept ' + IntToStr(armoCount) + ' wearable armors, patched '
    + IntToStr(patchedArma) + ' armatures (+UBE races).');
  AddMessage('TIP: this is override-only - safe to ESL-flag. In the File Header,');
  AddMessage('     tick the ESL flag (Record Flags), then Save, to make it espfe.');
  AddMessage('Save ' + PATCH_NAME + ', then enable it after BeeingFemale.esm and ' + UBE_PLUGIN + '.');
end;

end.
