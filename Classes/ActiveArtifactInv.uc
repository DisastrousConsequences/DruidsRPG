class ActiveArtifactInv extends Inventory
	config(UT2004RPG);

var config int CheckFrequency;

var float lastCheck;

var bool ActiveArtifact;

function Timer()
{
	super.Timer();
	setActiveArtifact();
}

function setActiveArtifact()
{
	local Inventory Inv;
	if(Instigator == None)
		return; //something strange is happening with this inventory, but it should work itself out shortly
	lastCheck = Instigator.Level.TimeSeconds;

	for (Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (Inv == None)
		{
			ActiveArtifact = false;
			return;
		}
		if (Inv.IsA('RPGArtifact') && RPGArtifact(Inv).bActive)
		{
			ActiveArtifact = true;
			return;
		}
		if (Inv.IsA('ActiveArtifactInv') && Inv != Self)
			Inv.destroy(); //somehow they got more than one?!
	}

	ActiveArtifact = false;
}

static function bool hasActiveArtifact(Pawn other)
{
	Local Pawn Instigator;
	Local ActiveArtifactInv Inv;

	if(Vehicle(Other) != None)
		Instigator = Vehicle(Other).Driver;
	else
		Instigator = Other;

	if(Instigator == None)
		return false;

	Inv = ActiveArtifactInv(Instigator.FindInventoryType(class'ActiveArtifactInv'));
	if (Inv == None)
	{
		Inv = Instigator.spawn(class'ActiveArtifactInv', other,,, rot(0,0,0));
		Inv.giveTo(Instigator);
		Inv.setActiveArtifact();
		Inv.SetTimer(Inv.CheckFrequency, true);
	}
	else
	{
		if(Other.Level.TimeSeconds - Inv.LastCheck > Inv.CheckFrequency)
			Inv.setActiveArtifact();
	}
	return(Inv.ActiveArtifact);
}

function DropFrom(vector StartLocation)
{
	//this inventory cant be dropped.
}

defaultproperties
{
     CheckFrequency=5;
     RemoteRole=ROLE_DumbProxy
     bOnlyRelevantToOwner=True
     bAlwaysRelevant=True
     bReplicateInstigator=False
}