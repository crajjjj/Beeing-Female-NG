{
  BFAP_GenerateAdultPack.pas
  Beeing Female NG - Adult Variety Pack generator

  Creates "BeeingFemaleAdultPack.esp" (ESL-flagged) containing copies of
  the 200 vanilla chargen preset NPCs (10 per race and sex). The copies keep
  the "Is CharGen Face Preset" flag (ACBS flags, bit $4), so the engine
  computes their faces live - no FaceGen export, no dark-face bug. Unlike the
  raw presets they get:

    - proper editor IDs (BFAP_NordM01 ...) and neutral display names
      (no more "Prisoner" base-name leakage)
    - a real class instead of Prisoner (auto-calc stats follow it)
    - the race-fitting follower-capable voice baked into VTCK
    - a default farm-clothes outfit (when one is found)
    - a vanilla sandbox AI package so unrecruited adults idle instead of
      standing frozen
    - the Unique flag cleared (several children may share one base)

  It also writes a ready-to-edit BF race add-on INI next to the xEdit exe
  ("BF Adult Pack.ini") listing every generated record.

  HOW TO RUN
    1. Copy this file into xEdit's "Edit Scripts" folder.
    2. Start SSEEdit with at least Skyrim.esm loaded (full load order is fine).
       "BeeingFemaleAdultPack.esp" must NOT already exist - remove it first
       when regenerating.
    3. Right-click any record -> Apply Script -> BFAP_GenerateAdultPack -> OK.
    4. Check the log for warnings, then exit xEdit and save the new plugin.
    5. Verify in the saved plugin that new FormIDs are in the 800..FFF range
       (they should be, because the ESL flag is set before records are added).
       If your xEdit version allocated outside that range: right-click the
       plugin -> Compact FormIDs for ESL, then save again.
    6. Move "BF Adult Pack.ini" (written next to the xEdit exe) into
       Data\BeeingFemale\AddOn\ and adjust to taste. It replaces the preset
       lists from "Default Adult Actors.ini"; race add-on lists merge, so
       either disable the default add-on or keep both for a larger pool.

  IN-GAME SPOT CHECK (one-time, before trusting the pack)
    player.placeatme <one BFAP FormID> - the actor must have a normal face
    (not dark, not grey). That confirms the chargen flag carried the live
    face computation over to the copy.
}
unit BFAP_GenerateAdultPack;

var
  gTargetPlugin, gIniPluginRef: string;
  gSkyrim, gTarget: IInterface;
  gClass, gPackage, gOutfit: IInterface;
  slIni, slNames: TStringList;
  gCopied, gWarnings: integer;

//==========================================================================
function FindFile(aName: string): IInterface;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to FileCount - 1 do
    if SameText(GetFileName(FileByIndex(i)), aName) then begin
      Result := FileByIndex(i);
      Exit;
    end;
end;

//==========================================================================
procedure SplitText(s, delim: string; sl: TStringList);
var
  p: integer;
begin
  sl.Clear;
  p := Pos(delim, s);
  while p > 0 do begin
    sl.Add(Copy(s, 1, p - 1));
    s := Copy(s, p + 1, Length(s));
    p := Pos(delim, s);
  end;
  sl.Add(s);
end;

//==========================================================================
// file-local FormID as compact hex (ESL-aware), e.g. '800'
function HexLocalID(fid: integer): string;
var
  localId: integer;
begin
  if (fid shr 24) = $FE then
    localId := fid and $FFF
  else
    localId := fid and $FFFFFF;
  Result := IntToHex(localId, 1);
end;

//==========================================================================
function ResolveSkyrimRecord(hexId: string): IInterface;
begin
  Result := RecordByFormID(gSkyrim, StrToInt('$' + hexId), True);
end;

//==========================================================================
// manual scan instead of MainRecordByEditorID - works on every xEdit build
function FindBySignatureAndEditorID(sig, edid: string): IInterface;
var
  grp, r: IInterface;
  i: integer;
begin
  Result := nil;
  grp := GroupBySignature(gSkyrim, sig);
  for i := 0 to ElementCount(grp) - 1 do begin
    r := ElementByIndex(grp, i);
    if SameText(EditorID(r), edid) then begin
      Result := r;
      Exit;
    end;
  end;
end;

//==========================================================================
function FindFirstOfCandidates(sig, candidates: string): IInterface;
var
  sl: TStringList;
  i: integer;
begin
  Result := nil;
  sl := TStringList.Create;
  try
    SplitText(candidates, ',', sl);
    for i := 0 to sl.Count - 1 do begin
      Result := FindBySignatureAndEditorID(sig, sl.Strings[i]);
      if Assigned(Result) then
        Exit;
    end;
  finally
    sl.Free;
  end;
end;

//==========================================================================
// plain farm-clothes outfit: exact candidates first, then any 'farmclothes'
// without hat variants, then any 'farmclothes', then any 'farm'
function FindOutfitRecord: IInterface;
var
  grp, r: IInterface;
  i: integer;
  ed: string;
begin
  Result := FindFirstOfCandidates('OTFT', 'FarmClothesOutfit01,FarmClothesOutfit02,FarmClothesOutfit03,FarmClothesOutfit04');
  if Assigned(Result) then
    Exit;
  grp := GroupBySignature(gSkyrim, 'OTFT');
  for i := 0 to ElementCount(grp) - 1 do begin
    r := ElementByIndex(grp, i);
    ed := LowerCase(EditorID(r));
    if (Pos('farmclothes', ed) > 0) and (Pos('hat', ed) = 0) then begin
      Result := r;
      Exit;
    end;
  end;
  for i := 0 to ElementCount(grp) - 1 do begin
    r := ElementByIndex(grp, i);
    if Pos('farmclothes', LowerCase(EditorID(r))) > 0 then begin
      Result := r;
      Exit;
    end;
  end;
  for i := 0 to ElementCount(grp) - 1 do begin
    r := ElementByIndex(grp, i);
    if Pos('farm', LowerCase(EditorID(r))) > 0 then begin
      Result := r;
      Exit;
    end;
  end;
end;

//==========================================================================
procedure EnsureSet(rec: IInterface; path, value: string);
begin
  if not Assigned(ElementByPath(rec, path)) then
    Add(rec, path, True);
  SetElementEditValues(rec, path, value);
end;

//==========================================================================
procedure CustomizeNPC(newRec: IInterface; edid, fullName, voiceHex: string);
var
  pkgs: IInterface;
  acbsFlags: integer;
begin
  SetElementEditValues(newRec, 'EDID', edid);
  EnsureSet(newRec, 'FULL', fullName);
  EnsureSet(newRec, 'VTCK', IntToHex(StrToInt('$' + voiceHex), 8));

  if Assigned(gClass) then
    EnsureSet(newRec, 'CNAM', IntToHex(GetLoadOrderFormID(gClass), 8));

  if Assigned(gOutfit) then
    EnsureSet(newRec, 'DOFT', IntToHex(GetLoadOrderFormID(gOutfit), 8));

  // "Is CharGen Face Preset" lives in ACBS flags (bit $4), not the record
  // header. Handle the bits numerically so xEdit flag display names can't bite.
  acbsFlags := GetElementNativeValues(newRec, 'ACBS\Flags');

  // the whole point of using presets - the live-face flag must be present
  if (acbsFlags and $4) = 0 then begin
    AddMessage('  WARNING: ' + edid + ' is missing the "Is CharGen Face Preset" ACBS flag - it will dark-face without FaceGen!');
    gWarnings := gWarnings + 1;
  end;

  if (acbsFlags and $20) <> 0 then
    acbsFlags := acbsFlags - $20;  // Unique off - several grown children may share one base
  if (acbsFlags and $10) = 0 then
    acbsFlags := acbsFlags + $10;  // Auto-calc stats on - let the assigned class drive attributes
  SetElementNativeValues(newRec, 'ACBS\Flags', acbsFlags);

  if Assigned(gPackage) then begin
    RemoveElement(newRec, 'Packages');
    pkgs := Add(newRec, 'Packages', True);
    SetEditValue(ElementByIndex(pkgs, 0), IntToHex(GetLoadOrderFormID(gPackage), 8));
  end;
end;

//==========================================================================
// copies one preset list (one race, one sex); csv = voice followed by the
// preset formids; returns the comma list of 'PluginRef:localhex' for the INI
function CopyPresetList(presetCsv, raceTag, sexTag: string): string;
var
  sl: TStringList;
  i: integer;
  srcRec, newRec: IInterface;
  edid, numStr, voiceHex: string;
begin
  Result := '';
  sl := TStringList.Create;
  try
    SplitText(presetCsv, ',', sl);
    voiceHex := sl.Strings[0];
    for i := 1 to sl.Count - 1 do begin
      srcRec := ResolveSkyrimRecord(sl.Strings[i]);
      if not Assigned(srcRec) then begin
        AddMessage('  WARNING: Skyrim.esm record ' + sl.Strings[i] + ' not found - skipped');
        gWarnings := gWarnings + 1;
      end else begin
        numStr := IntToStr(i);
        if i < 10 then
          numStr := '0' + numStr;
        edid := 'BFAP_' + raceTag + sexTag + numStr;

        newRec := wbCopyElementToFile(srcRec, gTarget, True, True);
        if not Assigned(newRec) then begin
          AddMessage('  WARNING: copy failed for ' + sl.Strings[i]);
          gWarnings := gWarnings + 1;
        end else begin
          CustomizeNPC(newRec, edid, slNames.Strings[(i - 1) mod slNames.Count], voiceHex);
          gCopied := gCopied + 1;

          if Result <> '' then
            Result := Result + ',';
          Result := Result + gIniPluginRef + ':' + HexLocalID(GetLoadOrderFormID(newRec));
        end;
      end;
    end;
  finally
    sl.Free;
  end;
end;

//==========================================================================
// data line: tag|display|idLine|maleVoice,malePresets...|femaleVoice,femalePresets...
procedure ProcessRace(raceIdx: integer; dataLine: string);
var
  sl: TStringList;
  maleIni, femaleIni: string;
begin
  sl := TStringList.Create;
  try
    SplitText(dataLine, '|', sl);
    AddMessage('Race ' + IntToStr(raceIdx) + ': ' + sl.Strings[1]);

    maleIni := CopyPresetList(sl.Strings[3], sl.Strings[0], 'M');
    femaleIni := CopyPresetList(sl.Strings[4], sl.Strings[0], 'F');

    slIni.Add('[Race' + IntToStr(raceIdx) + ']');
    slIni.Add('#' + sl.Strings[1]);
    slIni.Add('id=' + sl.Strings[2]);
    slIni.Add('AdultActor_Male=' + maleIni);
    slIni.Add('AdultActor_Female=' + femaleIni);
    slIni.Add('');
  finally
    sl.Free;
  end;
end;

//==========================================================================
function Initialize: integer;
var
  header: IInterface;
  iniPath: string;
begin
  Result := 1;  // abort unless we finish cleanly
  gTargetPlugin := 'BeeingFemaleAdultPack.esp';
  gIniPluginRef := 'BeeingFemaleAdultPack';  // extension optional for the BF resolver
  gCopied := 0;
  gWarnings := 0;

  gSkyrim := FindFile('Skyrim.esm');
  if not Assigned(gSkyrim) then begin
    AddMessage('ERROR: Skyrim.esm is not loaded.');
    Exit;
  end;

  if Assigned(FindFile(gTargetPlugin)) then begin
    AddMessage('ERROR: ' + gTargetPlugin + ' already exists in this session. Remove the file and restart xEdit to regenerate.');
    Exit;
  end;

  gTarget := AddNewFileName(gTargetPlugin);
  if not Assigned(gTarget) then begin
    AddMessage('ERROR: could not create ' + gTargetPlugin);
    Exit;
  end;

  // ESL flag BEFORE adding records so new FormIDs land in 800..FFF
  header := ElementByIndex(gTarget, 0);
  SetElementNativeValues(header, 'Record Header\Record Flags\ESL', 1);
  EnsureSet(header, 'CNAM', 'Beeing Female NG');
  AddMasterIfMissing(gTarget, 'Skyrim.esm');

  // shared lookups (EditorID-based so AE/SE form differences cannot bite)
  gClass := FindFirstOfCandidates('CLAS', 'CombatWarrior1H,EncClassWarrior1H,CombatRanger,SoldierImperialNotGuard');
  if Assigned(gClass) then
    AddMessage('Class: ' + EditorID(gClass))
  else begin
    AddMessage('WARNING: no candidate class found - copies keep the Prisoner class.');
    gWarnings := gWarnings + 1;
  end;

  gPackage := FindFirstOfCandidates('PACK', 'DefaultSandboxEditorLocation512,DefaultSandboxEditorLocation1024,DefaultSandboxCurrentLocation512,DefaultSandboxCurrentLocation1024');
  if Assigned(gPackage) then
    AddMessage('AI package: ' + EditorID(gPackage))
  else begin
    AddMessage('WARNING: no sandbox package found - copies get no AI package (they will stand in place when not following).');
    gWarnings := gWarnings + 1;
  end;

  gOutfit := FindOutfitRecord;
  if Assigned(gOutfit) then
    AddMessage('Outfit: ' + EditorID(gOutfit))
  else
    AddMessage('NOTE: no farm outfit found - copies keep no default outfit (BF roughspun fallback applies).');

  slNames := TStringList.Create;
  slNames.Add('Wanderer');
  slNames.Add('Traveler');
  slNames.Add('Adventurer');
  slNames.Add('Drifter');
  slNames.Add('Pilgrim');
  slNames.Add('Sellsword');
  slNames.Add('Hunter');
  slNames.Add('Outlander');
  slNames.Add('Rover');
  slNames.Add('Nomad');

  slIni := TStringList.Create;
  slIni.Add('[AddOn]');
  slIni.Add('name=BF Adult Pack');
  slIni.Add('description=Adult NPC bases generated from the vanilla chargen presets into BeeingFemaleAdultPack.esp. Same live-computed faces (no FaceGen needed), but with proper names, class, follower voice, outfit and a sandbox AI package. Replaces the preset lists from Default Adult Actors.ini - disable that add-on or keep both for a larger pool.');
  slIni.Add('author=Beeing Female NG');
  slIni.Add('type=race');
  slIni.Add('');
  slIni.Add('enabled=true');
  slIni.Add('hidden=false');
  slIni.Add('locked=false');
  slIni.Add('');
  slIni.Add('races=10');
  slIni.Add('');

  // tag|display|idLine|maleVoice,malePresets|femaleVoice,femalePresets
  ProcessRace(1,  'Argonian|Argonian|Skyrim:13740,Skyrim:8883A|13AEE,43E57,43E58,A2CEB,A2CEF,A2CF0,B2E10,10D3C2,10D3C3,10D3C4,10D3C5|13AEF,B2E11,B2E12,B2E13,B2E14,B2E15,B2E16,10D3BE,10D3BF,10D3C0,10D3C1');
  ProcessRace(2,  'Breton|Breton|Skyrim:13741,Skyrim:8883C|13AD2,79F6A,79F64,79F60,79F5F,99D22,10AB67,10AB68,10AB69,10AB6A,10AB6B|13ADD,79F65,79F63,79F62,79F61,99D50,10AB62,10AB63,10AB64,10AB65,10AB66');
  ProcessRace(3,  'DarkElf|Dark Elf|Skyrim:13742,Skyrim:8883D|13AF2,5EFA7,79F5E,79F5D,79F5C,99D52,10AB71,10AB72,10AB73,10AB74,10AB75|13AF3,79F5B,79F5A,79F59,79F58,99D51,10AB6C,10AB6D,10AB6E,10AB6F,10AB70');
  ProcessRace(4,  'HighElf|High Elf|Skyrim:13743,Skyrim:88840|13AD2,5EF9C,79C96,79C54,79BEE,99D5D,10AB7B,10AB7C,10AB7D,10AB7E,10AB7F|13ADD,79BED,79BEC,79BEB,79BE6,99D5E,10AB76,10AB77,10AB78,10AB79,10AB7A');
  ProcessRace(5,  'Imperial|Imperial|Skyrim:13744,Skyrim:88844|13AD1,26921,26927,2694E,26954,99D21,10AB85,10AB86,10AB87,10AB88,10AB89|13ADC,79F66,79F57,79F56,79F55,99D4F,10AB80,10AB81,10AB82,10AB83,10AB84');
  ProcessRace(6,  'Khajiit|Khajiit|Skyrim:13745,Skyrim:88845|13AEC,43E59,43E5A,EE84E,EE853,EE854,10D3CB,10D3CC,10D3CD,10D3CE,10D3CF|13ADD,EE856,EE85D,EE85E,EE85F,EE860,10D3C6,10D3C7,10D3C8,10D3C9,10D3CA');
  ProcessRace(7,  'Nord|Nord|Skyrim:13746,Skyrim:7EAF3,Skyrim:88794|13AE6,1750C,1750D,1750E,1750F,2425F,10AB5D,10AB5E,10AB5F,10AB60,10AB61|13AE7,79F68,79F54,79F53,79F52,99D4D,10AB8A,10AB8B,10AB8C,10AB8D,10AB8E');
  ProcessRace(8,  'Orc|Orc|Skyrim:13747,Skyrim:A82B9|13AEA,79F69,79F51,79F50,79F4F,99D4C,10AB94,10AB95,10AB96,10AB97,10AB98|13AEB,79F4E,79F25,79EE8,79EE6,99D5F,10AB8F,10AB90,10AB91,10AB92,10AB93');
  ProcessRace(9,  'Redguard|Redguard|Skyrim:13748,Skyrim:88846|13AD2,5B4F8,26904,268FC,26915,24261,10AB9E,10AB9F,10ABA0,10ABA1,10ABA2|13AE0,79F67,79EE1,79E2F,79E2C,99D4E,10AB99,10AB9A,10AB9B,10AB9C,10AB9D');
  ProcessRace(10, 'WoodElf|Wood Elf|Skyrim:13749,Skyrim:88884|EA267,5EF9A,79DD5,79CD5,79CD4,99D53,10ABA8,10ABA9,10ABAA,10ABAB,10ABAC|13ADC,79CD3,79CCE,79CCD,79C98,99D58,10ABA3,10ABA4,10ABA5,10ABA6,10ABA7');

  SortMasters(gTarget);
  CleanMasters(gTarget);

  iniPath := ProgramPath + 'BF Adult Pack.ini';
  slIni.SaveToFile(iniPath);

  AddMessage('');
  AddMessage('==========================================================');
  AddMessage('Done. ' + IntToStr(gCopied) + ' NPC records created in ' + gTargetPlugin + ', ' + IntToStr(gWarnings) + ' warning(s).');
  AddMessage('Add-on INI written to: ' + iniPath);
  AddMessage('Now exit xEdit and SAVE the new plugin, then follow the header notes (FormID range check, in-game face spot check).');
  AddMessage('==========================================================');

  slIni.Free;
  slNames.Free;
  Result := 0;
end;

//==========================================================================
function Process(e: IInterface): integer;
begin
  Result := 0;  // all work happens in Initialize
end;

end.
