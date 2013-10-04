class AbilityMonsterPoints extends CostRPGAbility
	abstract;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local MonsterPointsInv Inv;

	if(Monster(Other) != None)
		return; //Not for pets

	Inv = MonsterPointsInv(Other.FindInventoryType(class'MonsterPointsInv'));

	if(Inv != None)
	{
		if(Inv.TotalMonsterPoints == AbilityLevel)
			return;
	}
	else
	{
		Inv = Other.spawn(class'MonsterPointsInv', Other,,, rot(0,0,0));
		if(Inv == None)
			return; //get em next pass I guess?

		Inv.giveTo(Other);
	}
	Inv.TotalMonsterPoints = AbilityLevel;
}

defaultproperties
{
     AbilityName="Monster Points"
     Description="Allows you to summon monsters with the loaded monsters skill. |Cost (per level): 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21...."
     StartingCost=2
     CostAddPerLevel=1
     MaxLevel=30
}