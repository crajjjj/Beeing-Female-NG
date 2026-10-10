// BFATKC_GenerateTKChildren
// Beeing Female NG - TK Children child actor pack generator
//
// Writes dist/Addon/BFATKC:
//   BeeingFemaleTKChildren.esp (ESL-flagged) and
//   BeeingFemale/AddOn/BFA_TKChildren.ini (the race add-on listing every base).
//
// The plugin holds child actor bases for human parents (Nord, Imperial, Breton,
// Redguard): copies of the stock BF child actors, as BeeingFemaleSE_Opt.esp ships
// them, dressed in TK Children hair, eyes, head textures and face shapes.
// They keep BF's own child race (_FWNordRaceChild), so no race, skin or clothing
// record is touched. The RS Children patch restyles that same race and the Simple
// Children pack answers for the same parent races, so only one child pack is run.
//
// The bases carry the "Is CharGen Face Preset" flag, like the BF Adult Pack, so
// the engine computes their faces live: no FaceGen export, no dark-face bug.
// TK Children's head, eye and hair parts are valid for the vanilla child races
// only, so they are copied into the plugin with a valid-race list that names the
// BF child race. That keeps TKChildren.esm out of the master list; its meshes,
// textures and face morph (tri) files are still required at runtime, and the INI
// gates on it with "required=". Nothing of TK Children itself is shipped: its
// permissions forbid redistributing TKChildren.esm and the tri files.
//
// HOW TO RUN (from the repo root)
//   dotnet run --project tools/mutagen/BFATKC_GenerateTKChildren -- "<TK Children folder>"
// The folder must contain TKChildren.esm and TKChildren.esp (the face slider
// values are read from the latter): the installed mod folder, or "00 Main" of the
// unpacked archive. An optional second argument overrides the repo root. Re-run
// whenever the stock child actors in BeeingFemaleSE_Opt.esp change, so the copies
// pick up the new script properties.

using System.Drawing;
using System.Text;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string PluginName = "BeeingFemaleTKChildren.esp";
const string IniName = "BFA_TKChildren.ini";
const string Prefix = "_BFTK_";
const int LooksPerSex = 3;

if (args.Length < 1)
{
    Console.Error.WriteLine("usage: BFATKC_GenerateTKChildren <TK Children folder> [repo root]");
    return 1;
}
string tkDir = args[0];
string repo = args.Length > 1 ? args[1] : Directory.GetCurrentDirectory();
string coreDir = Path.Combine(repo, "dist", "Core");
string outDir = Path.Combine(repo, "dist", "Addon", "BFATKC");

using var tk = SkyrimMod.CreateFromBinaryOverlay(Path.Combine(tkDir, "TKChildren.esm"), SkyrimRelease.SkyrimSE);
using var kids = SkyrimMod.CreateFromBinaryOverlay(Path.Combine(tkDir, "TKChildren.esp"), SkyrimRelease.SkyrimSE);
using var bfOpt = SkyrimMod.CreateFromBinaryOverlay(Path.Combine(coreDir, "BeeingFemaleSE_Opt.esp"), SkyrimRelease.SkyrimSE);

var bfChildRace = FormKey.Factory("05A082:BeeingFemale.esm");

// 1..10 are HumanSkinBaseWhite01..10, the skin tone presets of the BF child race
// (tint index 1 male / 2 female, preset numbers 1..10 male / 11..20 female).
// 11 and 12 are HumanSkinDarkSkin09 and 10, the tones TK Children's Redguard
// children wear. The BF child race has no preset for them, so they are written
// as custom colors.
const int RacePresets = 10;
var skinTones = new (int R, int G, int B)[]
{
    (198, 176, 168), (183, 156, 145), (167, 134, 122), (130, 109, 91), (112, 97, 86),
    (97, 83, 73), (92, 67, 50), (87, 61, 51), (82, 61, 48), (92, 61, 54),
    (48, 33, 22), (45, 33, 30),
};

// Vanilla hair colors, all in the BF child race's available list.
var hairColors = new Dictionary<string, uint>
{
    ["LightBlond"] = 0x0A042D, ["BrightBlond"] = 0x0A042F, ["HoneyBlond"] = 0x0A042E,
    ["DarkBlond"] = 0x0A042C, ["Auburn"] = 0x0A0431, ["Chestnut"] = 0x0A0430,
    ["MediumBrown"] = 0x0A0432, ["DarkBrown"] = 0x0A0433, ["BlueBlack"] = 0x0A0435,
    ["Black"] = 0x0A0434,
};

// Parent races each group answers to (vampire forms included, they are the same people).
var raceIds = new (string Race, string Label, string Ids)[]
{
    ("Nord", "Nord, Nord Astrid, Nord Vampire, Elder, Elder Vampire",
        "Skyrim:13746,Skyrim:7EAF3,Skyrim:88794,Skyrim:67CD8,Skyrim:A82BA"),
    ("Imperial", "Imperial, Imperial Vampire", "Skyrim:13744,Skyrim:88844"),
    ("Breton", "Breton, Breton Vampire", "Skyrim:13741,Skyrim:8883C"),
    ("Redguard", "Redguard, Redguard Vampire", "Skyrim:13748,Skyrim:88846"),
};

// Hair/Eyes/Head are TKChildren.esm head part EditorIDs. All three are always set:
// the race defaults are the vanilla child parts, which would leave a vanilla head
// texture next to TK's. Face names the TKChildren.esp child whose face sliders are
// reused. No look repeats a TK child's full combination. ChildEyesLightGrey is
// left out: TK points it at the same texture as ChildEyesLightblue.
var looks = new Look[]
{
    new("Nord", true, "HairFemaleChild01", "ChildEyesIceblue", "HeadChild_1", "LightBlond", 5, "Runa"),
    new("Nord", true, "HairFemaleChild04", "ChildEyesGreen", "HeadChild_Freckle", "Auburn", 5, "Eirid"),
    new("Nord", true, "HairFemaleChild02", "ChildEyesGrey", "HeadChild_1", "HoneyBlond", 4, "Svari"),
    new("Nord", false, "HairMaleChild01", "ChildEyesLightblue", "HeadChild_2", "LightBlond", 5, "Skuli"),
    new("Nord", false, "HairMaleChild03", "ChildEyesGrey", "HeadChild_Freckle", "Chestnut", 5, "WERJ04Kid01"),
    new("Nord", false, "HairMaleChild04", "ChildEyesGreen", "HeadChild_2", "DarkBlond", 4, "Gralnach"),

    new("Imperial", true, "HairFemaleChild02", "ChildEyesHazelBrown", "HeadChild_1", "DarkBrown", 6, "BYOHUrchin_Lucia"),
    new("Imperial", true, "HairFemaleChild03", "ChildEyesBrown", "HeadChild_1", "Black", 6, "Dagny"),
    new("Imperial", true, "HairFemaleChild01", "ChildEyesHazel", "HeadChild", "MediumBrown", 5, "BYOHUrchin_Sofie"),
    new("Imperial", false, "HairMaleChild02", "ChildEyesBrown", "HeadChild_2", "DarkBrown", 6, "Samuel"),
    new("Imperial", false, "HairMaleChild04", "ChildEyesHazelBrown", "HeadChild", "Black", 6, "Assur"),
    new("Imperial", false, "HairMaleChild01", "ChildEyesHazel", "HeadChild_2", "MediumBrown", 5, "Francois"),

    new("Breton", true, "HairFemaleChild04", "ChildEyesHazel", "HeadChild_1", "Chestnut", 5, "Erith"),
    new("Breton", true, "HairFemaleChild01", "ChildEyesGreen", "HeadChild_Freckle", "Auburn", 4, "Sissel"),
    new("Breton", true, "HairFemaleChild03", "ChildEyesAmber", "HeadChild", "DarkBrown", 5, "MinetteVinius"),
    new("Breton", false, "HairMaleChild03", "ChildEyesGreen", "HeadChild_2", "Auburn", 5, "Joric"),
    new("Breton", false, "HairMaleChild02", "ChildEyesHazel", "HeadChild", "MediumBrown", 6, "ClintonLylvieve"),
    new("Breton", false, "HairMaleChild01", "ChildEyesLightblue", "HeadChild_Freckle", "HoneyBlond", 4, "Virkmund"),

    new("Redguard", true, "HairFemaleChild02", "ChildEyesBrown", "HeadChild", "Black", 12, "Braith"),
    new("Redguard", true, "HairFemaleChild04", "ChildEyesAmber", "HeadChild_2", "BlueBlack", 11, "Adara"),
    new("Redguard", true, "HairFemaleChild03", "ChildEyesHazelBrown", "HeadChild_1", "DarkBrown", 9, "Agni"),
    new("Redguard", false, "HairMaleChild02", "ChildEyesHazelBrown", "HeadChild_2", "Black", 9, "Kayd"),
    new("Redguard", false, "HairMaleChild04", "ChildEyesBrown", "HeadChild", "BlueBlack", 12, "BYOHUrchin_Alesan"),
    new("Redguard", false, "HairMaleChild01", "ChildEyesAmber", "HeadChild_2", "Black", 11, "Nelkir"),
};

var outMod = new SkyrimMod(ModKey.FromFileName(PluginName), SkyrimRelease.SkyrimSE);
outMod.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small;
outMod.ModHeader.Author = "crajjjj";
outMod.ModHeader.Description = "Beeing Female NG - TK Children child actors. Generated by tools/mutagen/BFATKC_GenerateTKChildren.";

var validRaces = outMod.FormLists.AddNew(Prefix + "ChildHeadPartRaces");
validRaces.Items.Add(bfChildRace.ToLink<ISkyrimMajorRecordGetter>());

// TKChildren.esm also overrides a few vanilla child head parts; only its own are copied.
var tkHeadParts = tk.HeadParts.Where(h => h.FormKey.ModKey == tk.ModKey).ToDictionary(h => h.EditorID!, StringComparer.OrdinalIgnoreCase);
var tkTextureSets = tk.TextureSets.ToDictionary(t => t.FormKey);
var copiedParts = new Dictionary<string, HeadPart>(StringComparer.OrdinalIgnoreCase);
var copiedTextures = new Dictionary<FormKey, TextureSet>();

HeadPart CopyHeadPart(string edid)
{
    if (copiedParts.TryGetValue(edid, out var done)) return done;
    if (!tkHeadParts.TryGetValue(edid, out var src))
        throw new InvalidOperationException($"TKChildren.esm defines no head part '{edid}'");

    var part = outMod.HeadParts.DuplicateInAsNewRecord(src);
    part.EditorID = Prefix + src.EditorID;
    part.Flags &= ~HeadPart.Flag.Playable;
    part.ValidRaces.SetTo(validRaces);
    copiedParts[edid] = part;

    if (tkTextureSets.TryGetValue(src.TextureSet.FormKey, out var srcTex))
    {
        if (!copiedTextures.TryGetValue(srcTex.FormKey, out var tex))
        {
            tex = outMod.TextureSets.DuplicateInAsNewRecord(srcTex);
            tex.EditorID = Prefix + srcTex.EditorID;
            copiedTextures[srcTex.FormKey] = tex;
        }
        part.TextureSet.SetTo(tex);
    }

    part.ExtraParts.Clear();
    foreach (var extra in src.ExtraParts)
    {
        var extraSrc = tkHeadParts.Values.FirstOrDefault(h => h.FormKey == extra.FormKey)
            ?? throw new InvalidOperationException($"'{edid}' uses an extra part outside TKChildren.esm ({extra.FormKey}); pick another hair");
        part.ExtraParts.Add(CopyHeadPart(extraSrc.EditorID!));
    }
    return part;
}

var kidsByName = kids.Npcs.ToDictionary(n => n.EditorID!, StringComparer.OrdinalIgnoreCase);
var ini = new Dictionary<string, List<string>>();

foreach (var (race, _, _) in raceIds)
{
    foreach (bool female in new[] { true, false })
    {
        var raceLooks = looks.Where(l => l.Race == race && l.Female == female).ToArray();
        if (raceLooks.Length != LooksPerSex)
            throw new InvalidOperationException($"{race} {(female ? "female" : "male")}: expected {LooksPerSex} looks, found {raceLooks.Length}");

        foreach (bool player in new[] { false, true })
        {
            string sex = female ? "Female" : "Male";
            string baseId = (player ? "_BFChildActorPlayer_" : "_BFChildActor_") + sex;
            var stock = bfOpt.Npcs.FirstOrDefault(n => n.EditorID == baseId)
                ?? throw new InvalidOperationException($"BeeingFemaleSE_Opt.esp has no '{baseId}'");

            for (int i = 0; i < raceLooks.Length; i++)
            {
                var look = raceLooks[i];
                var npc = outMod.Npcs.DuplicateInAsNewRecord(stock);
                npc.EditorID = $"{Prefix}ChildActor{race}{(player ? "Player" : "")}_{sex}{i + 1:00}";
                npc.Name = $"{(player ? "Player " : "")}{race} {(female ? "Girl" : "Boy")}";
                npc.ShortName = female ? "Girl" : "Boy";
                npc.IsCompressed = false;
                npc.Configuration.Flags |= NpcConfiguration.Flag.IsCharGenFacePreset;

                npc.HeadParts.Clear();
                npc.HeadParts.Add(CopyHeadPart(look.Head));
                npc.HeadParts.Add(CopyHeadPart(look.Eyes));
                npc.HeadParts.Add(CopyHeadPart(look.Hair));
                npc.HairColor.SetTo(new FormKey(ModKey.FromFileName("Skyrim.esm"), hairColors[look.HairColor]));

                var tone = skinTones[look.Skin - 1];
                var skin = Color.FromArgb(0, tone.R, tone.G, tone.B);
                npc.TextureLighting = skin;
                npc.TintLayers.Clear();
                npc.TintLayers.Add(new TintLayer
                {
                    Index = (ushort)(female ? 2 : 1),
                    Color = skin,
                    InterpolationValue = 1f,
                    Preset = (short)(look.Skin > RacePresets ? -1 : female ? look.Skin + 10 : look.Skin),
                });

                if (!kidsByName.TryGetValue(look.Face, out var face))
                    throw new InvalidOperationException($"TKChildren.esp has no '{look.Face}'");
                if (face.FaceMorph == null || face.FaceParts == null)
                    throw new InvalidOperationException($"TKChildren.esp leaves '{look.Face}' without face sliders; pick another face");
                npc.FaceMorph = face.FaceMorph.DeepCopy();
                npc.FaceParts = face.FaceParts.DeepCopy();

                string key = $"{race}|BabyActor_{sex}{(player ? "Player" : "")}";
                if (!ini.TryGetValue(key, out var list)) ini[key] = list = new List<string>();
                list.Add($"{Path.GetFileNameWithoutExtension(PluginName)}:{npc.FormKey.ID:X}");
            }
        }
    }
}

Directory.CreateDirectory(outDir);
string pluginPath = Path.Combine(outDir, PluginName);
outMod.BeginWrite
    .ToPath(pluginPath)
    .WithLoadOrder(new[] { "Skyrim.esm", "Update.esm", "Dawnguard.esm", "HearthFires.esm", "Dragonborn.esm", "BeeingFemale.esm", "BeeingFemaleBasicAddOn.esp", "BeeingFemaleSE_Opt.esp" }.Select(name => ModKey.FromFileName(name)).ToArray())
    .WithNoDataFolder()
    .Write();

var sb = new StringBuilder();
sb.AppendLine("# Generated by tools/mutagen/BFATKC_GenerateTKChildren - regenerate rather than hand-edit the FormIDs.");
sb.AppendLine("# Human children only: other races keep whatever child their own add-on (or the fallback) provides.");
sb.AppendLine("# Uses BF's own child race, which the RS Children patch restyles, and answers for the same parent races as the Simple Children pack, so run one child pack, not several.");
sb.AppendLine("[AddOn]");
sb.AppendLine("name=BF TK Children");
sb.AppendLine("description=Spawns the children of Nord, Imperial, Breton and Redguard parents with TK Children hair, eyes, head textures and face shapes (three looks per sex and race), so they match the other children in a TK Children game. Faces are computed live by the engine, so no FaceGen files are needed. Do not combine with the RS Children or Simple Children add-on.");
sb.AppendLine("author=crajjjj");
sb.AppendLine("type=race");
sb.AppendLine($"required=TKChildren.esm,{PluginName}");
sb.AppendLine();
sb.AppendLine("enabled=true");
sb.AppendLine("hidden=false");
sb.AppendLine("locked=false");
sb.AppendLine();
sb.AppendLine($"races={raceIds.Length}");
for (int r = 0; r < raceIds.Length; r++)
{
    var (race, label, ids) = raceIds[r];
    sb.AppendLine();
    sb.AppendLine($"[Race{r + 1}]");
    sb.AppendLine($"#{label}");
    sb.AppendLine($"id={ids}");
    foreach (string slot in new[] { "BabyActor_Female", "BabyActor_FemalePlayer", "BabyActor_Male", "BabyActor_MalePlayer" })
        sb.AppendLine($"{slot}={string.Join(",", ini[$"{race}|{slot}"])}");
}
string iniPath = Path.Combine(outDir, "BeeingFemale", "AddOn", IniName);
Directory.CreateDirectory(Path.GetDirectoryName(iniPath)!);
File.WriteAllText(iniPath, sb.ToString().ReplaceLineEndings("\r\n"), new UTF8Encoding(false));

Console.WriteLine($"{pluginPath}: {outMod.Npcs.Count} child actors, {outMod.HeadParts.Count} head parts, {outMod.TextureSets.Count} texture sets");
Console.WriteLine(iniPath);
return 0;

record Look(string Race, bool Female, string Hair, string Eyes, string Head, string HairColor, int Skin, string Face);
