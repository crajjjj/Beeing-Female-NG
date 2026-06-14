{
  BF_SetFertilityRussianStrings.pas
  Beeing Female NG - Russian names/descriptions for the Fertility Tonic

  BeeingFemale.esm is <Localized>, and Russian is a REAL translation (not an
  English clone), so the clone bats skip it. This script fills the Russian FULL
  and DNAM strings for the fertility records that BF_GenerateFertilityPotion.pas
  created. Run it AFTER that generator + the English save.

  ! CRITICAL ! It writes the strings of whatever language xEdit loaded. You MUST
  start xEdit with the Russian language or you will overwrite ENGLISH:
        SSEEdit.exe -l:russian
  (In MO2: add  -l:russian  to the SSEEdit executable's Arguments.)
  A confirmation prompt is shown as a safety net, but it cannot truly detect the
  language - that is on you.

  HOW TO RUN
    1. Start xEdit with  -l:russian , load order incl. BeeingFemale.esm.
    2. Right-click any record -> Apply Script -> BF_SetFertilityRussianStrings.
    3. Confirm the prompt, read the log, then exit xEdit and SAVE BeeingFemale.esm.
       Saving writes BeeingFemale_RUSSIAN.STRINGS (+ .DLSTRINGS for the DNAM).

  ENCODING
    This file must stay UTF-8 so the Cyrillic below is read correctly by xEdit.
    Edit the four strings to taste; keep <mag> literal in the description.
}
unit BF_SetFertilityRussianStrings;

const
  TARGET_FILE = 'BeeingFemale.esm';
  // ---- edit these to taste (Cyrillic; keep <mag> literal) -------------------
  RU_TONIC_MILD   = 'Тоник фертильности';
  RU_TONIC_POTENT = 'Сильный тоник фертильности';
  RU_EFFECT_NAME  = 'Фертильность';
  RU_EFFECT_DESC  = 'Эта жидкость даёт <mag> фертильности.';
  // --------------------------------------------------------------------------

var
  gBF: IInterface;
  gCount, gWarnings: integer;

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
// find a record in TARGET_FILE by signature + EditorID
function FindRec(sig, edid: string): IInterface;
var
  grp, r: IInterface;
  i: integer;
begin
  Result := nil;
  grp := GroupBySignature(gBF, sig);
  if not Assigned(grp) then
    Exit;
  for i := 0 to ElementCount(grp) - 1 do begin
    r := ElementByIndex(grp, i);
    if SameText(EditorID(r), edid) then begin
      Result := r;
      Exit;
    end;
  end;
end;

//==========================================================================
procedure SetPath(rec: IInterface; path, value, fieldName: string);
begin
  if not Assigned(ElementByPath(rec, path)) then
    Add(rec, path, True);
  SetElementEditValues(rec, path, value);
  AddMessage('  ' + EditorID(rec) + ' ' + fieldName + ' = ' + value);
  gCount := gCount + 1;
end;

//==========================================================================
function ApplyFull(sig, edid, value: string): IInterface;
begin
  Result := FindRec(sig, edid);
  if not Assigned(Result) then begin
    AddMessage('WARNING: ' + sig + ' ' + edid + ' not found - run the generator first.');
    gWarnings := gWarnings + 1;
    Exit;
  end;
  SetPath(Result, 'FULL', value, 'FULL');
end;

//==========================================================================
function Initialize: integer;
var
  mgef: IInterface;
begin
  Result := 1;
  gCount := 0;
  gWarnings := 0;

  if MessageDlg('This writes the CURRENTLY LOADED language''s strings.' + #13#10 +
                'xEdit must have been started with  -l:russian  or you will' + #13#10 +
                'overwrite ENGLISH. Continue?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then begin
    AddMessage('Aborted by user.');
    Exit;
  end;

  gBF := FindFile(TARGET_FILE);
  if not Assigned(gBF) then begin
    AddMessage('ERROR: ' + TARGET_FILE + ' is not loaded.');
    Exit;
  end;

  AddMessage('Setting Russian fertility strings in ' + TARGET_FILE + '...');

  ApplyFull('ALCH', '_BF_FertilityTonicMild',   RU_TONIC_MILD);
  ApplyFull('ALCH', '_BF_FertilityTonicPotent', RU_TONIC_POTENT);

  mgef := ApplyFull('MGEF', '_BFFertilityEffect', RU_EFFECT_NAME);
  if Assigned(mgef) then
    SetPath(mgef, 'DNAM', RU_EFFECT_DESC, 'DNAM');

  AddMessage('');
  AddMessage('Done. ' + IntToStr(gCount) + ' string(s) set, ' + IntToStr(gWarnings) + ' warning(s).');
  AddMessage('Exit xEdit and SAVE ' + TARGET_FILE + ' to write the Russian STRINGS/DLSTRINGS.');
  Result := 0;
end;

//==========================================================================
function Process(e: IInterface): integer;
begin
  Result := 0;
end;

end.
