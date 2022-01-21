class DXRMenuSetupRando extends DXRMenuBase;

var float combatDifficulty;

event InitWindow()
{
    Super.InitWindow();
}

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        num_rows=default.num_rows;
        num_cols=default.num_cols;
        col_width_odd=default.col_width_odd;
        col_width_even=default.col_width_even;
        row_height=default.row_height;
        padding_width=default.padding_width;
        padding_height=default.padding_height;
    }
    Super.CheckConfig();
}

function BindControls(bool writing, optional string action)
{
    local DXRFlags f;
    local string doors_option, skills_option, locations_option;
    local int iDifficulty;
    Super.BindControls(writing, action);
    f = InitFlags();

    NewGroup("General");
    NewMenuItem("Brightness (0-255) +", "Increase the brightness of dark areas.");
    Slider(f.brightness, 0, 255, writing);

    NewMenuItem("Combat Difficulty %", "Multiply the damage the player takes. The original game uses 400% for realistic.");
    iDifficulty = int(combatDifficulty * 100.0);
    Slider(iDifficulty, 0, 500, writing);
    combatDifficulty = float(iDifficulty) / 100.0;

    NewMenuItem("", "Randomize goal locations, starting locations, or both");
    locations_option = f.settings.startinglocations $";"$ f.settings.goals;
    EnumOptionString("Randomize Goal and Starting Locations", "100;100", writing, locations_option);
    EnumOptionString("Randomize Starting Locations", "100;0", writing, locations_option);
    EnumOptionString("Randomize Goal Locations", "0;100", writing, locations_option);
    EnumOptionString("Unchanged Goal and Starting Locations", "0;0", writing, locations_option);
    f.settings.startinglocations = UnpackInt(locations_option);
    f.settings.goals = UnpackInt(locations_option);

    NewMenuItem("Medbots", "Percentage chance for a medbot to spawn in a map (vanilla is about 14%)");
    Slider(f.settings.medbots, 0, 100, writing);

    NewMenuItem("Repair bots", "Percentage chance for a repair bot to spawn in a map (vanilla is about 14%)");
    Slider(f.settings.repairbots, 0, 100, writing);

    NewMenuItem("Move Turrets", "Randomizes locations of turrets, cameras, and security computers for them.");
    Slider(f.settings.turrets_move, 0, 100, writing);

    NewMenuItem("Add Turrets", "Randomly adds turrets, cameras, and security computers for them.");
    Slider(f.settings.turrets_add, 0, 100, writing);

    NewMenuItem("The Merchant Chance %", "The chance for The Merchant to appear in each map.");
    Slider(f.settings.merchants, 0, 100, writing);

    NewMenuItem("", "Help with finding passwords from your notes.");
    EnumOption("Autofill Passwords", 2, writing, f.codes_mode);
    EnumOption("Mark Known Passwords", 1, writing, f.codes_mode);
    EnumOption("No Assistance With Passwords", 0, writing, f.codes_mode);

    NewMenuItem("Dancing %", "How many characters should be dancing.");
    Slider(f.settings.dancingpercent, 0, 100, writing);

    NewGroup("Doors and Keys");
    NewMenuItem("", "Additional options to get through doors that normally can't be destroyed or lockpicked.");
    doors_option = f.settings.doorsmode $ ";" $ f.settings.doorsdestructible $ ";" $ f.settings.doorspickable;
    //I could make this dual column? "Key-Only Doors" on the left and then "Breakable or Pickable" on the right? or should it be 2 rows?
    EnumOptionString("Key-Only Doors Breakable or Pickable", (f.keyonlydoors+f.doormutuallyexclusive)$";50;50", writing, doors_option);
    EnumOptionString("Key-Only Doors Breakable & Pickable", (f.keyonlydoors+f.doormutuallyinclusive)$";100;100", writing, doors_option);
    EnumOptionString("Key-Only Doors Breakable", (f.keyonlydoors+f.doorindependent)$";100;0", writing, doors_option);
    EnumOptionString("Key-Only Doors Pickable", (f.keyonlydoors+f.doorindependent)$";0;100", writing, doors_option);
    EnumOptionString("Some Doors Breakable or Pickable", (f.keyonlydoors+f.doormutuallyexclusive)$";25;25", writing, doors_option);
    EnumOptionString("Some Doors Breakable & Pickable", (f.keyonlydoors+f.doormutuallyinclusive)$";50;50", writing, doors_option);
    EnumOptionString("Some Doors Breakable", (f.keyonlydoors+f.doorindependent)$";50;0", writing, doors_option);
    EnumOptionString("Some Doors Pickable", (f.keyonlydoors+f.doorindependent)$";0;50", writing, doors_option);
    EnumOptionString("Undefeatable Doors Breakable or Pickable", (f.undefeatabledoors+f.doormutuallyexclusive)$";50;50", writing, doors_option);
    EnumOptionString("Undefeatable Doors Breakable & Pickable", (f.undefeatabledoors+f.doormutuallyinclusive)$";100;100", writing, doors_option);
    EnumOptionString("Undefeatable Doors Breakable", (f.undefeatabledoors+f.doorindependent)$";100;0", writing, doors_option);
    EnumOptionString("Undefeatable Doors Pickable", (f.undefeatabledoors+f.doorindependent)$";0;100", writing, doors_option);
    EnumOptionString("Doors Unchanged", "0;0;0", writing, doors_option);
    EnumOptionString("All Doors Breakable or Pickable", (f.alldoors+f.doormutuallyexclusive)$";50;50", writing, doors_option);
    EnumOptionString("All Doors Breakable & Pickable", (f.alldoors+f.doormutuallyinclusive)$";100;100", writing, doors_option);
    EnumOptionString("All Doors Breakable", (f.alldoors+f.doorindependent)$";100;0", writing, doors_option);
    EnumOptionString("All Doors Pickable", (f.alldoors+f.doorindependent)$";0;100", writing, doors_option);
    f.settings.doorsmode = UnpackInt(doors_option);
    f.settings.doorsdestructible = UnpackInt(doors_option);
    f.settings.doorspickable = UnpackInt(doors_option);

    NewMenuItem("NanoKey Locations", "Move keys around the map.");
    EnumOption("Randomized", 4, writing, f.settings.keysrando);
    EnumOption("Unchanged", 0, writing, f.settings.keysrando);

    NewGroup("Passwords");
    NewMenuItem("Electronic Devices", "Provide additional options for keypads and electronic panels.");
    EnumOption("All Hackable", 100, writing, f.settings.deviceshackable);
    EnumOption("Some Hackable", 50, writing, f.settings.deviceshackable);
    EnumOption("Unchanged", 0, writing, f.settings.deviceshackable);

    NewMenuItem("Passwords", "Forces you to look for passwords and passcodes.");
    EnumOption("Randomized", 100, writing, f.settings.passwordsrandomized);
    EnumOption("Unchanged", 0, writing, f.settings.passwordsrandomized);

    NewMenuItem("Datacubes Locations", "Moves datacubes and other information objects around the map.");
    EnumOption("Randomized", 100, writing, f.settings.infodevices);
    EnumOption("Unchanged", 0, writing, f.settings.infodevices);

    NewGroup("Enemies");
    NewMenuItem("Enemy Randomization %", "How many additional enemies to add and how much to randomize their weapons.");
    Slider(f.settings.enemiesrandomized, 0, 100, writing);

    NewMenuItem("Non-Human Chance %", "Reduce the chance of new enemies being non-humans.");
    Slider(f.settings.enemies_nonhumans, 0, 100, writing);

    NewMenuItem("Enemy Respawn Seconds", "(Beta) How many seconds for enemies to respawn. Leave blank or 0 to disable");
    Slider(f.settings.enemyrespawn, 0, 100, writing);

    NewGroup("Skills");
    NewMenuItem("", "Adjust how skill cost randomization works.");
    skills_option = f.settings.skills_disable_downgrades $";"$ f.settings.skills_reroll_missions $";"$ f.settings.skills_independent_levels;
    EnumOptionString("Normal Skill Randomization", "0;0;0", writing, skills_option);
    EnumOptionString("Normal Skills Every Mission", "0;1;0", writing, skills_option);
    EnumOptionString("Normal Skills Every 2 Missions", "0;2;0", writing, skills_option);
    EnumOptionString("Normal Skills Every 3 Missions", "0;3;0", writing, skills_option);
    EnumOptionString("Normal Skills Every 5 Missions", "0;5;0", writing, skills_option);
    EnumOptionString("Blind Skill Randomization", "5;0;100", writing, skills_option);
    EnumOptionString("Blind Skills Every Mission", "5;1;100", writing, skills_option);
    EnumOptionString("Blind Skills Every 2 Missions", "5;2;100", writing, skills_option);
    EnumOptionString("Blind Skills Every 3 Missions", "5;3;100", writing, skills_option);
    EnumOptionString("Blind Skills Every 5 Missions", "5;5;100", writing, skills_option);
    f.settings.skills_disable_downgrades = UnpackInt(skills_option);
    f.settings.skills_reroll_missions = UnpackInt(skills_option);
    f.settings.skills_independent_levels = UnpackInt(skills_option);

    NewMenuItem("Minimum Skill Cost %", "Minimum cost for skills in percentage of the original cost.");
    Slider(f.settings.minskill, 0, 1000, writing);

    NewMenuItem("Maximum Skill Cost %", "Maximum cost for skills in percentage of the original cost.");
    Slider(f.settings.maxskill, 0, 1000, writing);

    NewMenuItem("Banned Skills %", "Chance of a skill having a cost of 99,999 points.");
    Slider(f.settings.banned_skills, 0, 100, writing);

    NewMenuItem("Banned Skill Levels %", "Chance of a certain level of a skill having a cost of 99,999 points.");
    Slider(f.settings.banned_skill_levels, 0, 100, writing);

    NewMenuItem("Skill Strength Rando %", "How much to randomize the strength of skills.");
    Slider(f.settings.skill_value_rando, 0, 300, writing);

    NewGroup("Items");
    NewMenuItem("Ammo Drops %", "Make ammo more scarce.");
    Slider(f.settings.ammo, 0, 100, writing);

    NewMenuItem("Multitools Drops %", "Make multitools more scarce.");
    Slider(f.settings.multitools, 0, 100, writing);

    NewMenuItem("Lockpicks Drops %", "Make lockpicks more scarce.");
    Slider(f.settings.lockpicks, 0, 100, writing);

    NewMenuItem("Bioelectric Cells Drops %", "Make bioelectric cells more scarce.");
    Slider(f.settings.biocells, 0, 100, writing);

    NewMenuItem("Medkit Drops %", "Make medkits more scarce.");
    Slider(f.settings.medkits, 0, 100, writing);

    NewMenuItem("Starting Equipment", "How many random items you start with");
    Slider(f.settings.equipment, 0, 10, writing);

    NewMenuItem("Swap Items %", "The chance for item positions to be swapped.");
    Slider(f.settings.swapitems, 0, 100, writing);

    NewMenuItem("Swap Containers %", "The chance for container positions to be swapped.");
    Slider(f.settings.swapcontainers, 0, 100, writing);

    NewMenuItem("Min Weapon Damage %", "The minmum damage for weapons.");
    Slider(f.settings.min_weapon_dmg, 0, 300, writing);

    NewMenuItem("Max Weapon Damage %", "The maximum damage for weapons.");
    Slider(f.settings.max_weapon_dmg, 0, 300, writing);

    NewMenuItem("Min Weapon Shot Time %", "The minmum shot time / firing speed for weapons.");
    Slider(f.settings.min_weapon_shottime, 0, 300, writing);

    NewMenuItem("Max Weapon Shot Time %", "The maximum shot time / firing speed for weapons.");
    Slider(f.settings.max_weapon_shottime, 0, 300, writing);

    NewGroup("Augmentations");
    NewMenuItem("Speed Aug Level", "Start the game with the Speed Enhancement augmentation.");
    Slider(f.settings.speedlevel, 0, 3, writing);

    NewMenuItem("Aug Cans Randomized %", "The chance for aug cannisters to have their contents changed.");
    Slider(f.settings.augcans, 0, 100, writing);

    NewMenuItem("Aug Strength Rando %", "How much to randomize the strength of augmentations.");
    Slider(f.settings.aug_value_rando, 0, 300, writing);

    if( action == "NEXT" ) _InvokeNewGameScreen(combatDifficulty, InitDxr());
}

function SetDifficulty(float newDifficulty)
{
    combatDifficulty = newDifficulty;
}

defaultproperties
{
    num_rows=13
    num_cols=4
    col_width_odd=160
    col_width_even=140
    row_height=20
    padding_width=20
    padding_height=10
    Title="DX Rando Options"
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
}
