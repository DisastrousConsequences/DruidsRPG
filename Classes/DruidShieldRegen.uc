class DruidShieldRegen extends CostRPGAbility
	config(UT2004RPG) 
	abstract;

// these config variables only affect the server, so ok
var config int NoDamageDelay, ShieldPerLevel;
var config float ShieldRegenRate, RegenPerLevel;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local DruidShieldRegenInv R;
	local Inventory Inv;
	local int MaxShield;
	local bool bGotInv;

	if (Other == None)
		return;
	if (Other.Role != ROLE_Authority)
		return;

	//remove old one, if it exists
	//might happen if player levels up this ability while still alive
	bGotInv = false;
	Inv = Other.FindInventoryType(class'DruidShieldRegenInv');
	if (Inv != None)
	{
	    bGotInv = true;
		Inv.Destroy();
	}

	R = Other.spawn(class'DruidShieldRegenInv', Other,,,rot(0,0,0));
	if (R == None)
		return;	// ?
	R.NoDamageDelay = default.NoDamageDelay;
	MaxShield = default.ShieldPerLevel*AbilityLevel;
	R.MaxShieldRegen = MaxShield;
	// choice is to either have a flat regen rate, adding so much a second
	// or to have the amount regened based upon the level (e.g. 0.33 would generate level/3 per second)
	// so, whichever is best use.
	R.ShieldRegenRate = fmax(default.ShieldRegenRate,default.RegenPerLevel*float(AbilityLevel));

	R.GiveTo(Other);

	if (!bGotInv)
		Other.AddShieldStrength(MaxShield);	// start off topped up. But only on first giving of the ability

}

defaultproperties
{
     AbilityName="Shield Regeneration"
     Description="Regenerates your shield at 0.5 per level per second, minimum one, provided you haven't suffered damage recently. Does not regenerate past starting shield amount.  |Cost (per level): 4,4,4,4,4,4,4,4,4,4,...."
     StartingCost=4
     CostAddPerLevel=0
     MaxLevel=25
     NoDamageDelay=3
     ShieldPerLevel=10
     ShieldRegenRate=1.0
     RegenPerLevel=0.5
     BotChance=8
}