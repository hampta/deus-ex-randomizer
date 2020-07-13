class DXRFlags extends DXRBase;

var FlagBase flags;

//rando flags
var int seed;
var int flagsversion;//if you load an old game with a newer version of the randomizer, we'll need to set defaults for new flags
var int brightness, minskill, maxskill, ammo, multitools, lockpicks, biocells, medkits, speedlevel;
var int keysrando;//0=off, 1=dumb, 2=smart, 3=copies
var int doorspickable, doorsdestructible, deviceshackable, passwordsrandomized, gibsdropkeys;//could be bools, but int is more flexible, especially so I don't have to change the flag type
var int autosave;//0=off, 1=first time entering level, 2=every loading screen
var int removeinvisiblewalls, enemiesrandomized;

function Init(DXRando tdxr)
{
    Super.Init(tdxr);

    flags = dxr.Player.FlagBase;
}

function Timer()
{
    Super.Timer();
    if( flags.GetInt('Rando_version') == 0 ) {
        l("flags got deleted, saving again");//the intro deletes all flags
        SaveFlags();
    }
}

function LoadFlags()
{
    l("LoadFlags()");
    seed = flags.GetInt('Rando_seed');
    dxr.seed = seed;

    flagsversion = flags.GetInt('Rando_version');
    brightness = flags.GetInt('Rando_brightness');
    minskill = flags.GetInt('Rando_minskill');
    maxskill = flags.GetInt('Rando_maxskill');
    ammo = flags.GetInt('Rando_ammo');
    multitools = flags.GetInt('Rando_multitools');
    lockpicks = flags.GetInt('Rando_lockpicks');
    biocells = flags.GetInt('Rando_biocells');
    medkits = flags.GetInt('Rando_medkits');
    speedlevel = flags.GetInt('Rando_speedlevel');
    keysrando = flags.GetInt('Rando_keys');
    doorspickable = flags.GetInt('Rando_doorspickable');
    doorsdestructible = flags.GetInt('Rando_doorsdestructible');
    deviceshackable = flags.GetInt('Rando_deviceshackable');
    passwordsrandomized = flags.GetInt('Rando_passwordsrandomized');
    gibsdropkeys = flags.GetInt('Rando_gibsdropkeys');
    autosave = flags.GetInt('Rando_autosave');
    removeinvisiblewalls = flags.GetInt('Rando_removeinvisiblewalls');
    enemiesrandomized = flags.GetInt('Rando_enemiesrandomized');

    if(flagsversion < 1) {
        brightness = 5;
        minskill = 25;
        maxskill = 300;
        ammo = 80;
        multitools = 70;
        lockpicks = 70;
        biocells = 80;
        speedlevel = 1;
        keysrando = 2;
        doorspickable = 100;
        doorsdestructible = 100;
        deviceshackable = 100;
        passwordsrandomized = 100;
        gibsdropkeys = 1;
    }
    if(flagsversion < 2) {
        medkits = 80;
    }
    if(flagsversion <3 ) {
        l("upgrading flags from v"$flagsversion);
        autosave = 1;
        removeinvisiblewalls = 0;
        enemiesrandomized = 50;
        SaveFlags();
    }

    LogFlags("LoadFlags");
}

function SaveFlags()
{
    l("SaveFlags()");
    InitVersion();
    flags.SetInt('Rando_seed', seed,, 999);
    dxr.seed = seed;

    flags.SetInt('Rando_version', flagsversion,, 999);
    flags.SetInt('Rando_brightness', brightness,, 999);
    flags.SetInt('Rando_minskill', minskill,, 999);
    flags.SetInt('Rando_maxskill', maxskill,, 999);
    flags.SetInt('Rando_ammo', ammo,, 999);
    flags.SetInt('Rando_multitools', multitools,, 999);
    flags.SetInt('Rando_lockpicks', lockpicks,, 999);
    flags.SetInt('Rando_biocells', biocells,, 999);
    flags.SetInt('Rando_medkits', medkits,, 999);
    flags.SetInt('Rando_speedlevel', speedlevel,, 999);
    flags.SetInt('Rando_keys', keysrando,, 999);
    flags.SetInt('Rando_doorspickable', doorspickable,, 999);
    flags.SetInt('Rando_doorsdestructible', doorsdestructible,, 999);
    flags.SetInt('Rando_deviceshackable', deviceshackable,, 999);
    flags.SetInt('Rando_passwordsrandomized', passwordsrandomized,, 999);
    flags.SetInt('Rando_gibsdropkeys', gibsdropkeys,, 999);
    flags.SetInt('Rando_autosave', autosave,, 999);
    flags.SetInt('Rando_removeinvisiblewalls', removeinvisiblewalls,, 999);
    flags.SetInt('Rando_enemiesrandomized', enemiesrandomized,, 999);

    LogFlags("SaveFlags");
}

function LogFlags(string prefix)
{
    l(prefix$" - "
        $ "seed: "$seed$", flagsversion: "$flagsversion$", brightness: "$brightness$", minskill: "$minskill$", maxskill: "$maxskill$", ammo: "$ammo
        $ ", multitools: "$multitools$", lockpicks: "$lockpicks$", biocells: "$biocells$", medkits: "$medkits
        $ ", speedlevel: "$speedlevel$", keysrando: "$keysrando$", doorspickable: "$doorspickable$", doorsdestructible: "$doorsdestructible
        $ ", deviceshackable: "$deviceshackable$", passwordsrandomized: "$passwordsrandomized$", gibsdropkeys: "$gibsdropkeys
        $ ", autosave: "$autosave$", removeinvisiblewalls: "$removeinvisiblewalls$", enemiesrandomized: "$enemiesrandomized
    );
}

function InitVersion()
{
    flagsversion = 3;
}

function string VersionString()
{
    return "v1.2";
}
