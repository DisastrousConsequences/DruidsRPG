class AbilityDefenseSentinelArmor extends EngineerAbility
	config(UT2004RPG)
	abstract;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (DruidDefenseSentinel(Other) != None)
	    DruidDefenseSentinel(Other).ArmorHealingLevel = AbilityLevel;
}

defaultproperties
{
     AbilityName="DefSent Armor healing"
     Description="Allows defense sentinels to heal armor when they are not busy. Each level adds 1 to each healing shot.|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     CostAddPerLevel=0
     MaxLevel=10
}
