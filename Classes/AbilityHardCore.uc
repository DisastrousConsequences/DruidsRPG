class AbilityHardCore extends CostRPGAbility
	config(UT2004RPG) 
	abstract;

//Maybe this should be a subclass with an icon? Can you have more than one subclass?
//Should we give an XP boost or a damage boost for hardcore. Do we even want to? 
static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local HardCoreInv Inv;
	Inv = HardCoreInv(Other.FindInventoryType(class'HardCoreInv'));
	if(Inv == None)
	{
		Inv = Other.spawn(class'HardCoreInv', Other,,, rot(0,0,0));
		Inv.GiveTo(Other);
	}
	//they're now immune to healing. Just for you Sparky
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(!bOwnedByInstigator)
		return;

	Damage = Damage * 1.05;
}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
		return 0;	// stop bots from buying. They have more sense.
}

DefaultProperties
{
	AbilityName="Hard Core"
	Description="Don't buy this skill. This skill will PREVENT others from healing you, giving you shields, or helping you. You must be at least level 100 to purchase this."
	
	StartingCost=1
	CostAddPerLevel=0
	MaxLevel=1

	MinPlayerLevel=100
}