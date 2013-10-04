class AbilityDefenseSentinelShields extends EngineerAbility
	config(UT2004RPG)
	abstract;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (DruidDefenseSentinel(Other) != None)
	    DruidDefenseSentinel(Other).ShieldHealingLevel = AbilityLevel;
}

defaultproperties
{
     AbilityName="DefSent Shield healing"
     Description="Allows defense sentinels to heal shields when they are not busy. Each level adds 1 to each healing shot.|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     CostAddPerLevel=0
     MaxLevel=10
}
