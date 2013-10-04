class DruidAdrenalineRegen extends CostRPGAbility
	abstract;

static simulated function int GetCost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool gotab;
	
	if (Data == None)
		return 0;
	
	// now check for LoadedArtifacts 5
	if (CurrentLevel >= 3)
	{
		gotab = false;
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == class'DruidArtifactLoaded' && Data.AbilityLevels[x] >= 5)
				gotab = true;
		if (!gotab)
			return 0;
	}

	return super.GetCost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local DruidAdrenRegenInv R;
	local Inventory Inv;
	local int WaveNum;

	if (Other.Role != ROLE_Authority)
		return;

	//remove old one, if it exists
	//might happen if player levels up this ability while still alive
	// but keep a record of the old wavenum
	WaveNum = -1;
	Inv = Other.FindInventoryType(class'DruidAdrenRegenInv');
	if (Inv != None)
	{
		WaveNum = DruidAdrenRegenInv(Inv).WaveNum;
		Inv.Destroy();
	}

	R = Other.spawn(class'DruidAdrenRegenInv', Other,,,rot(0,0,0));
	R.GiveTo(Other);
	R.WaveNum = WaveNum;        // so don't get wave bonus after ghosting/speed/etc

	if (AbilityLevel >= 3)
	{
		R.RegenAmount *= (AbilityLevel - 2);
		if (AbilityLevel > 3)
			R.bAlwaysGive = true;
		R.SetTimer(1, true);
		R.WaveBonus = 5;
	}
	else
	{
		R.SetTimer(4 - AbilityLevel, true);
		R.WaveBonus = AbilityLevel;
	}
}

defaultproperties
{
     AbilityName="Adrenal Drip"
     Description="Slowly drips adrenaline into your system.|At level 1 you get one adrenaline every 3 seconds.|At level 2 you get one adrenaline every 2 seconds.|At level 3 you get one adrenaline every second. |At level 4 you get two adrenaline per second.|You must spend 25 points in your Adrenaline Max stat for each level of this ability you want to purchase. |Cost (per level): 2,8,14..."

     StartingCost=2
     CostAddPerLevel=6

     MaxLevel=6
     MinAdrenalineMax=125
     AdrenalineMaxStep=25
}
