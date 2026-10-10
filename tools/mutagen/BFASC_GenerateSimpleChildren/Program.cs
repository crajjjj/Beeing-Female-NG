// BFASC_GenerateSimpleChildren
// Beeing Female NG - Simple Children child actor pack generator
//
// Writes dist/Addon/BFASC:
//   BeeingFemaleSimpleChildren.esp (ESL-flagged) and
//   BeeingFemale/AddOn/BFA_SimpleChildren.ini (the race add-on listing every base).
//
// The plugin holds child actor bases for human parents (Nord, Imperial, Breton,
// Redguard): copies of the stock BF child actors, as BeeingFemaleSE_Opt.esp ships
// them, dressed in Simple Children hair, eyes, head textures and skin tones.
// They keep BF's own child race (_FWNordRaceChild); no skin or clothing record is
// touched. That is also why this pack and the RS Children pack exclude each
// other: the RS patch restyles that same race. The TK Children pack answers for
// the same parent races, so it is not run alongside either.
//
// The one BF record the plugin overrides is that race, to give it a Morph Race.
// Simple Children requires TK Children's tri files, and those shape the child
// head, eyes and mouth through race morphs the engine picks by the race's
// EditorID or Morph Race. BF's child race matches neither, so without the
// override its children keep the vanilla head shape while every other child has
// TK's. All four parent races borrow NordRaceChild's morph. The override copies
// the winning record from BeeingFemaleSE_Opt.esp, which is listed as a master so
// the plugin sorts after it. It adds no FormID: the child bases keep the IDs that
// 3.6.1 saves store, so do not reorder or edit the looks table below.
//
// The bases carry the "Is CharGen Face Preset" flag, like the BF Adult Pack, so
// the engine computes their faces live: no FaceGen export, no dark-face bug.
// The Simple Children head parts and texture sets are copied into the plugin
// with a valid-race list that names the BF child race, so SimpleChildren.esp is
// not a master. Its meshes and textures are still required at runtime; the INI
// gates on it with "required=".
//
// HOW TO RUN (from the repo root)
//   dotnet run --project tools/mutagen/BFASC_GenerateSimpleChildren -- "<Simple Children mod folder>"
// The folder must contain SimpleChildren.esp and FacegenForKids.esp (the face
// slider values are read from the latter). An optional second argument overrides
// the repo root. Re-run whenever the stock child actors in BeeingFemaleSE_Opt.esp
// change, so the copies pick up the new script properties.

using System.Drawing;
using System.Text;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string PluginName = "BeeingFemaleSimpleChildren.esp";
const string IniName = "BFA_SimpleChildren.ini";
const string Prefix = "_BFSC_";
const int LooksPerSex = 3;

if (args.Length < 1)
{
    Console.Error.WriteLine("usage: BFASC_GenerateSimpleChildren <Simple Children mod folder> [repo root]");
    return 1;
}
string scDir = args[0];
string repo = args.Length > 1 ? args[1] : Directory.GetCurrentDirectory();
string coreDir = Path.Combine(repo, "dist", "Core");
string outDir = Path.Combine(repo, "dist", "Addon", "BFASC");

using var sc = SkyrimMod.CreateFromBinaryOverlay(Path.Combine(scDir, "SimpleChildren.esp"), SkyrimRelease.SkyrimSE);
using var kids = SkyrimMod.CreateFromBinaryOverlay(Path.Combine(scDir, "FacegenForKids.esp"), SkyrimRelease.SkyrimSE);
using var bfOpt = SkyrimMod.CreateFromBinaryOverlay(Path.Combine(coreDir, "BeeingFemaleSE_Opt.esp"), SkyrimRelease.SkyrimSE);

var bfChildRace = FormKey.Factory("05A082:BeeingFemale.esm");
var nordRaceChild = FormKey.Factory("02C65B:Skyrim.esm");

// HumanSkinBaseWhite01..10, the skin tone presets of the BF child race
// (tint index 1 male / 2 female, preset numbers 1..10 male / 11..20 female).
var skinTones = new (int R, int G, int B)[]
{
    (198, 176, 168), (183, 156, 145), (167, 134, 122), (130, 109, 91), (112, 97, 86),
    (97, 83, 73), (92, 67, 50), (87, 61, 51), (82, 61, 48), (92, 61, 54),
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

// Hair/Eyes/Head are SimpleChildren.esp head part EditorIDs; null keeps the race
// default (brown eyes, smooth head). Face names the FacegenForKids.esp child whose
// face sliders are reused. No look repeats a vanilla child's full combination.
var looks = new Look[]
{
    new("Nord", true, "ChildHairF_TD18_3", "ChildEyesLightBlue", null, "LightBlond", 1, "Dorthe"),
    new("Nord", true, "ChildHairF17", "ChildEyesIceBlue", "MaleHeadChild_Freckles", "Auburn", 2, "Agni"),
    new("Nord", true, "HairFemaleNordChild01c", "ChildEyesLightGrey", null, "BrightBlond", 1, "Eirid"),
    new("Nord", false, "ChildHairM08", "ChildEyesLightBlue", null, "LightBlond", 1, "LarsBattleBorn"),
    new("Nord", false, "ChildHairM_VHVP_1", "ChildEyesIceGrey", "MaleHeadChild_Freckles", "Chestnut", 2, "Hroar"),
    new("Nord", false, "ChildHairM10", "ChildEyesDarkBlue", "MaleHeadChild_Rough", "DarkBlond", 2, "Joric"),

    new("Imperial", true, "ChildHairF14", "ChildEyesHazelBrown", null, "DarkBrown", 3, "Dagny"),
    new("Imperial", true, "ChildHairF_VHVP_3", "ChildEyesBrightGreen", null, "MediumBrown", 3, "BYOHUrchin_Lucia"),
    new("Imperial", true, "ChildHairF09", null, null, "Black", 4, "MilaValentia"),
    new("Imperial", false, "ChildHairM11", "ChildEyesHazelBrown", null, "DarkBrown", 3, "Francois"),
    new("Imperial", false, "ChildHairM04", null, null, "Black", 4, "Samuel"),
    new("Imperial", false, "ChildHairM_TD18_9", "ChildEyesHazel", "MaleHeadChild_Rough", "MediumBrown", 3, "Frothar"),

    new("Breton", true, "ChildHairF18", "ChildEyesHazel", null, "Chestnut", 2, "Erith"),
    new("Breton", true, "ChildHairF_TD18_5", "ChildEyesBrightGreen", "MaleHeadChild_Freckles", "Auburn", 1, "Sissel"),
    new("Breton", true, "ChildHairF_Serana", "ChildEyesLightBlue", null, "DarkBrown", 2, "BYOHUrchin_Sofie"),
    new("Breton", false, "ChildHairM20", "ChildEyesDarkBlue", "MaleHeadChild_Freckles", "Auburn", 2, "BYOHUrchin_Blaise"),
    new("Breton", false, "ChildHairM14", "ChildEyesHazel", null, "MediumBrown", 2, "Virkmund"),
    new("Breton", false, "ChildHairM_VHVP_4", "ChildEyesLightGrey", null, "HoneyBlond", 1, "Skuli"),

    new("Redguard", true, "ChildHairF_R02", null, null, "Black", 8, "Adara"),
    new("Redguard", true, "ChildHairF_R01", "ChildEyesAmber", null, "BlueBlack", 7, "Braith"),
    new("Redguard", true, "ChildHairF20", "ChildEyesHazelBrown", null, "DarkBrown", 9, "Britte"),
    new("Redguard", false, "ChildHairM_R05", "ChildEyesHazelBrown", null, "BlueBlack", 8, "BYOHUrchin_Alesan"),
    new("Redguard", false, "ChildHairM16", null, null, "Black", 9, "Kayd"),
    new("Redguard", false, "ChildHairM09", "ChildEyesAmber", null, "Black", 7, "ClintonLylvieve"),
};

var outMod = new SkyrimMod(ModKey.FromFileName(PluginName), SkyrimRelease.SkyrimSE);
outMod.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small;
outMod.ModHeader.Author = "crajjjj";
outMod.ModHeader.Description = "Beeing Female NG - Simple Children child actors. Generated by tools/mutagen/BFASC_GenerateSimpleChildren.";

var validRaces = outMod.FormLists.AddNew(Prefix + "ChildHeadPartRaces");
validRaces.Items.Add(bfChildRace.ToLink<ISkyrimMajorRecordGetter>());

var stockRace = bfOpt.Races.FirstOrDefault(r => r.FormKey == bfChildRace)
    ?? throw new InvalidOperationException("BeeingFemaleSE_Opt.esp no longer overrides _FWNordRaceChild; copy the race from the plugin that now wins");
outMod.Races.GetOrAddAsOverride(stockRace).MorphRace.SetTo(nordRaceChild);

var scHeadParts = sc.HeadParts.Where(h => h.FormKey.ModKey == sc.ModKey).ToDictionary(h => h.EditorID!, StringComparer.OrdinalIgnoreCase);
var scTextureSets = sc.TextureSets.ToDictionary(t => t.FormKey);
var copiedParts = new Dictionary<string, HeadPart>(StringComparer.OrdinalIgnoreCase);
var copiedTextures = new Dictionary<FormKey, TextureSet>();

HeadPart CopyHeadPart(string edid)
{
    if (copiedParts.TryGetValue(edid, out var done)) return done;
    if (!scHeadParts.TryGetValue(edid, out var src))
        throw new InvalidOperationException($"SimpleChildren.esp defines no head part '{edid}'");

    var part = outMod.HeadParts.DuplicateInAsNewRecord(src);
    part.EditorID = Prefix + src.EditorID;
    part.Flags &= ~HeadPart.Flag.Playable;
    part.ValidRaces.SetTo(validRaces);
    copiedParts[edid] = part;

    if (scTextureSets.TryGetValue(src.TextureSet.FormKey, out var srcTex))
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
        var extraSrc = scHeadParts.Values.FirstOrDefault(h => h.FormKey == extra.FormKey)
            ?? throw new InvalidOperationException($"'{edid}' uses an extra part outside SimpleChildren.esp ({extra.FormKey}); pick another hair");
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
                npc.HeadParts.Add(CopyHeadPart(look.Hair));
                if (look.Eyes != null) npc.HeadParts.Add(CopyHeadPart(look.Eyes));
                if (look.Head != null) npc.HeadParts.Add(CopyHeadPart(look.Head));
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
                    Preset = (short)(female ? look.Skin + 10 : look.Skin),
                });

                if (!kidsByName.TryGetValue(look.Face, out var face))
                    throw new InvalidOperationException($"FacegenForKids.esp has no '{look.Face}'");
                npc.FaceMorph = face.FaceMorph?.DeepCopy();
                npc.FaceParts = face.FaceParts?.DeepCopy();

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
    .WithExtraIncludedMasters(bfOpt.ModKey)
    .Write();

var sb = new StringBuilder();
sb.AppendLine("# Generated by tools/mutagen/BFASC_GenerateSimpleChildren - regenerate rather than hand-edit the FormIDs.");
sb.AppendLine("# Human children only: other races keep whatever child their own add-on (or the fallback) provides.");
sb.AppendLine("# Uses BF's own child race, which the RS Children patch restyles, and answers for the same parent races as the TK Children pack, so run one child pack, not several.");
sb.AppendLine("[AddOn]");
sb.AppendLine("name=BF Simple Children");
sb.AppendLine("description=Spawns the children of Nord, Imperial, Breton and Redguard parents with Simple Children hair, eyes, head textures and skin tones (three looks per sex and race), so they match the other children in a Simple Children game. Faces are computed live by the engine, so no FaceGen files are needed. Do not combine with the RS Children or TK Children add-on.");
sb.AppendLine("author=crajjjj");
sb.AppendLine("type=race");
sb.AppendLine($"required=SimpleChildren.esp,{PluginName}");
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

record Look(string Race, bool Female, string Hair, string? Eyes, string? Head, string HairColor, int Skin, string Face);
