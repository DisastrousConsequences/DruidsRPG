class FreezeInv extends Inventory;

var Controller InstigatorController;
var Pawn PawnOwner;
var int Modifier;

var class <xEmitter> FreezeEffectClass;
var Material ModifierOverlay;

var bool stopped;

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		PawnOwner;
	reliable if (Role == ROLE_Authority)
		stopped;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Instigator != None)
		InstigatorController = Instigator.Controller;

	SetTimer(0.5, true);
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	local Pawn OldInstigator;

	if(Other == None)
	{
		destroy();
		return;
	}

	stopped = false;
	if (InstigatorController == None)
		InstigatorController = Other.Controller;

	//want Instigator to be the one that caused the freeze
	OldInstigator = Instigator;
	Super.GiveTo(Other);
	PawnOwner = Other;

	Instigator = OldInstigator;
	PawnOwner.setOverlayMaterial(ModifierOverlay, (LifeSpan-2), true);
}

simulated function Timer()
{
	Local Actor A;
	if(!stopped)
	{

		if (Level.NetMode != NM_DedicatedServer && PawnOwner != None)
		{
			if (PawnOwner.IsLocallyControlled() && PlayerController(PawnOwner.Controller) != None)
				PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'FreezeConditionMessage', 0);
		}
		if (Role == ROLE_Authority)
		{
			if(Owner != None)
				A = PawnOwner.spawn(class'IceSmoke', PawnOwner,, PawnOwner.Location, PawnOwner.Rotation);

			if(!class'RW_Freeze'.static.canTriggerPhysics(PawnOwner))
			{
				stopEffect();
				return;
			}

			if(LifeSpan <= 0.5)
			{
				stopEffect();
				return;
			}

			if (Owner == None)
			{
				Destroy();
				return;
			}

			if (Instigator == None && InstigatorController != None)
				Instigator = InstigatorController.Pawn;
			else if(PawnOwner != None)
				class'RW_Speedy'.static.quickfoot(-10 * Modifier, PawnOwner);
		}
	}
}

function stopEffect()
{
	if(stopped)
		return;
	else
		stopped = true;
	if(PawnOwner != None)
	{
		class'RW_Speedy'.static.quickfoot(0, PawnOwner);
	}
}

function destroyed()
{
	stopEffect();
	super.destroyed();
}

defaultproperties
{
	ModifierOverlay=Shader'DCText.DomShaders.PulseGreyShader'
	bOnlyRelevantToOwner=False
	bAlwaysRelevant=True
	bReplicateInstigator=True
	RemoteRole=ROLE_SimulatedProxy
}