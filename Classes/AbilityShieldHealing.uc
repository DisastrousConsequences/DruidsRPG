class AbilityShieldHealing extends CostRPGAbility
	config(UT2004RPG)
	abstract;
	
var config float ShieldHealingPercent;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local Inventory OInv;
	local RW_EngineerLink EGun;
	local ArtifactShieldBlast ASB;
	local bool bGotAM;
	local RPGStatsInv StatsInv;
	local int x;

	if(Monster(Other) != None)
		return; //Not for pets

	EGun = None;
	// Now let's see if they have an EngineerLinkGun
	for (OInv=Other.Inventory; OInv != None; OInv = OInv.Inventory)
	{
		if(ClassIsChildOf(OInv.Class,class'RW_EngineerLink'))
		{
			EGun = RW_EngineerLink(OInv);
			break;
		}
	}
	if (EGun != None)
	{	// ok, they already have the EngineerLink. Let's set their healing level. If not, it will be set when they add the link
		// code duplicated in AbilityLoadedEngineer.SetShieldHealingLevel
		EGun.HealingLevel = AbilityLevel;
		EGun.ShieldHealingPercent = default.ShieldHealingPercent;
	}

	bGotAM = false;

	// now check if we get the other hybrid artifacts
	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));

	for (x = 0; StatsInv != None && x < StatsInv.Data.Abilities.length; x++)
	{
		if (StatsInv.Data.Abilities[x] == class'DruidArtifactLoaded')
		{
		    if (StatsInv.Data.AbilityLevels[x] >= 2)
		        bGotAM = true;
		}
	}
	
	if(AbilityLevel == 3 || bGotAM)
	{
		// lets give them the shield blast
		ASB = ArtifactShieldBlast(Other.FindInventoryType(class'ArtifactShieldBlast'));
		if(ASB == None)
		{
			ASB = Other.spawn(class'ArtifactShieldBlast', Other,,, rot(0,0,0));
			if(ASB == None)
				return; //get em next pass I guess?

			ASB.giveTo(Other);
			if(Other.SelectedItem == None)
				Other.NextItem();
		}
	}
}

defaultproperties
{
     AbilityName="Shield Healing"
     Description="Allows Engineers to heal other people's shields.|Level 1 enables the Engineers Link Gun. |Level 2 Gives double the experience for healing, Level 3 triple the experience, and gives the Shield Blast artifact. |Cost (per level): 10,15,20"
     StartingCost=10
     CostAddPerLevel=5
     MaxLevel=3
     ShieldHealingPercent=1.0
     BotChance=7
}
