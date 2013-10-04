//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NullEntropyInv extends Inventory;

var Pawn PawnOwner;
var Material ModifierOverlay;
var int Modifier;
var Sound NullEntropySound;

function GiveTo(Pawn Other, optional Pickup Pickup)
{

	if(Other == None)
	{
		destroy();
		return;
	}
	PawnOwner = Other;

	PawnOwner.SetPhysics(PHYS_None);
	enable('Tick');
	
	if(Modifier < 7)
	{
		LifeSpan = (Modifier / 3) + ((7 - Modifier) * 0.1);
		SetTimer(0.1, true);
	}
	else
		LifeSpan = (Modifier / 3);

	if(PawnOwner.Controller != None && PlayerController(PawnOwner.Controller) != None)
		PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'NullEntropyConditionMessage', 0);
	PawnOwner.PlaySound(NullEntropySound,,1.5 * PawnOwner.TransientSoundVolume,,PawnOwner.TransientSoundRadius);
	PawnOwner.setOverlayMaterial(ModifierOverlay, LifeSpan, true);

	Super.GiveTo(Other);
}

function Tick(float deltaTime)
{
	if(!class'RW_Freeze'.static.canTriggerPhysics(PawnOwner))
		return;

	if(PawnOwner != None && PawnOwner.Physics != PHYS_NONE)
		PawnOwner.setPhysics(PHYS_NONE);
}

function destroyed()
{
	disable('Tick');
	if(PawnOwner != None && PawnOwner.Physics == PHYS_NONE)
		PawnOwner.SetPhysics(PHYS_Falling);
	super.destroyed();
}

function Timer()
{
	if(LifeSpan <= (7 - Modifier) * 0.1)
	{
		SetTimer(0, true);
		disable('Tick');		
		PawnOwner.SetPhysics(PHYS_Falling);
	}
}

DefaultProperties
{
	RemoteRole=ROLE_SimulatedProxy
	ModifierOverlay=Shader'MutantSkins.Shaders.MutantGlowShader'
	NullEntropySound=sound'WeaponSounds.TranslocatorModuleRegeneration'
	bOnlyRelevantToOwner=False
	bAlwaysRelevant=True
	bReplicateInstigator=True
}