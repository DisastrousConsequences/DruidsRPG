class AbilityBotEnhancedDamage extends BotAbility
	abstract;

// this is a bit of a dummy ability. When bots run out of things to buy, the server can crash if the level is too high - too many iterations buying.
// so this just gives them something to buy. Bots only.

var float LevMultiplier;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(!bOwnedByInstigator)
		return;
	if(Damage > 0)
		Damage *= (1 + (AbilityLevel * default.LevMultiplier));
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
	AbilityName="Bot Damage Bonus"
	Description="Increases bot damage bonus by 0.5% per level. |Cost (per level): 20,21,.... Bots only can buy."
	
	LevMultiplier=0.005000
	StartingCost=20
	CostAddPerLevel=1
	MaxLevel=200

	MinPlayerLevel=180
	BotChance=1
}