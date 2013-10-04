class AbilityBotEnhancedReduction extends BotAbility
	abstract;

var float LevMultiplier;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(bOwnedByInstigator)
		return; //if the instigator is doing the damage, ignore this.
	if(Damage > 0)
		Damage *= (abs((AbilityLevel * default.LevMultiplier)-1));
}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data == None || Data.Level < default.MinPlayerLevel)
		return 0;	// stop bots from buying
		
	if (Cost(Data, CurrentLevel) > 0)
		return default.BotChance;
	else
		return 0;
}

DefaultProperties
{
	AbilityName="Bot Damage Reduction"
	Description="Increases bot total damage reduction by 4% per level. Does not apply to self damage.|Cost (per level): 20,21,.... Bots only can purchase."
	
	LevMultiplier=0.005000
	StartingCost=20
	CostAddPerLevel=1
	MaxLevel=100

	MinPlayerLevel=200
	BotChance=1
}