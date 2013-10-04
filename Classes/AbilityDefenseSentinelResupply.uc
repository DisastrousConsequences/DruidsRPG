class AbilityDefenseSentinelResupply extends EngineerAbility
	config(UT2004RPG)
	abstract;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (DruidDefenseSentinel(Other) != None)
	    DruidDefenseSentinel(Other).ResupplyLevel = AbilityLevel;
}

defaultproperties
{
     AbilityName="DefSent Resupply"
     Description="Allows defense sentinels to grant ammo resupply when they are not busy. Each level adds 1 to each healing shot.|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     CostAddPerLevel=0
     MaxLevel=10
}
