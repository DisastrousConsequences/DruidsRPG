class AbilityEnhancedDamage extends CostRPGAbility
	config(UT2004RPG) 
	abstract;

var config float LevMultiplier;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(!bOwnedByInstigator)
		return;
	if(Damage > 0)
		Damage *= (1 + (AbilityLevel * default.LevMultiplier));
}

DefaultProperties
{
	AbilityName="Advanced Damage Bonus"
	Description="Increases your cumulative total damage bonus by 3% per level. |Cost (per level): 5. You must be level 75 to purchase the first level of this ability, level 76 to purchase the second level, and so on."
	
	LevMultiplier=0.030000
	StartingCost=5
	CostAddPerLevel=0
	MaxLevel=20

	MinPlayerLevel=75
	PlayerLevelStep=1
}