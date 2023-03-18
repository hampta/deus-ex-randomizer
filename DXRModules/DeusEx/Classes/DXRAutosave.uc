class DXRAutosave extends DXRBase transient;

var transient bool bNeedSave;
var config float save_delay;

const Disabled = 0;
const FirstEntry = 1;
const EveryEntry = 2;
const Hardcore = 3;
const ExtraSafe = 4;

function CheckConfig()
{
    if( ConfigOlderThan(1,4,8,0) ) {
        save_delay = default.save_delay;
    }
    Super.CheckConfig();
}

function PostFirstEntry()
{
    Super.PostFirstEntry();
    l("PostFirstEntry() " $ dxr.dxInfo.MissionNumber);
    if( dxr.dxInfo != None && dxr.dxInfo.MissionNumber > 0 && dxr.dxInfo.MissionNumber < 98 && dxr.flags.autosave > 0 ) {
        bNeedSave=true;
    }
}

function ReEntry(bool IsTravel)
{
    Super.ReEntry(IsTravel);
    l("ReEntry() " $ dxr.dxInfo.MissionNumber);
    if( dxr.dxInfo != None && dxr.dxInfo.MissionNumber > 0 && dxr.dxInfo.MissionNumber < 98 && dxr.flags.autosave>=EveryEntry && dxr.flags.autosave != Hardcore && IsTravel ) {
        bNeedSave=true;
    }
}

function PostAnyEntry()
{
    if( bNeedSave )
        SetTimer(save_delay, True);
}

function Timer()
{
    if( bNeedSave )
        doAutosave();
}

static function bool AllowManualSaves(DeusExPlayer player)
{
    local DXRFlags f;
    f = Human(player).GetDXR().flags;
    if( f == None ) return true;
    if( f.autosave == Hardcore ) return false;
    if( f.gamemode == 2 ) return false;// horde mode
    return true;
}

function doAutosave()
{
    local string saveName;
    local DataLinkPlay interruptedDL;
    local #var(PlayerPawn) p;
    local int saveSlot;
    local int lastMission;
    local bool isDifferentMission;

    if( dxr == None ) {
        info("dxr == None, doAutosave() not saving yet");
        SetTimer(save_delay, True);
        return;
    }

    if( dxr.bTickEnabled ) {
        info("dxr.bTickEnabled, doAutosave() not saving yet");
        SetTimer(save_delay, True);
        return;
    }
    if( dxr.flagbase.GetBool('PlayerTraveling') ) {
        info("waiting for PlayerTraveling to be cleared by the MissionScript, not saving yet");
        SetTimer(save_delay, True);
        return;
    }

    p = player();

    if( p.dataLinkPlay != None ) {
        p.dataLinkPlay.AbortDataLink();
        interruptedDL = p.dataLinkPlay;
        p.dataLinkPlay = None;
    }

    //copied from DeusExPlayer QuickSave()
    if (
        (dxr.dxInfo == None) || (dxr.dxInfo.MissionNumber < 0) ||
        ((p.IsInState('Dying')) || (p.IsInState('Paralyzed')) || (p.IsInState('Interpolating'))) ||
        (p.dataLinkPlay != None) || (dxr.Level.Netmode != NM_Standalone) || (p.InConversation())
    ){
        info("doAutosave() not saving yet");
        SetTimer(1.0, True);
        return;
    }

    saveSlot = -3;
    saveName = "DXR " $ dxr.seed $ ": " $ dxr.dxInfo.MissionLocation;
    lastMission = dxr.flags.f.GetInt('Rando_lastmission');
    l("doAutosave() " $ lastMission @ dxr.dxInfo.MissionNumber @ saveName);

    isDifferentMission = lastMission != 0 && dxr.dxInfo.MissionNumber != 0 && lastMission != dxr.dxInfo.MissionNumber;
    if( isDifferentMission || dxr.flags.autosave == ExtraSafe ) {
        saveSlot = 0;
        saveName = "DXR " $ dxr.seed $ ", Mission " $ dxr.dxInfo.MissionNumber $ ": " $ dxr.dxInfo.MissionLocation;
    }
    dxr.flags.f.SetInt('Rando_lastmission', dxr.dxInfo.MissionNumber,, 999);

    bNeedSave = false;
    class'DXRStats'.static.IncDataStorageStat(p, "DXRStats_autosaves");
    p.SaveGame(saveSlot, saveName);
    if( interruptedDL != None ) {
        p.dataLinkPlay = interruptedDL;
        if( interruptedDL.tag != 'dummydatalink' )
            p.ResumeDataLinks();
    }

    SetTimer(0, False);
    info("doAutosave() completed, save_delay: "$save_delay);
}

defaultproperties
{
    save_delay=0.5
}
