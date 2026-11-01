// BFATKAA_GenerateTKAAChildren
// Beeing Female NG - The Kids Are Alright child actor pack generator
//
// Writes dist/Addon/BFATKAA:
//   BeeingFemaleTKAAChildren.esp (ESL-flagged) and
//   BeeingFemale/AddOn/BFA_TKAAChildren.ini (the race add-on listing every base).
//
// The plugin holds child actor bases for the ten playable parent races: copies
// of the stock BF child actors, as BeeingFemaleSE_Opt.esp ships them, that take
// their whole look from one of TKAA's children through an NPC template with the
// "Use Traits" flag.
//
// Why a template and not copied face data like the TK Children pack: TKAA builds
// every child head, boys' included, on vanilla's adult female head mesh, and none
// of its children carries face sliders. The child faces exist only as sculpted
// FaceGen files in TKAA.bsa. A templated NPC is drawn with its template's FaceGen,
// so a BF child looks exactly like that TKAA child, race (TKAA's own child races),
// head, skin and voice included. A live-computed face would be a small adult woman.
// The cost: BF's parent hair color and face slider inheritance, written onto the
// child base at birth, has no visible effect on these children.
//
// Templates are TKAA's own children plus the vanilla children it restyles (their
// FaceGen ships in TKAA.bsa too), so a BF child can be a look-alike of a named
// town child. The ghost, skeleton and vampire children are left out.
//
// TKAA.esp is a master: the templates and races live in it. Nothing of TKAA is
// shipped. The INI gates on it with "required=".
//
// HOW TO RUN (from the repo root)
//   dotnet run --project tools/mutagen/BFATKAA_GenerateTKAAChildren -- "<TKAA folder>"
// The folder must contain TKAA.esp and TKAA.bsa (the installed mod folder, or the
// unpacked "The Kids Are Alright Renewal" archive). An optional second argument
// overrides the repo root. Re-run whenever the stock child actors in
// BeeingFemaleSE_Opt.esp change, so the copies pick up the new script properties.

using System.Text;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Archives;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string PluginName = "BeeingFemaleTKAAChildren.esp";
const string IniName = "BFA_TKAAChildren.ini";
const string Prefix = "_BFTKAA_";

if (args.Length < 1)
{
    Console.Error.WriteLine("usage: BFATKAA_GenerateTKAAChildren <TKAA folder> [repo root]");
    return 1;
}
string tkaaDir = args[0];
string repo = args.Length > 1 ? args[1] : Directory.GetCurrentDirectory();
string coreDir = Path.Combine(repo, "dist", "Core");
string outDir = Path.Combine(repo, "dist", "Addon", "BFATKAA");

using var tkaa = SkyrimMod.CreateFromBinaryOverlay(Path.Combine(tkaaDir, "TKAA.esp"), SkyrimRelease.SkyrimSE);
using var bfOpt = SkyrimMod.CreateFromBinaryOverlay(Path.Combine(coreDir, "BeeingFemaleSE_Opt.esp"), SkyrimRelease.SkyrimSE);

// FaceGen of every template must be in TKAA.bsa: without it the engine draws a
// dark or default face, which is exactly what the template is there to avoid.
var faceGen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
var bsa = Archive.CreateReader(GameRelease.SkyrimSE, Path.Combine(tkaaDir, "TKAA.bsa"));
foreach (var file in bsa.Files)
    faceGen.Add(file.Path.Replace('/', '\\'));

// Parent races each group answers to (vampire forms included, they are the same
// people) and the TKAA child race its children are in.
var raceIds = new (string Race, string Label, string Ids, string TkaaRace, string Display)[]
{
    ("Nord", "Nord, Nord Astrid, Nord Vampire, Elder, Elder Vampire",
        "Skyrim:13746,Skyrim:7EAF3,Skyrim:88794,Skyrim:67CD8,Skyrim:A82BA", "TKAANordRace", "Nord"),
    ("Imperial", "Imperial, Imperial Vampire", "Skyrim:13744,Skyrim:88844", "TKAAImperialRace", "Imperial"),
    ("Breton", "Breton, Breton Vampire", "Skyrim:13741,Skyrim:8883C", "TKAABretonRace", "Breton"),
    ("Redguard", "Redguard, Redguard Vampire", "Skyrim:13748,Skyrim:88846", "TKAARedguardRace", "Redguard"),
    ("HighElf", "High Elf, High Elf Vampire", "Skyrim:13743,Skyrim:88840", "TKAAHighElfRace", "High Elf"),
    ("WoodElf", "Wood Elf, Wood Elf Vampire", "Skyrim:13749,Skyrim:88884", "TKAAWoodElfRace", "Wood Elf"),
    ("DarkElf", "Dark Elf, Dark Elf Vampire", "Skyrim:13742,Skyrim:8883D", "TKAADarkElfRace", "Dark Elf"),
    ("Orc", "Orc, Orc Vampire", "Skyrim:13747,Skyrim:A82B9", "TKAAOrcRace", "Orc"),
    ("Khajiit", "Khajiit, Khajiit Vampire", "Skyrim:13745,Skyrim:88845", "TKAAKhajiitRace", "Khajiit"),
    ("Argonian", "Argonian, Argonian Vampire", "Skyrim:13740,Skyrim:8883A", "TKAAArgonianRace", "Argonian"),
};

// Template is the EditorID of a child in TKAA.esp (its own or a vanilla override).
// The number of looks per race and sex follows from this table; TKAA has one boy
// and one girl of each non-human race.
var looks = new Look[]
{
    new("Nord", true, "TKAANordGirl1"), new("Nord", true, "TKAANordGirl2"), new("Nord", true, "TKAASkaalGirl"),
    new("Nord", false, "TKAASkaalBoy"), new("Nord", false, "Frodnar"), new("Nord", false, "Haming"),
    new("Imperial", true, "MilaValentia"),
    new("Imperial", false, "TKAAImperialBoy1"), new("Imperial", false, "Francois"), new("Imperial", false, "Samuel"),
    new("Breton", true, "Erith"),
    new("Breton", false, "BYOHUrchin_Blaise"), new("Breton", false, "ClintonLylvieve"),
    new("Redguard", true, "TKAARedguardGirl1"), new("Redguard", true, "Adara"), new("Redguard", true, "Braith"),
    new("Redguard", false, "BYOHUrchin_Alesan"), new("Redguard", false, "Kayd"),
    new("HighElf", true, "TKAAHighElfGirl1"), new("HighElf", false, "TKAAHighElfBoy1"),
    new("WoodElf", true, "TKAAWoodElfGirl1"), new("WoodElf", false, "TKAAWoodElfBoy1"),
    new("DarkElf", true, "TKAADarkElfGirl1"), new("DarkElf", false, "TKAADarkElfBoy1"),
    new("Orc", true, "TKAAOrcGirl1"), new("Orc", false, "TKAAOrcBoy1"),
    new("Khajiit", true, "TKAAKhajiitGirl1"), new("Khajiit", false, "TKAAKhajiitBoy1"),
    new("Argonian", true, "TKAAArgonianGirl1"), new("Argonian", false, "TKAAArgonianBoy1"),
};

var tkaaNpcs = tkaa.Npcs.ToDictionary(n => n.EditorID!, StringComparer.OrdinalIgnoreCase);
var tkaaRaces = tkaa.Races.ToDictionary(r => r.EditorID!, StringComparer.OrdinalIgnoreCase);

INpcGetter Template(Look look, string tkaaRace)
{
    if (!tkaaNpcs.TryGetValue(look.Template, out var src))
        throw new InvalidOperationException($"TKAA.esp has no child '{look.Template}'");
    bool female = src.Configuration.Flags.HasFlag(NpcConfiguration.Flag.Female);
    if (female != look.Female)
        throw new InvalidOperationException($"'{look.Template}' is a {(female ? "girl" : "boy")}, the table says otherwise");
    if (src.Race.FormKey != tkaaRaces[tkaaRace].FormKey)
        throw new InvalidOperationException($"'{look.Template}' is not in {tkaaRace}");
    if (!src.Template.IsNull)
        throw new InvalidOperationException($"'{look.Template}' is itself templated; pick a child with its own face");
    string face = $"meshes\\actors\\character\\facegendata\\facegeom\\{src.FormKey.ModKey.FileName}\\{src.FormKey.ID:x8}.nif";
    if (!faceGen.Contains(face))
        throw new InvalidOperationException($"TKAA.bsa has no FaceGen for '{look.Template}' ({face})");
    return src;
}

var outMod = new SkyrimMod(ModKey.FromFileName(PluginName), SkyrimRelease.SkyrimSE);
outMod.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small;
outMod.ModHeader.Author = "crajjjj";
outMod.ModHeader.Description = "Beeing Female NG - The Kids Are Alright child actors. Generated by tools/mutagen/BFATKAA_GenerateTKAAChildren.";

var ini = new Dictionary<string, List<string>>();

// Bases are the only records, created in table order, so their FormIDs (801
// onwards) follow from the race list and the looks table alone. Saves store them:
// swapping a look's template is safe, adding, removing or reordering looks is not.
foreach (var (race, _, _, tkaaRace, display) in raceIds)
{
    if (!tkaaRaces.ContainsKey(tkaaRace))
        throw new InvalidOperationException($"TKAA.esp has no race '{tkaaRace}'");
    foreach (bool female in new[] { true, false })
    {
        var raceLooks = looks.Where(l => l.Race == race && l.Female == female).ToArray();
        if (raceLooks.Length == 0)
            throw new InvalidOperationException($"{race} {(female ? "female" : "male")}: no looks");

        foreach (bool player in new[] { false, true })
        {
            string sex = female ? "Female" : "Male";
            string baseId = (player ? "_BFChildActorPlayer_" : "_BFChildActor_") + sex;
            var stock = bfOpt.Npcs.FirstOrDefault(n => n.EditorID == baseId)
                ?? throw new InvalidOperationException($"BeeingFemaleSE_Opt.esp has no '{baseId}'");
            // The stock bases take only their attack data from a vanilla face preset;
            // anything more would be lost when the copies point at a TKAA child.
            if ((stock.Configuration.TemplateFlags & ~NpcConfiguration.TemplateFlag.AttackData) != 0)
                throw new InvalidOperationException($"'{baseId}' now inherits {stock.Configuration.TemplateFlags} from its template; the copies would lose it");

            for (int i = 0; i < raceLooks.Length; i++)
            {
                var template = Template(raceLooks[i], tkaaRace);
                var npc = outMod.Npcs.DuplicateInAsNewRecord(stock);
                npc.EditorID = $"{Prefix}ChildActor{race}{(player ? "Player" : "")}_{sex}{i + 1:00}";
                npc.Name = $"{(player ? "Player " : "")}{display} {(female ? "Girl" : "Boy")}";
                npc.ShortName = female ? "Girl" : "Boy";
                npc.IsCompressed = false;

                // The template supplies race, sex, height, weight, voice, skin, head
                // parts and face; the copy keeps BF's scripts, outfit and AI. The race
                // is set as well because BF reads it from this base (validateBabyCustomRace).
                npc.Template.SetTo(template.FormKey);
                npc.Configuration.TemplateFlags = NpcConfiguration.TemplateFlag.Traits | NpcConfiguration.TemplateFlag.AttackData;
                npc.Configuration.Flags &= ~NpcConfiguration.Flag.IsCharGenFacePreset;
                npc.Race.SetTo(template.Race.FormKey);
                npc.HeadParts.Clear();
                npc.HairColor.Clear();
                npc.FaceMorph = null;
                npc.FaceParts = null;
                npc.TintLayers.Clear();
                npc.TextureLighting = null;

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
    .WithLoadOrder(new[] { "Skyrim.esm", "Update.esm", "Dawnguard.esm", "HearthFires.esm", "Dragonborn.esm", "BeeingFemale.esm", "TKAA.esp", "BeeingFemaleBasicAddOn.esp", "BeeingFemaleSE_Opt.esp" }.Select(name => ModKey.FromFileName(name)).ToArray())
    .WithNoDataFolder()
    .Write();

var sb = new StringBuilder();
sb.AppendLine("# Generated by tools/mutagen/BFATKAA_GenerateTKAAChildren - regenerate rather than hand-edit the FormIDs.");
sb.AppendLine("# Every child looks exactly like one TKAA child (an NPC template), in TKAA's child race of its parents.");
sb.AppendLine("# Answers for the same parent races as the RS Children, Simple Children and TK Children packs, so run one child pack, not several.");
sb.AppendLine("[AddOn]");
sb.AppendLine("name=BF TKAA Children");
sb.AppendLine("description=Spawns the children of all ten playable races in The Kids Are Alright's child races, each looking like one of TKAA's children (its own and the vanilla ones it restyles), so they match the other children in a TKAA game. Faces come from TKAA's FaceGen, so children don't take their parents' hair color or features. Do not combine with the RS Children, Simple Children or TK Children add-on.");
sb.AppendLine("author=crajjjj");
sb.AppendLine("type=race");
sb.AppendLine($"required=TKAA.esp,{PluginName}");
sb.AppendLine();
sb.AppendLine("enabled=true");
sb.AppendLine("hidden=false");
sb.AppendLine("locked=false");
sb.AppendLine();
sb.AppendLine($"races={raceIds.Length}");
for (int r = 0; r < raceIds.Length; r++)
{
    var (race, label, ids, _, _) = raceIds[r];
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

Console.WriteLine($"{pluginPath}: {outMod.Npcs.Count} child actors");
Console.WriteLine(iniPath);
return 0;

record Look(string Race, bool Female, string Template);
