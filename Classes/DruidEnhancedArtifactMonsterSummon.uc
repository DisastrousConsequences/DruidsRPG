class DruidEnhancedArtifactMonsterSummon extends DruidArtifactMonsterSummon
	config(UT2004RPG);

var config float MonsterLifeSpan;
var config int MaxMonsters;
var config bool DestroyOnUse;
var config bool DestroyOnUseForLA;

var config int MaxAdrenaline;

function Class<Monster> chooseMonster(out int AdrenalineUsed, out int MonsterPointsUsed, MonsterPointsInv Inv)
{
	local int x, chosen, sizeOfChosen;
	local int zeroPointMonsters;
	local Class<Monster> ChosenMonster;

	for(x = 0; x < Inv.SummonedMonsterPoints.Length; x++)
	{
		if(Inv.SummonedMonsterPoints[x] == 0)
			zeroPointMonsters++;
	}
	if(zeroPointMonsters >= MaxMonsters)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 2500, None, None, Class);
		return None;
	}

	sizeOfChosen = -1;

	for (x = 0; x < RPGMut.MonsterList.length; x++)
	{
		if(RPGMut.MonsterList[x] == None)
		{
			Log("Warning: Unknown entry in Monster List. Index:"@x);
			continue;
		}
		if
		(
			(
				Instigator.Controller.Adrenaline >= RPGMut.MonsterList[x].default.ScoringValue * 10
			) ||
			(
				Instigator.Controller.Adrenaline >= MaxAdrenaline &&
				RPGMut.MonsterList[x].default.ScoringValue * 10 >= MaxAdrenaline
			)
		)
		{
			if
			(
				RPGMut.MonsterList[x].default.ScoringValue * 10 >= sizeOfChosen ||
				(
					RPGMut.MonsterList[x].default.ScoringValue * 10 >= MaxAdrenaline &&
					sizeOfChosen >= MaxAdrenaline
				)
			)
			{
				if
				(
					RPGMut.MonsterList[x].default.ScoringValue * 10 == sizeOfChosen ||
					(
						RPGMut.MonsterList[x].default.ScoringValue * 10 >= MaxAdrenaline &&
						sizeOfChosen >= MaxAdrenaline
					)
				)
				{
					if(0 == rand(2))
					{
						chosen = x;
						sizeOfChosen = RPGMut.MonsterList[x].default.ScoringValue * 10;
					}
				}
				else
				{
					chosen = x;
					sizeOfChosen = RPGMut.MonsterList[x].default.ScoringValue * 10;
				}
			}
		}
	}
	if(sizeOfChosen == -1)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 4500, None, None, Class);
		return None;
	}

	ChosenMonster = RPGMut.MonsterList[chosen];
	AdrenalineUsed = ChosenMonster.default.ScoringValue * 10;
	if(AdrenalineUsed >= MaxAdrenaline)
		AdrenalineUsed=MaxAdrenaline-1;

	return ChosenMonster;
}

function bool ShouldDestroy()
{
	local LoadedInv LoadedInv;

	log("Checking Destroy");

	if(DestroyOnUse)
	{
		LoadedInv = LoadedInv(Instigator.FindInventoryType(class'LoadedInv'));

		if(LoadedInv == None)
			return true;
		
		if(!LoadedInv.ProtectArtifacts)
			return true;

		if(DestroyOnUseForLA)
			return true;
		
		return false;
	}
	else
		return false;
}

function float getMonsterLifeSpan()
{
	return MonsterLifeSpan;
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2500)
		return class'ArtifactMonsterSummon'.Default.TooManyMonstersMessage;
	if (Switch == 4500)
		return "Unable to Summon Monster";

	return Super.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}

defaultproperties
{
	MaxMonsters=2
	MaxAdrenaline=150
	MonsterLifeSpan=240.000000
	DestroyOnUse=True
	DestroyOnUseForLA=True
	PickupClass=Class'DruidEnhancedArtifactMonsterSummonPickup'
	ItemName="Summoning Charm"
	MessageClass=Class'UnrealGame.StringMessagePlus'
}