class DamageInv extends Inventory;

var RPGRules Rules;
var float KillXPPerc;
var int EstimatedRunTime;
var vector CoreLocation;
var Controller DamagePlayerController;
var float EffectRadius;
var Material EffectOverlay;

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		DamagePlayerController,CoreLocation,EstimatedRunTime;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(1, true);
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	super.GiveTo(Other, Pickup);
	SwitchOnDamage();
}

function SwitchOnDamage()
{
	// need to switch on damage for this player
	if ((Owner == None) || (DamagePlayerController == None) || (Pawn(Owner) == None) || (Pawn(Owner).Controller == None) || Pawn(Owner).HasUDamage())
	{	// got problems. Do not switch on
		Destroy();
		return;
	}

	Pawn(Owner).EnableUDamage(EstimatedRunTime);
	if (PlayerController(Pawn(Owner).Controller) != None)
	{
		PlayerController(Pawn(Owner).Controller).ReceiveLocalizedMessage(class'DamageConditionMessage', 0);
	}
	Pawn(Owner).SetOverlayMaterial(EffectOverlay, EstimatedRunTime, true);
}

function SwitchOffDamage()
{
	// need to switch off invulnerability if we are the only source for this player
	// no other sphere will have started while we were running
	// if he started the globe, tough luck

	if (Pawn(Owner) != None)
	{
		Pawn(Owner).DisableUDamage();
		if (Pawn(Owner).Controller != None && PlayerController(Pawn(Owner).Controller) != None)
		{
			PlayerController(Pawn(Owner).Controller).ReceiveLocalizedMessage(class'DamageConditionMessage', 1);
		}
		Pawn(Owner).SetOverlayMaterial(EffectOverlay, -1, true);
	}
}

simulated function Timer()
{
	local ArtifactSphereDamage InitiatingSphere;
	if (Role == ROLE_Authority)
	{

		if ((Owner == None) || (Pawn(Owner) == None))
		{	// got problems.
			if (Owner == None)
				Warn("*** Damage Sphere effect still active and unable to terminate. Owner None");
			else 
				Warn("*** Damage Sphere effect still active and unable to terminate. Pawn(Owner) None");
			Destroy();
			return;
		}
		
		if (Pawn(Owner).Controller == None)
		{
			// something funny happening. Lets switch off udamage
			SwitchOffDamage();
			Destroy();
			return;
		}

		if (!Pawn(Owner).HasUDamage())
		{	// if the owner hasn't got udamage anymore, then not active, so destroy
			Destroy();
			return;
		}

		if ((DamagePlayerController == None) || (DamagePlayerController.Pawn == None) || (DamagePlayerController.Pawn.Health <= 0) || !DamagePlayerController.Pawn.HasUDamage() )
		{	// initiating player hasn't got udamage anymore, so artifact must have stopped
			SwitchOffDamage();
			Destroy();
			return;
		}

		// lets find the artifact
		InitiatingSphere = ArtifactSphereDamage(DamagePlayerController.Pawn.FindInventoryType(class'ArtifactSphereDamage'));

		// ok, lets check if still in range and artifact still active
		if ((VSize(Pawn(Owner).Location - CoreLocation) > EffectRadius) || (InitiatingSphere == None) || (!InitiatingSphere.bActive))
		{	// now out of range
			SwitchOffDamage();
			Destroy();
			return;
		}

		// ok as a safety, lets decrement the EstimatedRunTime, and switch off when zero
		EstimatedRunTime--;
		if (EstimatedRunTime <= 0)
		{	// failsafe, lets terminate
			SwitchOffDamage();
			Destroy();
			return;
		}

		// ok, lets see if the initiator gets any xp
		// Not any more. Use damage based reward.
		//if ((ExpPerSecond > 0) && (Rules != None))
		//{
		//	Rules.ShareExperience(RPGStatsInv(DamagePlayerController.Pawn.FindInventoryType(class'RPGStatsInv')), ExpPerSecond);
		//}
	}

	//dont call super. Bad things will happen.
}

simulated function Destroyed()
{	
	if ((Owner != None) && (Pawn(Owner) != None) && (Pawn(Owner).Controller != None) && Pawn(Owner).HasUDamage())
		 SwitchOffDamage();
	super.Destroyed();
}

defaultproperties
{
     EffectOverlay=Shader'XGameShaders.PlayerShaders.WeaponUDamageShader'
     bOnlyRelevantToOwner=False
     KillXPPerc=0.1
}
