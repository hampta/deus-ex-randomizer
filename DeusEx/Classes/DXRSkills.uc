class DXRSkills extends DXRBase;

struct SkillCostMultiplier {
    var string type;//you can use "Skill" to make it apply to all skills
    var int percent;//percent to multiply, stacks
    var int minLevel;//the first skill level this adjustment will apply to
    var int maxLevel;//the highest skill level this adjustment will apply to
};

var config SkillCostMultiplier SkillCostMultipliers[16];
var config int reroll_missions;
var config bool independent_levels;

function CheckConfig()
{
    local int i;
    if( config_version < 4 ) {
        for(i=0; i < ArrayCount(SkillCostMultipliers); i++) {
            SkillCostMultipliers[i].type = "";
            SkillCostMultipliers[i].percent = 100;
            SkillCostMultipliers[i].minLevel = 1;
            SkillCostMultipliers[i].maxLevel = ArrayCount(class'Skill'.default.Cost);
        }
    }
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,4) ) {
        independent_levels = false;
        reroll_missions = 0;
    }
    Super.CheckConfig();
}

function AnyEntry()
{
    Super.AnyEntry();
    RandoSkills();
}

function RandoSkills()
{
    local Skill aSkill;
    local int i, m;
    local int percent, mission_group;
    local float f;
    local SkillCostMultiplier scm;
    local class<Skill> c;

    l("randomizing skills with seed " $ dxr.seed $ ", min: "$dxr.flags.minskill$", max: "$dxr.flags.maxskill $", reroll_missions: "$reroll_missions $", independent_levels: "$independent_levels);
    if( reroll_missions == 0 )
        dxr.SetSeed(dxr.seed);
    else {
        if( dxr.dxInfo != None )
            mission_group = dxr.dxInfo.missionNumber / reroll_missions;
        i = dxr.Crc(dxr.seed $"M"$ mission_group);
        dxr.SetSeed( i );
    }

    if( dxr.flags.minskill > dxr.flags.maxskill ) dxr.flags.maxskill = dxr.flags.minskill;

    aSkill = dxr.Player.SkillSystem.FirstSkill;
    while(aSkill != None)
    {
        percent = rng(dxr.flags.maxskill - dxr.flags.minskill + 1) + dxr.flags.minskill;
        l( aSkill.Class.Name $ " percent: "$percent$"%");
        for(i=0; i<arrayCount(aSkill.Cost); i++)
        {
            if( independent_levels ) {
                percent = rng(dxr.flags.maxskill - dxr.flags.minskill + 1) + dxr.flags.minskill;
                l( aSkill.Class.Name $ " lvl: "$(i+1)$", percent: "$percent$"%");
            }

            f = float(aSkill.default.Cost[i]) * float(percent) / 100.0;
            for(m=0; m < ArrayCount(SkillCostMultipliers); m++) {
                scm = SkillCostMultipliers[m];
                if( scm.type == "" ) continue;
                c = class<Skill>(GetClassFromString(scm.type, class'Skill'));
                if( aSkill.IsA(c.name) && i+1 >= scm.minLevel && i < scm.maxLevel ) {
                    f *= float(scm.percent) / 100.0;
                }
            }
            aSkill.Cost[i] = int(f);
        }
        aSkill = aSkill.next;
    }
}
