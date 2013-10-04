class AbilityMonsterHealthBonus extends MonsterAbility
	config(UT2004RPG)
	abstract;

var config float HealthBonus;

static simulated function ModifyMonster(Monster Other, int AbilityLevel)
{
	Other.HealthMax += Other.HealthMax * (Default.HealthBonus * AbilityLevel);
	Other.Health += Other.Health * (Default.HealthBonus * AbilityLevel);
}

defaultproperties
{
     AbilityName="Summons: Health Bonus"
     Description="Gives an additional health bonus to your summoned monsters. Each level adds 10% health to your monster's max health. |Cost (per level): 2,6,10,14,18,22,26,30,34,38"
     StartingCost=2
     CostAddPerLevel=4
     MaxLevel=20
     HealthBonus=0.100000
}