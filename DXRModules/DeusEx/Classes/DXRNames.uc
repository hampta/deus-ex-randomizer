class DXRNames extends DXRBase;

function FirstEntry()
{
    local #var(prefix)ScriptedPawn p;
#ifdef hx
    local HXCarcass c;
#else
    local DeusExCarcass c;
#endif
    Super.FirstEntry();

    SetSeed( "DXRNames" );

    foreach AllActors(class'#var(prefix)ScriptedPawn', p)
    {
        GiveRandomName(dxr, p);
    }

#ifdef hx
    foreach AllActors(class'HXCarcass', c)
#else
    foreach AllActors(class'DeusExCarcass', c)
#endif
    {
        if ( c.itemName != "Dead Body" && c.itemName != "Unconscious" && c.itemName != "Animal Carcass" )
            return;
        if ( c.BindName == "PaulDentonCarcass" )
            return;
        c.itemName = c.itemName $ " (" $ RandomName(dxr) $ ")";
    }
}

static function GiveRandomName(DXRando dxr, ScriptedPawn p)
{
    if( p.bImportant ) return;
    p.UnfamiliarName = RandomName(dxr, p);
    p.FamiliarName = p.UnfamiliarName;
}

static function string RandomName(DXRando dxr, optional Actor a)
{
    if ( a != None && a.IsA('#var(prefix)Robot') ) {
        return Caps(RandomNamePart(dxr, 2,4)) $ "-" $ dxr.rng(1000);
    }

    if( dxr.rng(2) == 0 ) {
        return RandomNamePart(dxr, 2, 4) @ RandomNamePart(dxr, 2, 4);
    }

    return RandomNamePart(dxr, 2, 6);
}

static function string RandomNamePart(DXRando dxr, int min, int max)
{
    local string n;
    local bool vowel;
    local int length, num_vowels, num_cons, i, a;
    local string vowels, cons, s;

    vowels = "aeiouy";
    //cons = "bcdfghjklmnpqrstvwxz";
    cons = "bcdfghjklmnprstvwx";

    num_vowels = Len(vowels);
    num_cons = Len(cons);

    length = dxr.rng(max-min+1)+min;
    if( dxr.rng(2) == 0 ) vowel = true;

    for( i=0; i < length; i++ ) {
        if( vowel ) {
            vowel = false;
            a = dxr.rng(num_vowels)+1;
            s = Left(vowels, a);
            s = Right(s, 1);
            n = n $ s;
        } else {
            vowel = true;
            a = dxr.rng(num_cons)+1;
            s = Left(cons, a);
            s = Right(s, 1);
            n = n $ s;
        }
        if ( i == 0 ) n = Caps(n);
    }

    if(InStr(Caps(n), "FAG") != -1) {
        return RandomNamePart(dxr, min, max);
    }
    return n;
}
