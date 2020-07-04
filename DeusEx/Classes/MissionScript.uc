//=============================================================================
// MissionScript.
//=============================================================================
class MissionScript extends Info
	transient
	abstract;

//
// State machine for each mission
// All flags set by this mission controller script should be
// prefixed with MS_ for consistency
//

var float checkTime;
var DeusExPlayer Player;
var FlagBase flags;
var string localURL;
var DeusExLevelInfo dxInfo;
var int seed;
var int newseed;

// ----------------------------------------------------------------------
// PostPostBeginPlay()
//
// Set the timer
// ----------------------------------------------------------------------

function PostPostBeginPlay()
{
    local name flagName;

	// start the script
	SetTimer(checkTime, True);
}

// ----------------------------------------------------------------------
// InitStateMachine()
//
// Get the player's flag base, get the map name, and set the player
// ----------------------------------------------------------------------

function InitStateMachine()
{
	local DeusExLevelInfo info;

	Player = DeusExPlayer(GetPlayerPawn());

	foreach AllActors(class'DeusExLevelInfo', info)
		dxInfo = info;

	if (Player != None)
	{
		flags = Player.FlagBase;

		// Get the mission number by extracting it from the
		// DeusExLevelInfo and then delete any expired flags.
		//
		// Also set the default mission expiration so flags
		// expire in the next mission unless explicitly set
		// differently when the flag is created.

		if (flags != None)
		{
			// Don't delete expired flags if we just loaded
			// a savegame
			if (flags.GetBool('PlayerTraveling'))
				flags.DeleteExpiredFlags(dxInfo.MissionNumber);

			flags.SetDefaultExpiration(dxInfo.MissionNumber + 1);

			localURL = Caps(dxInfo.mapName);

			log("**** InitStateMachine() -"@player@"started mission state machine for"@localURL);
		}
		else
		{
			log("**** InitStateMachine() - flagBase not set - mission state machine NOT initialized!");
		}
	}
	else
	{
		log("**** InitStateMachine() - player not set - mission state machine NOT initialized!");
	}
}

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local name flagName;
	local ScriptedPawn P;
	local int i;

	flags.DeleteFlag('PlayerTraveling', FLAG_Bool);

	// Check to see which NPCs should be dead from prevous missions
	foreach AllActors(class'ScriptedPawn', P)
	{
		if (P.bImportant)
		{
			flagName = Player.rootWindow.StringToName(P.BindName$"_Dead");
			if (flags.GetBool(flagName))
				P.Destroy();
		}
	}

	// print the mission startup text only once per map
	flagName = Player.rootWindow.StringToName("M"$Caps(dxInfo.mapName)$"_StartupText");
	if (!flags.GetBool(flagName))
	{
        Rando();
        if (dxInfo.startupMessage[0] != "")
        {
    		for (i=0; i<ArrayCount(dxInfo.startupMessage); i++)
	    		DeusExRootWindow(Player.rootWindow).hud.startDisplay.AddMessage(dxInfo.startupMessage[i]);
		    DeusExRootWindow(Player.rootWindow).hud.startDisplay.StartMessage();
        }
		flags.SetBool(flagName, True);
	}

	flagName = Player.rootWindow.StringToName("M"$dxInfo.MissionNumber$"MissionStart");
	if (!flags.GetBool(flagName))
	{
		// Remove completed Primary goals and all Secondary goals
		Player.ResetGoals();

		// Remove any Conversation History.
		Player.ResetConversationHistory();

		// Set this flag so we only get in here once per mission.
		flags.SetBool(flagName, True);
	}
}

// ----------------------------------------------------------------------
// PreTravel()
// 
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
	// turn off the timer
	SetTimer(0, False);

	// zero the flags so FirstFrame() gets executed at load
	flags = None;
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
    local FlagBase f;
    local name flagName;

	// make sure our flags are initialized correctly
	if (flags == None)
	{
        //load seed flag from the new game before the intro deletes all flags
        f = DeusExPlayer(GetPlayerPawn()).FlagBase;
        flagName = 'Rando_seed';
        seed = f.GetInt(flagName);
        //if( self.Class == class'MissionIntro' )
        //    f.SetInt(flagName, seed,, 999);

		InitStateMachine();

		// Don't want to do this if the user just loaded a savegame
		if ((player != None) && (flags.GetBool('PlayerTraveling')))
			FirstFrame();
        
        //save the seed flag again after the intro deletes all flags
        if( self.Class == class'MissionIntro' )
            f.SetInt(flagName, seed,, 999);

        RandoEnter();
	}
}

// ----------------------------------------------------------------------
// GetPatrolPoint()
// ----------------------------------------------------------------------

function PatrolPoint GetPatrolPoint(Name patrolTag, optional bool bRandom)
{
	local PatrolPoint aPoint;

	aPoint = None;

	foreach AllActors(class'PatrolPoint', aPoint, patrolTag)
	{
		if (bRandom && (FRand() < 0.5))
			break;
		else
			break;
	}

	return aPoint;
}

// ----------------------------------------------------------------------
// GetSpawnPoint()
// ----------------------------------------------------------------------

function SpawnPoint GetSpawnPoint(Name spawnTag, optional bool bRandom)
{
	local SpawnPoint aPoint;

	aPoint = None;

	foreach AllActors(class'SpawnPoint', aPoint, spawnTag)
	{
		if (bRandom && (FRand() < 0.5))
			break;
		else
			break;
	}

	return aPoint;
}

function Rando()
{
    local ScriptedPawn p;
    local DeusExCarcass c;
    local Weapon inv;
    local Augmentation anAug;

    SetSeed(seed + ( dxInfo.MissionNumber * 107 ) + Len(dxInfo.mapName) );//need to hash the map name string better, maybe use this http://www.unrealtexture.com/Unreal/Downloads/3DEditing/UnrealEd/Tutorials/unrealwiki-offline/crc32.html

    log("randomizing "$dxInfo.mapName$" using seed " $ seed);

    if( Level.AmbientBrightness<100 ) Level.AmbientBrightness += 1;

    if( self.Class == class'MissionIntro' )
    { // extra randomization in the intro for the lolz
        RandomizeIntro();
        return;
    }

    if( self.Class == class'Mission01' && localURL == "01_NYC_UNATCOISLAND" )
    {
        anAug = Player.AugmentationSystem.GivePlayerAugmentation(class'AugSpeed');
        //anAug.CurrentLevel = 1;//anAug.MaxLevel;
    }

    SwapAll('Inventory');
    SwapAll('Containers');

    RandomizeAugCannisters();
    ReduceAmmo(0.8);
    //ReduceSpawns('Inventory', 0);//no items, even for enemies
    ReduceSpawns('Multitool', 50);
    ReduceSpawns('Lockpick', 50);

    /*foreach AllActors(class'ScriptedPawn', p)
    {
        if( p.bIsPlayer ) continue;
        inv = spawn(class'WeaponAssaultGun');
        inv.GiveTo(p);
        inv.SetBase(p);

        inv.AmmoType = spawn(inv.AmmoName);
        inv.AmmoType.InitialState='Idle2';
        inv.AmmoType.GiveTo(p);
        inv.AmmoType.SetBase(p);

        p.SetupWeapon(false);
    }*/

    /*foreach AllActors(class'DeusExCarcass', c)
    {
        inv = spawn(class'WeaponAssaultGun', self);
        c.AddInventory(inv);
    }*/

    log("done randomizing "$dxInfo.mapName);
}

function SwapAll(name classname)
{
    local Actor a, b;
    local int num, i, slot;
    num=0;
    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;
        num++;
    }

    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;

        i=0;
        slot=Rng(num-1);
        foreach AllActors(class'Actor', b )
        {
            if( SkipActor(b, classname) ) continue;

            if(i==slot) {
                Swap(a, b);
                break;
            }
            i++;
        }
    }
}

function bool CarriedItem(Actor a)
{
    return a.Owner != None && a.Owner.IsA('Pawn');
    //return ! (a.Owner == None || a.Owner.IsA('Conatiners') || a.Owner.IsA('Carcass') );
}

function bool SkipActor(Actor a, name classname)
{
    //( Pawn(a.Owner) != None )
    return ( ! a.IsA(classname) ) || ( a.Owner != None ) || a.bStatic || a.bHidden || a.IsA('BarrelAmbrosia') || a.IsA('BarrelVirus');
}

function Swap(Actor a, Actor b)
{
    local vector newloc;
    local rotator newrot;

    if( a == b ) return;

    log("swapping "$a.Class$" and "$b.Class);

    newloc = b.Location + (a.CollisionHeight - b.CollisionHeight) * vect(0,0,1);
    newrot = b.Rotation;

    b.SetLocation(a.Location + (b.CollisionHeight - a.CollisionHeight) * vect(0,0,1) );
    b.SetRotation(a.Rotation);

    a.SetLocation(newloc);
    a.SetRotation(newrot);

    //a.SetPhysics(PHYS_Falling);
    //b.SetPhysics(PHYS_Falling);
}

function RandomizeAugCannisters()
{
    local AugmentationCannister a;
    local int augIndex;
    local int numAugs;

    if( Player == None ) return;

    numAugs=0;

    for(augIndex=0; augIndex<arrayCount(Player.AugmentationSystem.augClasses); augIndex++)
    {
        if (Player.AugmentationSystem.augClasses[augIndex] != None)
        {
            numAugs=augIndex+1;
        }
    }

    foreach AllActors(class'AugmentationCannister', a)
    {
        a.AddAugs[0] = PickRandomAug(numAugs);
        a.AddAugs[1] = a.AddAugs[0];
        while( a.AddAugs[1] == a.AddAugs[0] )
        {
            a.AddAugs[1] = PickRandomAug(numAugs);
        }
    }
}

function Name PickRandomAug(int numAugs)
{
    local int slot;
    slot = Rng(numAugs-1);
    return Player.AugmentationSystem.augClasses[slot].Name;
}

function ReduceAmmo(float mult)
{
    local Weapon w;
    local Ammo a;

    foreach AllActors(class'Weapon', w)
    {
        if( w.PickupAmmoCount > 0 )
            w.PickupAmmoCount = Clamp(w.PickupAmmoCount * mult, 1, 99999);
    }

    foreach AllActors(class'Ammo', a)
    {
        if( a.AmmoAmount > 0 && ( ! CarriedItem(a) ) )
            a.AmmoAmount = Clamp(a.AmmoAmount * mult, 1, 99999);
    }
}

function ReduceSpawns(name classname, int percent)
{
    local Actor a;
    local Containers d;

    foreach AllActors(class'Actor', a)
    {
        //if( SkipActor(a, classname) ) continue;
        if( a == Player ) continue;
        if( a.Owner == Player ) continue;
        if( ! a.IsA(classname) ) continue;

        if( Rng(100) >= percent )
        {
	        DestroyActor( a );
        }
    }

    foreach AllActors(class'Containers', d)
    {
        log("DXRando found Decoration " $ d.Name $ " with Contents: " $ d.Contents $ ", looking for " $ classname);
        if( Rng(100) >= percent ) {
            if( ClassIsA( d.Contents, classname) ) d.Contents = d.Content2;
            if( ClassIsA( d.Contents, classname) ) d.Content2 = d.Content3;
            if( ClassIsA( d.Contents, classname) ) d.Content3 = None;
        }
    }
}

function bool ClassIsA(class<actor> class, name classname)
{
    // there must be a better way to do this...
    local actor a;
    local bool ret;
    if(class == None) return ret;

    //return class<classname>(class) != None;

    a = Spawn(class);
    ret = a.IsA(classname);
    a.Destroy();
    return ret;
}

function RandomizeIntro()
{
    local Tree t;

    foreach AllActors(class'Tree', t)
    { // exclude 80% of trees from the SwapAll by temporarily hiding them
        if( Rng(100) < 80 ) t.bHidden = true;
    }
    SwapAll('Actor');
    foreach AllActors(class'Tree', t)
    {
        t.bHidden = false;
    }
}

function RandoEnter()
{
    local DeusExMover d;
    local Terrorist t;
    local NanoKey key;
    local HackableDevices h;

    //return;// disabled for now

    //log("test");
    RandoSkills();

    foreach AllActors(class'DeusExMover', d)
    {
        if( d.bPickable == false && d.bBreakable == false && (d.KeyIDNeeded$"") != "None" ) {
            log("DXRando found unpickable and unbreakable door class: " $ d.Class $ ", tag: " $ d.Tag $ ", name: " $ d.Name $ " in " $ dxInfo.mapName $ " with KeyIDNeeded: " $ d.KeyIDNeeded);
            d.bPickable = true;
            d.bBreakable = true;
            d.minDamageThreshold = 50;
            d.lockStrength = 1;
            d.doorStrength = 1;
            d.initiallockStrength = 1;
        }
    }

    foreach AllActors(class'NanoKey', key)
    {
        log("DXRando found key class: " $ key.Class $ ", tag: " $ key.Tag $ ", name: " $ key.Name $ ", KeyID: " $ key.KeyID $ " in " $ dxInfo.mapName);
    }

    foreach AllActors(class'HackableDevices', h)
    {
        if( h.bHackable == false ) {
            log("DXRando found unhackable device class: " $ h.Class $ ", tag: " $ h.Tag $ ", name: " $ h.Name $ " in " $ dxInfo.mapName);
            h.bHackable = true;
            h.hackStrength = 1;
            h.initialhackStrength = 1;
        }
    }

    /*if( dxInfo.mapName == "03_NYC_MolePeople" )
    {
        foreach AllActors(class'DeusExMover', d)
        {
            if( d.Name == 'DeusExMover65' ) {
                Player.ClientMessage("found DeusExMover65");
                d.bPickable = true;
                d.bBreakable = true;
                Player.ClientMessage("fixed DeusExMover65");
            }
        }
        
        foreach AllActors(class'Terrorist', t)
        {
            if( t.name == 'Terrorist33' )
            {
                key = spawn(class'NanoKey', self);
                key.KeyID = 'MoleRestroomKey';
                t.AddInventory(key);
            }
        }
    }*/
}

function RandoSkills()
{
    local Skill aSkill;
    local int i;
    local int percent;

    log("randomizing skills with seed " $ seed);
    SetSeed(seed);

    aSkill = Player.SkillSystem.FirstSkill;
	while(aSkill != None)
	{
        percent = Rng(375) + 25;
        for(i=0; i<arrayCount(aSkill.Cost); i++)
        {
    		aSkill.Cost[i] = aSkill.default.Cost[i] * percent / 100;
        }
		aSkill = aSkill.next;
	}
}

function bool DestroyActor( Actor d )
{
	// If this item is in an inventory chain, unlink it.
	//local actor Link;
    local Decoration downer;

    if( d.IsA('Inventory') && d.Owner != None && d.Owner.IsA('Pawn') )
    {
        Pawn(d.Owner).DeleteInventory( Inventory(d) );
    }
    /*else if( d.IsA('Inventory') && d.Owner != None && d.Owner.IsA('Decoration') ) {
        downer = Decoration(d.Owner);
        log("DXRando DestroyActor " $ downer.Name);
        if( downer.contents == d.Class ) downer.contents = downer.content2;
        if( downer.content2 == d.Class ) downer.content2 = downer.content3;
        if( downer.content3 == d.Class ) downer.content3 = None;

        Inventory(d).SetOwner(None);
    }*/
    return d.Destroy();
    //d.bHidden = True;
}

function int SetSeed(int s)
{
    newseed = s;
}

function int Rng(int max)
{
    local int gen1, gen2;
    gen2 = 2147483643;
    gen1 = gen2/2;
    newseed = gen1 * newseed * 5 + gen2 + (newseed/5) * 3;
    newseed = abs(newseed);
    return newseed % max;
}

defaultproperties
{
     checkTime=1.000000
     localURL="NOTHING"
}
