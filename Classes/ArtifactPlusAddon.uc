class ArtifactPlusAddon extends RPGArtifact;

var config int ModifierPlusValue;
var config int LimitOverMaximum;

var bool needsIdentify;
var bool hasbeenused;

function bool CanUseArtifact()
{
	local RPGWeapon CurWeapon;
	local Vehicle V;

	if (Instigator == None || hasbeenused)
		return false;

	V = Vehicle(Instigator);
	if (V != None )
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
		return false;	// can't use in a vehicle
	}

	CurWeapon = RPGWeapon(Instigator.Weapon);
	if (CurWeapon == None)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 1000, None, None, Class);
		return false;	// can't use except on a RPGWeapon
	}
	if ((CurWeapon.Modifier + ModifierPlusValue == 0) && !CurWeapon.bCanHaveZeroModifier) 
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 1200, None, None, Class);
		return false;	// if weapon type cannot have zero modifier
	}
	if (CurWeapon.MaxModifier == 0) 
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
		return false;	// if weapon type cannot have zero modifier
	}
	if (CurWeapon.class == class'RW_EngineerLink' || CurWeapon.class == class'RW_Superhealer')
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
		return false;	// cannot use this Power type on this type of weapon
	}
	// Will that specific weapon accept it given its current state?
	if (CurWeapon.Modifier + ModifierPlusValue > CurWeapon.MaxModifier + LimitOverMaximum)	// would put it too high
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 2500, None, None, Class);
		return false;	// weapon cannot accept
	}

	return true;
}

function BotConsider()
{
	if ( CanUseArtifact() )
		Activate();
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');
}

function Activate()
{
	local RPGWeapon CurWeapon;

	if (Instigator == None)
		return;

	if (!CanUseArtifact())
	{
		bActive = false;
		GotoState('');
		return;
	}

	// do it
	hasbeenused = true;									// stop someone sneaking in a second use
	CurWeapon = RPGWeapon(Instigator.Weapon);
	CurWeapon.Modifier += ModifierPlusValue;			// use .Modifier not .GetModifier()
	if (CurWeapon.Modifier > CurWeapon.MaxModifier+LimitOverMaximum)
		CurWeapon.Modifier = CurWeapon.MaxModifier+LimitOverMaximum;
	if (CurWeapon.Modifier > CurWeapon.MaxModifier)
		CurWeapon.bCanThrow = false;
	
	needsIdentify = true;
	setTimer(0.6, true);

	if(CurWeapon.isA('RW_Speedy'))
		(RW_Speedy(CurWeapon)).deactivate();

	bActive = false;
	GotoState('');
}

function Timer()
{
	local RPGWeapon CurWeapon;
	CurWeapon = RPGWeapon(Instigator.Weapon);
	if( needsIdentify && CurWeapon != None)
	{
		CurWeapon.Identify();
	}
	setTimer(0, false);

	Destroy();			// was a one shot artifact
	Instigator.NextItem();
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 1000)
		return "This artifact cannot work on your current weapon";
	else if (Switch == 1200)
		return "Your weapon cannot be upgraded to have a zero modifier";
	else if (Switch == 2000)
		return "Your weapon is of the wrong type for this artifact";
	else if (Switch == 2500)
		return "Your current weapon is too powerful to accept more of these";
	else if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else
		return "Cannot use this artifact";
}

defaultproperties
{
     PickupClass=Class'ArtifactPlusAddonPickup'
     ModifierPlusValue=1
     LimitOverMaximum=1
     ItemName="Plus Addon Powerup"
     IconMaterial=FinalBlend'EpicParticles.Shaders.IonFallFinal'
     CostPerSec=1
     MinActivationTime=0.000001
}

