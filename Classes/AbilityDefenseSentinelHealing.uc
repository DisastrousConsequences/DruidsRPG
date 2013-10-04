class AbilityDefenseSentinelHealing extends EngineerAbility
	config(UT2004RPG)
	abstract;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (DruidDefenseSentinel(Other) != None)
	    DruidDefenseSentinel(Other).HealthHealingLevel = AbilityLevel;
}

defaultproperties
{
     AbilityName="DefSent Health Bonus"
     Description="Allows defense sentinels to heal nearby players when they are not busy. Each level adds 1 to each healing shot.|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     CostAddPerLevel=0
     MaxLevel=10
}
