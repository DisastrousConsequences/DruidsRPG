class AbilityConstructionHealthBonus extends EngineerAbility
	config(UT2004RPG)
	abstract;

var config float HealthBonus;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	Other.HealthMax += Other.HealthMax * (Default.HealthBonus * AbilityLevel);
	Other.Health += Other.Health * (Default.HealthBonus * AbilityLevel);
	Other.SuperHealthMax += Other.SuperHealthMax * (Default.HealthBonus * AbilityLevel);
}

defaultproperties
{
     AbilityName="Constructions: Health Bonus"
     Description="Gives an additional health bonus to your summoned constructions. Each level adds 20% health to your construction's max health.|Cost (per level): 2,4,6,8,10,12,14,16,18,20"
     StartingCost=2
     CostAddPerLevel=2
     MaxLevel=20
     HealthBonus=0.200000
}