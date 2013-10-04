class ArtifactKillAllVehicles extends RPGArtifact;

function Activate()
{
	local EngineerPointsInv Inv;

	Inv = class'AbilityLoadedEngineer'.static.GetEngInv(Instigator);
	if(Inv != None)
		Inv.KillAllVehicles();

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
     IconMaterial=Texture'DCText.Icons.KillSummonVehicleIcon'
     ItemName="Kill All Summoned Vehicles"
}