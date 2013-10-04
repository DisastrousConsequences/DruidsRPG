class DruidMonsterMasterArtifactMonsterSummon extends DruidArtifactMonsterSummon
	config(UT2004RPG);

var class<Monster> ChosenMonster;
var string FriendlyName;
var int Adrenaline;
var int MonsterPoints;

replication
{
	reliable if (Role == ROLE_Authority)
		MonsterPoints, Adrenaline, FriendlyName;
}

function setup(String name, class<Monster> Monster, int AdrenalineUsed, int MonsterPointsUsed)
{
	ChosenMonster = Monster;
	Adrenaline = AdrenalineUsed;
	MonsterPoints = MonsterPointsUsed;
	FriendlyName = Name;
}

function Class<Monster> chooseMonster(out int AdrenalineUsed, out int MonsterPointsUsed, MonsterPointsInv Inv)
{
	AdrenalineUsed = Adrenaline;
	MonsterPointsUsed = MonsterPoints;
	return ChosenMonster;
}

function bool ShouldDestroy()
{
	return false;
}

function float getMonsterLifeSpan()
{
	return 0.0;
}

exec function TossArtifact()
{
	//do nothing. This artifact cant be thrown
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	bOnlyRelevantToOwner=True
	ItemName=""
}