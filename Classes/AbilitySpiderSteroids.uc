class AbilitySpiderSteroids extends EngineerAbility
	config(UT2004RPG) 
	abstract;

var config float LevMultiplier;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local Inventory OInv;
	local RW_EngineerLink EGun;

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
	{	// ok, they already have the EngineerLink. Let's set their SpiderBoost level. If not, it will be set when they add the link
		// code duplicated in AbilityLoadedEngineer.SetSpiderBoostLevel
		EGun.SpiderBoost = AbilityLevel * default.LevMultiplier;
	}
}

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (DruidDefenseSentinel(Other) != None)
	    DruidDefenseSentinel(Other).SpiderBoostLevel = AbilityLevel * default.LevMultiplier;
}

DefaultProperties
{
	AbilityName="Spider Steroids"
	Description="Allows the Engineer Link Gun to boost spider mines"

	LevMultiplier=0.200000
	StartingCost=5
	CostAddPerLevel=0
	MaxLevel=20
}