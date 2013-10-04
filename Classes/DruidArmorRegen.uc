class DruidArmorRegen extends CostRPGAbility
	abstract;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local DruidArmorRegenInv R;
	local Inventory Inv;

	if (Other.Role != ROLE_Authority)
		return;

	//remove old one, if it exists
	//might happen if player levels up this ability while still alive
	Inv = Other.FindInventoryType(class'DruidArmorRegenInv');
	if (Inv != None)
		Inv.Destroy();

	R = Other.spawn(class'DruidArmorRegenInv', Other,,,rot(0,0,0));
	R.RegenAmount = AbilityLevel*2;
	R.GiveTo(Other);
}

defaultproperties
{
     Description="Heals 2 armor per second per level. Does not heal past starting armor amount. You must have a Health Bonus stat equal to 25 times the ability level you wish to have before you can purchase it. |Cost (per level): 15,20,25,30,..."
     AbilityName="Armor Regeneration"
     StartingCost=15
     CostAddPerLevel=5
     MaxLevel=10
     MinHealthBonus=25
     HealthBonusStep=25
}
