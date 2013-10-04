class AbilityExpHealing extends CostRPGAbility
	config(UT2004RPG)
	abstract;

var config float EXPBonusPerLevel;

var config int MaxNormalLevel;

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local ArtifactMakeSuperHealer AMSH;
	if(Monster(Other) != None)
		return; //Not for pets

	AMSH = ArtifactMakeSuperHealer(Other.FindInventoryType(class'ArtifactMakeSuperHealer'));

	//spawn one. AbilityLoadedHealing will come along and populate the other data in a moment.
	if(AMSH == None)
	{
		AMSH = Other.spawn(class'ArtifactMakeSuperHealer', Other,,, rot(0,0,0));
		if(AMSH == None)
			return; //get em next pass I guess?

		AMSH.giveTo(Other);
	}
	AMSH.EXPMultiplier = class'RW_Healer'.default.EXPMultiplier + (Default.EXPBonusPerLevel * AbilityLevel);
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (AbilityLevel <= default.MaxNormalLevel)
		return false;		// don't know, so let someone else decide
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		bAllowPickup = 0;	// no enhanced or offensive artifacts allowed
		return true;
	}
	return false;		// don't know, so let someone else decide
}

defaultproperties
{
     AbilityName="Experienced Healing"
     Description="Allows you to gain additional experience for healing others with the Medic Gun.|Each level allows you to gain an additional 1% experience from healing. |You must have Loaded Medic to purchase this skill.|Cost (per level): 5,8,11,14,17,20,23,26,29..."
     StartingCost=5
     CostAddPerLevel=3
     MaxLevel=20
     EXPBonusPerLevel=0.010000
     RequiredAbilities[0]=class'AbilityLoadedHealing'

     MaxNormalLevel=9
}