class ArtifactKillAllPets extends RPGArtifact;

function Activate()
{
	local MonsterPointsInv Inv;

	Inv = MonsterPointsInv(Instigator.FindInventoryType(class'MonsterPointsInv'));
	if(Inv != None)
		inv.KillAllMonsters();

	bActive = false;
	GotoState('');
	return;
}

exec function TossArtifact()
{
	//do nothing. This artifact cant be thrown
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

function BotConsider()
{
	return;		// bots do not kill things they have summoned
}

defaultproperties
{
     CostPerSec=0
     MinActivationTime=0.0
     IconMaterial=Texture'DCText.Icons.KillSummoningCharmIcon'
     ItemName="Kill All Summoned Monsters"
}