class AbilityMedicAwareness extends CostRPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	for (x = 0; x < Data.Abilities.length; x++)
	{
		if (Data.Abilities[x] == class'AbilityLoadedHealing')
			if (Data.AbilityLevels[x] > CurrentLevel)
				ok = true;
	}
	if (!ok)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	Local GiveItemsInv GIInv;

	if (Other == None || Other.Controller == None || !Other.Controller.IsA('PlayerController'))
		return;

	//set the flag to say we have medic awareness.
	GIInv = class'GiveItemsInv'.static.GetGiveItemsInv(Other.Controller);
	if(GIInv != None)
	{
		GIInv.MedicAwarenessLevel = AbilityLevel;
		return;
	}
}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
		return 0;	// stop bots from trying to buy
}

defaultproperties
{
     AbilityName="Medic Awareness"
     Description="Informs you of your friends' health with a display over their heads. At level 1 you get a small dully-colored indicator - blue for very healthy, green for reasonably healthy, yellow for hurt, and then red for near death. At level 2 you get a larger and more brightly colored health bar with a white background, that shrinks and changes colors as the target gains health. The bar will turn a full solid blue if the target is fully healed. You need to have the same level of Loaded Medic to purchase this skill. Cost per level: 10, 15. "
     StartingCost=10
     CostAddPerLevel=5
     BotChance=0
     MaxLevel=2
     RequiredAbilities[0]=class'AbilityLoadedHealing'
}
