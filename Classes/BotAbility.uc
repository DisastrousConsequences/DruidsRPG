class BotAbility extends CostRPGAbility
	abstract;

// only for bots this ability
static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data == None || Data.OwnerID != "Bot") 	// bots only, and then only when over level 250
		return 0;
		
	return super.Cost(Data, CurrentLevel);		
}

DefaultProperties
{
	AbilityName="Bot Ability"
	Description="Only for bots"
	
	BotChance=5
}