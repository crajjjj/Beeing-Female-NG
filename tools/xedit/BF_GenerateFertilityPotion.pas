{
  BF_GenerateFertilityPotion.pas
  Beeing Female NG - Fertility Tonic generator

  Creates the "Fertility Tonic" potions (the symmetric counterpart of the
  Contraception Fluid items) directly inside BeeingFemale.esm by copying and
  re-pointing the existing contraception forms. A tonic grants a timed
  conception-chance boost (FW.Fertility) that FWAbilityBeeingFemale adds to its
  fertile-window impregnation roll ("Gate 2"). Neither tonic cancels
  contraception.

  The effect magnitude does double duty - it is both the size of the Gate 2
  boost AND the tier selector that FWFertilityItem.execute() branches on:
    - Mild (magnitude 2): Gate 2 boost only.
    - Potent (magnitude 4): the same Gate 2 boost, PLUS it forces the current
      cycle's "can become pregnant" flag (Gate 1) on, so a cycle that rolled
      infertile becomes fertile for the rest of its window. So magnitude 4 here
      is not just a bigger boost - it crosses FWFertilityItem's >= 3.5 threshold
      that enables the Gate 1 behavior. Keep Potent at 4 unless you also change
      that threshold in the script.

  It creates ONE shared magic effect plus the two potions (exactly like
  contraception: a single MGEF, two potions whose EFIT magnitude differs):

  ONE magic effect (_BFFertilityEffect), cloned from the contraception MGEF:
    - VMAD script re-pointed FWContraceptionItem -> FWFertilityItem; ONLY the
      contraception-only properties (iModContraception0..9 / PlayerRef) are pruned.
      The FWSpell base properties (Controller, System, StatPregnancyCycle) are KEPT
      - they are required, or the effect errors out on cast.
    - FULL = "Fertility"; DNAM = "This fluid gives <mag> of fertility." (distinct
      text, so it gets its own string and never edits contraception's)
    - keyword swapped _FWContraceptionItemEffect -> _FWFertilityItemEffect; the
      contraception hit shader is left in place on purpose (cosmetic)

  TWO potions (Mild from 38C9, Potent from 38CB), each cloned from the matching
  contraception fluid:
    - effect re-pointed at the single _BFFertilityEffect above
    - EFIT magnitude set (Mild = 2, Potent = 4); the magnitude is read by
      FWFertilityItem and is the Gate 2 boost size AND the tier selector - 4
      crosses the script's >= 3.5 threshold that also forces Gate 1 (see note
      above), so keep Potent at 4 unless you change that threshold
    - keyword swapped _FWContraceptionItem -> _FWFertilityItem (NO contraception
      keyword remains)
    - the contraception crafting recipe(s) (COBJ whose Created Object is the
      source potion) are copied and re-pointed at the new potion, so it is
      craftable like contraception. The recipe's purple mountain flower is
      swapped for the red one (RECIPE_FLOWER_TO_EDID); other ingredients kept.

  No Papyrus form-reference is needed: the boost is applied through the MGEF's
  FWFertilityItem script, not Game.GetFormFromFile, so nothing in FWSystem /
  FWController has to point at these FormIDs.

  HOW TO RUN
    1. Compile FWFertilityItem.psc (and the edited FWController/FWAbility/FWSystem)
       first, so the script name the MGEF points at actually exists.
    2. Copy this file into xEdit's "Edit Scripts" folder.
    3. Start SSEEdit with your load order (BeeingFemale.esm must be present).
    4. Right-click any record -> Apply Script -> BF_GenerateFertilityPotion -> OK.
    5. Read the log for warnings, then exit xEdit and SAVE BeeingFemale.esm.

  AFTER SAVING (spot check in xEdit)
    - Both new ALCH records ("Fertility Tonic" / "Potent Fertility Tonic") have one
      effect whose Base Effect is the SAME _BFFertilityEffect, with EFIT magnitude
      2 (mild) and 4 (potent).
    - _BFFertilityEffect's VMAD names FWFertilityItem and keeps Controller/System
      (no iModContraception*/PlayerRef);
      its KWDA has _FWFertilityItemEffect (NOT _FWContraceptionItemEffect).
    - Each new ALCH's KWDA has _FWFertilityItem (NOT _FWContraceptionItem).
    - The copied COBJ recipes' "Created Object" points at the new potions.

  LOCALIZED STRINGS (important - BeeingFemale.esm is <Localized>)
    Item/effect names are NOT stored on the record; they live in
    Strings/BeeingFemale_<LANG>.STRINGS (+ .DLSTRINGS/.ILSTRINGS). The FULLs set
    above become string references. This mod ships NO real translations - every
    non-English STRINGS file is a CLONE of English (see the two .bat files in
    dist/Core/Strings).
    - ENGLISH: saving in xEdit regenerates BeeingFemale_English.STRINGS with the
      new names (confirm xEdit is saving strings, not inlining them).
    - ALL OTHER LANGUAGES: after the English update, re-clone so they pick up the
      new (and re-numbered) strings, in this order:
        1. run  _BakClonedFromEnglish.bat   (backs up + removes the old clones)
        2. run  "_Clone english strings to all not exist language strings.bat"
                                            (copies English -> every language)
      Skipping this leaves non-English STRINGS stale/mismatched. The MCM .txt
      files under Interface/translations/ are unrelated (SkyUI menu text).
    - RUSSIAN is the exception: it is a REAL translation (not a clone), so the
      clone bats skip it. Add the new names with xTranslator (translate, or paste
      the English text). Ukrainian has no ESM STRINGS file and auto-falls back to
      English, so it needs nothing.
    - !! CRITICAL ORDER !! Treat the ESM as FINAL once you save it in English.
      Do NOT re-save it in another language mode (e.g. an -l:russian xEdit save):
      saving a <Localized> plugin reassigns its string IDs and only rewrites the
      loaded language's STRINGS, which desyncs every other language - the ESM's
      new IDs then map to the wrong text (e.g. potions show the effect name /
      description). xTranslator is safe because it writes a language's STRINGS
      WITHOUT re-saving the ESM. So: English save -> clone bats -> xTranslator for
      Russian, and no further ESM saves.

  LOOT / VENDOR
    Contraception itself is not seeded through leveled lists (NPCs receive it via
    the NPCHaveItems script path), so this script does not touch leveled lists by
    default. To also seed the tonic as loot/vendor stock, list one or more potion
    leveled-list EditorIDs in LEVELED_LIST_EDIDS below; each found list gets both
    potions added (Level 1, Count 1). Leave it empty to skip.
}
unit BF_GenerateFertilityPotion;

const
  TARGET_FILE = 'BeeingFemale.esm';
  // comma-separated LVLI EditorIDs to add the tonics to; empty = skip
  LEVELED_LIST_EDIDS = '';
  // fertility keywords, mirroring the contraception pair they replace:
  //   _FWFertilityItem        on the potion (ALCH)  <- _FWContraceptionItem
  //   _FWFertilityItemEffect  on the effect (MGEF)  <- _FWContraceptionItemEffect
  FERTILITY_ITEM_KEYWORD_EDID   = '_FWFertilityItem';
  FERTILITY_EFFECT_KEYWORD_EDID = '_FWFertilityItemEffect';
  // magic-effect description (DNAM). <mag> is the runtime magnitude token - keep
  // it literal. Distinct from the contraception text, so it gets its own string.
  FERTILITY_DESCRIPTION = 'This fluid gives <mag> of fertility.';
  // recipe flavor: replace the contraception recipe's purple mountain flower with
  // the red one. Set to '' to leave the inherited ingredients untouched.
  RECIPE_FLOWER_TO_EDID = 'MountainFlower01Red';

var
  gBF: IInterface;
  gFertilityItemKw, gFertilityEffectKw, gRedFlower, gFertilityMgef: IInterface;
  gCreated, gWarnings: integer;

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
// 8-digit hex of a record's load-order FormID (for setting link subrecords)
function HexFID(rec: IInterface): string;
begin
  Result := IntToHex(GetLoadOrderFormID(rec), 8);
end;

//==========================================================================
procedure EnsureSet(rec: IInterface; path, value: string);
begin
  if not Assigned(ElementByPath(rec, path)) then
    Add(rec, path, True);
  SetElementEditValues(rec, path, value);
end;

//==========================================================================
// find a record in a specific file by its local (24-bit) FormID
function FindRecordByLocalID(f: IInterface; sig: string; localId: integer): IInterface;
var
  grp, r: IInterface;
  i: integer;
begin
  Result := nil;
  grp := GroupBySignature(f, sig);
  if not Assigned(grp) then
    Exit;
  for i := 0 to ElementCount(grp) - 1 do begin
    r := ElementByIndex(grp, i);
    if (GetLoadOrderFormID(r) and $FFFFFF) = localId then begin
      Result := r;
      Exit;
    end;
  end;
end;

//==========================================================================
function FindBySignatureAndEditorID(sig, edid: string): IInterface;
var
  i, j: integer;
  f, grp, r: IInterface;
begin
  Result := nil;
  for i := 0 to FileCount - 1 do begin
    f := FileByIndex(i);
    grp := GroupBySignature(f, sig);
    if not Assigned(grp) then
      continue;
    for j := 0 to ElementCount(grp) - 1 do begin
      r := ElementByIndex(grp, j);
      if SameText(EditorID(r), edid) then begin
        Result := r;
        Exit;
      end;
    end;
  end;
end;

//==========================================================================
// Remove ONLY the contraception-specific VMAD properties (iModContraception0..9
// and PlayerRef). Everything else is kept - critically the FWSpell base
// properties (Controller, System, StatPregnancyCycle) that FWFertilityItem
// inherits and REQUIRES: stripping those leaves them None and the effect errors
// out on the very first line of OnEffectStart (System.IsValidateFemaleActor).
// Fail-safe: if the property name can't be read, nothing is removed (all kept).
procedure StripScriptProperties(mgef: IInterface);
var
  props, p: IInterface;
  i: integer;
  nm: string;
begin
  try
    props := ElementByPath(mgef, 'VMAD - Virtual Machine Adapter\Scripts\[0]\Properties');
    if not Assigned(props) then
      Exit;
    i := ElementCount(props) - 1;
    while i >= 0 do begin
      p := ElementByIndex(props, i);
      nm := LowerCase(GetElementEditValues(p, 'propertyName'));
      if (Pos('imodcontraception', nm) > 0) or (nm = 'playerref') then
        RemoveElement(props, p);
      i := i - 1;
    end;
  except
    AddMessage('  NOTE: could not prune contraception-only properties (kept all - harmless).');
  end;
end;

//==========================================================================
// get (or create once) a keyword by EditorID, cloning an existing keyword as a
// template so the record structure matches; falls back to a fresh KYWD.
function GetOrCreateKeyword(newEdid, templateEdid: string): IInterface;
var
  template, grp: IInterface;
begin
  Result := FindBySignatureAndEditorID('KYWD', newEdid);
  if Assigned(Result) then
    Exit;
  template := FindBySignatureAndEditorID('KYWD', templateEdid);
  if Assigned(template) then
    Result := wbCopyElementToFile(template, gBF, True, True)
  else begin
    grp := GroupBySignature(gBF, 'KYWD');
    Result := Add(grp, 'KYWD', True);
  end;
  SetElementEditValues(Result, 'EDID', newEdid);
  AddMessage('Created keyword ' + newEdid + ' (' + HexFID(Result) + ')');
end;

//==========================================================================
// replace the inherited contraception keyword (oldEdid) on a record with newKw.
// Swaps in place when present, appends if absent, and removes a redundant old
// entry if the new keyword already exists. Other keywords are left untouched.
// Idempotent: safe to run more than once.
procedure SwapKeyword(rec: IInterface; oldEdid: string; newKw: IInterface);
var
  kwda, el, linked: IInterface;
  i, newFid, oldIndex, dupIndex: integer;
begin
  if not Assigned(newKw) then
    Exit;
  newFid := GetLoadOrderFormID(newKw);
  kwda := ElementByPath(rec, 'KWDA - Keywords');
  if not Assigned(kwda) then
    kwda := Add(rec, 'KWDA - Keywords', True);
  oldIndex := -1;
  dupIndex := -1;
  for i := 0 to ElementCount(kwda) - 1 do begin
    linked := LinksTo(ElementByIndex(kwda, i));
    if Assigned(linked) then begin
      if GetLoadOrderFormID(linked) = newFid then
        dupIndex := i
      else if SameText(EditorID(linked), oldEdid) then
        oldIndex := i;
    end;
  end;
  if dupIndex >= 0 then begin
    // new keyword already present - just drop the old one if it lingers
    if oldIndex >= 0 then
      RemoveElement(kwda, ElementByIndex(kwda, oldIndex));
  end else if oldIndex >= 0 then
    SetEditValue(ElementByIndex(kwda, oldIndex), IntToHex(newFid, 8))  // swap in place
  else begin
    el := ElementAssign(kwda, HighInteger, nil, False);               // neither present - add
    SetEditValue(el, IntToHex(newFid, 8));
  end;
  // keep the KSIZ counter in sync with the array length
  if Assigned(ElementByPath(rec, 'KSIZ - Keyword Count')) then
    SetElementNativeValues(rec, 'KSIZ - Keyword Count', ElementCount(kwda));
end;

//==========================================================================
// swap the contraception recipe's purple mountain flower for the configured red
// one (fertility flavor); leaves all other ingredients untouched
procedure SwapRecipeFlower(cobj: IInterface);
var
  items, itm, ref, linked: IInterface;
  k: integer;
  ed: string;
begin
  if not Assigned(gRedFlower) then
    Exit;
  items := ElementByPath(cobj, 'Items');
  if not Assigned(items) then
    Exit;
  for k := 0 to ElementCount(items) - 1 do begin
    itm := ElementByIndex(items, k);
    ref := ElementByPath(itm, 'CNTO - Item\Item');
    linked := LinksTo(ref);
    if Assigned(linked) then begin
      ed := LowerCase(EditorID(linked));
      if (Pos('mountainflower', ed) > 0) and (Pos('purple', ed) > 0) then begin
        SetEditValue(ref, IntToHex(GetLoadOrderFormID(gRedFlower), 8));
        AddMessage('  recipe: swapped purple mountain flower -> ' + EditorID(gRedFlower));
      end;
    end;
  end;
end;

//==========================================================================
// copy the contraception recipe(s) that create srcAlch, re-pointed at newAlch
procedure CopyRecipes(srcAlch, newAlch: IInterface; recipeEdid: string);
var
  i, j, origCount, made: integer;
  f, grp, cobj, cnam, newCobj, linked: IInterface;
  thisEdid: string;
begin
  made := 0;
  for i := 0 to FileCount - 1 do begin
    f := FileByIndex(i);
    grp := GroupBySignature(f, 'COBJ');
    if not Assigned(grp) then
      continue;
    origCount := ElementCount(grp);  // snapshot: don't revisit records we append
    for j := 0 to origCount - 1 do begin
      cobj := ElementByIndex(grp, j);
      cnam := ElementByPath(cobj, 'CNAM - Created Object');
      if not Assigned(cnam) then
        continue;
      linked := LinksTo(cnam);
      if Assigned(linked) and (GetLoadOrderFormID(linked) = GetLoadOrderFormID(srcAlch)) then begin
        newCobj := wbCopyElementToFile(cobj, gBF, True, True);
        // first recipe keeps the clean EditorID; any extras get a numeric suffix
        thisEdid := recipeEdid;
        if made > 0 then
          thisEdid := recipeEdid + IntToStr(made);
        SetElementEditValues(newCobj, 'EDID', thisEdid);
        SetElementEditValues(newCobj, 'CNAM - Created Object', HexFID(newAlch));
        SwapRecipeFlower(newCobj);  // purple mountain flower -> red (fertility flavor)
        AddMessage('  Copied recipe ' + Name(cobj) + ' -> ' + HexFID(newCobj));
        made := made + 1;
        gCreated := gCreated + 1;
      end;
    end;
  end;
  if made = 0 then begin
    AddMessage('  NOTE: no crafting recipe found for ' + EditorID(srcAlch) + ' - add one manually if you want it craftable.');
    gWarnings := gWarnings + 1;
  end;
end;

//==========================================================================
// create the SINGLE shared fertility MGEF, cloned from the contraception MGEF of
// the given template potion. Both fertility potions point at this one effect; the
// per-potion EFIT magnitude (read by FWFertilityItem) drives mild vs potent - so
// only one MGEF is needed, exactly like contraception.
function CreateFertilityMgef(templateAlchLocalId: integer): IInterface;
var
  srcAlch, srcMgef: IInterface;
begin
  Result := nil;
  srcAlch := FindRecordByLocalID(gBF, 'ALCH', templateAlchLocalId);
  if not Assigned(srcAlch) then begin
    AddMessage('ERROR: source contraception ALCH ' + IntToHex(templateAlchLocalId, 6) + ' not found in ' + TARGET_FILE);
    gWarnings := gWarnings + 1;
    Exit;
  end;
  srcMgef := LinksTo(ElementByPath(srcAlch, 'Effects\[0]\EFID - Base Effect'));
  if not Assigned(srcMgef) then begin
    AddMessage('ERROR: could not resolve the contraception MGEF from ' + EditorID(srcAlch));
    gWarnings := gWarnings + 1;
    Exit;
  end;
  Result := wbCopyElementToFile(srcMgef, gBF, True, True);
  SetElementEditValues(Result, 'EDID', '_BFFertilityEffect');
  EnsureSet(Result, 'FULL', 'Fertility');                   // short name
  EnsureSet(Result, 'DNAM', FERTILITY_DESCRIPTION);         // overwrite inherited contraception description
  SetElementEditValues(Result, 'VMAD - Virtual Machine Adapter\Scripts\[0]\scriptName', 'FWFertilityItem');
  StripScriptProperties(Result);
  SwapKeyword(Result, '_FWContraceptionItemEffect', gFertilityEffectKw);
  AddMessage('Created magic effect _BFFertilityEffect (' + HexFID(Result) + ')');
  gCreated := gCreated + 1;
end;

//==========================================================================
// build one fertility potion (ALCH) pointing at the shared MGEF; returns it.
// magnitude is the Gate 2 boost size; >= 3.5 also enables the potent Gate 1
// behavior (read by FWFertilityItem from this potion's EFIT).
function BuildPotion(srcLocalId: integer; alchEdid, alchFull, recipeEdid: string; magnitude: real): IInterface;
var
  srcAlch, newAlch: IInterface;
begin
  Result := nil;
  if not Assigned(gFertilityMgef) then
    Exit;
  srcAlch := FindRecordByLocalID(gBF, 'ALCH', srcLocalId);
  if not Assigned(srcAlch) then begin
    AddMessage('ERROR: source contraception ALCH ' + IntToHex(srcLocalId, 6) + ' not found in ' + TARGET_FILE);
    gWarnings := gWarnings + 1;
    Exit;
  end;
  newAlch := wbCopyElementToFile(srcAlch, gBF, True, True);
  SetElementEditValues(newAlch, 'EDID', alchEdid);
  EnsureSet(newAlch, 'FULL', alchFull);
  SetElementEditValues(newAlch, 'Effects\[0]\EFID - Base Effect', HexFID(gFertilityMgef));
  SetElementNativeValues(newAlch, 'Effects\[0]\EFIT - Magic Effect Data\Magnitude', magnitude);
  SwapKeyword(newAlch, '_FWContraceptionItem', gFertilityItemKw);
  AddMessage('  Created ' + alchFull + ' (' + HexFID(newAlch) + '), magnitude ' + FloatToStr(magnitude));
  gCreated := gCreated + 1;
  Result := newAlch;
  CopyRecipes(srcAlch, newAlch, recipeEdid);
end;

//==========================================================================
procedure AddToLeveledList(lvli, item: IInterface);
var
  entries, entry: IInterface;
begin
  entries := ElementByPath(lvli, 'Leveled List Entries');
  if not Assigned(entries) then
    entries := Add(lvli, 'Leveled List Entries', True);
  entry := ElementAssign(entries, HighInteger, nil, False);
  SetElementEditValues(entry, 'LVLO\Reference', HexFID(item));
  SetElementNativeValues(entry, 'LVLO\Level', 1);
  SetElementNativeValues(entry, 'LVLO\Count', 1);
end;

//==========================================================================
procedure SeedLeveledLists(mildAlch, potentAlch: IInterface);
var
  sl: TStringList;
  i: integer;
  lvliSrc, lvli: IInterface;
begin
  if LEVELED_LIST_EDIDS = '' then
    Exit;
  sl := TStringList.Create;
  try
    sl.CommaText := LEVELED_LIST_EDIDS;
    for i := 0 to sl.Count - 1 do begin
      lvliSrc := FindBySignatureAndEditorID('LVLI', Trim(sl.Strings[i]));
      if not Assigned(lvliSrc) then begin
        AddMessage('  NOTE: leveled list ' + sl.Strings[i] + ' not found - skipped.');
        gWarnings := gWarnings + 1;
        continue;
      end;
      // override the list into BeeingFemale.esm, then append both potions
      lvli := wbCopyElementToFile(lvliSrc, gBF, False, True);
      AddToLeveledList(lvli, mildAlch);
      AddToLeveledList(lvli, potentAlch);
      AddMessage('  Added both tonics to leveled list ' + EditorID(lvli));
    end;
  finally
    sl.Free;
  end;
end;

//==========================================================================
function Initialize: integer;
var
  mildAlch, potentAlch: IInterface;
begin
  Result := 1; // abort unless we finish cleanly
  gCreated := 0;
  gWarnings := 0;

  gBF := FindFile(TARGET_FILE);
  if not Assigned(gBF) then begin
    AddMessage('ERROR: ' + TARGET_FILE + ' is not loaded.');
    Exit;
  end;

  AddMessage('Generating Fertility Tonic records into ' + TARGET_FILE + '...');

  // create the two fertility keywords once (cloned from the contraception pair)
  gFertilityItemKw   := GetOrCreateKeyword(FERTILITY_ITEM_KEYWORD_EDID,   '_FWContraceptionItem');
  gFertilityEffectKw := GetOrCreateKeyword(FERTILITY_EFFECT_KEYWORD_EDID, '_FWContraceptionItemEffect');

  // resolve the replacement recipe flower once (used by CopyRecipes)
  if RECIPE_FLOWER_TO_EDID <> '' then begin
    gRedFlower := FindBySignatureAndEditorID('INGR', RECIPE_FLOWER_TO_EDID);
    if not Assigned(gRedFlower) then begin
      AddMessage('NOTE: ingredient ' + RECIPE_FLOWER_TO_EDID + ' not found - recipe flower swap skipped.');
      gWarnings := gWarnings + 1;
    end;
  end;

  // one shared magic effect (cloned from contraception), then the two potions
  gFertilityMgef := CreateFertilityMgef($38C9);

  // EditorIDs follow the existing BF conventions: ALCH '_BF_...',
  // recipe '_BFRecipe...' (mirror _BF_ContraceptionLow / _BFRecipeContraceptionLow)
  mildAlch   := BuildPotion($38C9, '_BF_FertilityTonicMild',  'Fertility Tonic',
                            '_BFRecipeFertilityTonicMild',   2.0);
  potentAlch := BuildPotion($38CB, '_BF_FertilityTonicPotent', 'Potent Fertility Tonic',
                            '_BFRecipeFertilityTonicPotent', 4.0);

  if Assigned(mildAlch) and Assigned(potentAlch) then
    SeedLeveledLists(mildAlch, potentAlch);

  SortMasters(gBF); // keep the header tidy; CleanMasters is skipped on the shipped master

  AddMessage('');
  AddMessage('==========================================================');
  AddMessage('Done. ' + IntToStr(gCreated) + ' record(s) created in ' + TARGET_FILE + ', ' + IntToStr(gWarnings) + ' warning(s).');
  AddMessage('Now exit xEdit and SAVE ' + TARGET_FILE + ', then follow the spot-check notes in the script header.');
  AddMessage('==========================================================');

  Result := 0; // records are already created; warnings are advisory only
end;

//==========================================================================
function Process(e: IInterface): integer;
begin
  Result := 0; // all work happens in Initialize
end;

end.
