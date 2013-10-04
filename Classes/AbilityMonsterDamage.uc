class AbilityMonsterDamage extends CostRPGAbility
	config(UT2004RPG) 
	abstract;

var config float LevMultiplier;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(!bOwnedByInstigator || Instigator == None || Monster(Instigator) == None)
		return;
	// now know this is damage done by a monster
	if(Damage > 0)
		Damage *= (1 + (AbilityLevel * default.LevMultiplier));
}

DefaultProperties
{
	AbilityName="Monster Damage Bonus"
	Description="Increases the damage done by Pets by 2% per level. |Cost (per level): 5."
	
	LevMultiplier=0.020000
	StartingCost=5
	CostAddPerLevel=0
	MaxLevel=20
}