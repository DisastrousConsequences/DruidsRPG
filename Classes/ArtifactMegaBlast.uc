class ArtifactMegaBlast extends EnhancedRPGArtifact
		config(UT2004RPG);

var config int AdrenalineRequired;
var config int BlastDistance;
var config float ChargeTime;
var config float Damage;
var config float DamageRadius;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < AdrenalineRequired)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.2 )	// make it rare
		Activate();
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');
}

function Activate()
{
	local Vehicle V;
	local Vector FaceDir;
	local Vector BlastLocation;
	local vector HitLocation;
	local vector HitNormal;
	Local MegaCharger MC;

	if (Instigator != None)
	{
		if(Instigator.Controller.Adrenaline < (AdrenalineRequired*AdrenalineUsage))
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired*AdrenalineUsage, None, None, Class);
			bActive = false;
			GotoState('');
			return;
		}
		
		if (LastUsedTime  + (TimeBetweenUses*AdrenalineUsage) > Instigator.Level.TimeSeconds)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 5000, None, None, Class);
			bActive = false;
			GotoState('');
			return;	// cannot use yet
		}

		V = Vehicle(Instigator);
		if (V != None )
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
			bActive = false;
			GotoState('');
			return;	// can't use in a vehicle

		}

		// change the guts of it
		FaceDir = Vector(Instigator.Controller.GetViewRotation());
		BlastLocation = Instigator.Location + (FaceDir * BlastDistance);
		if (!FastTrace(Instigator.Location, BlastLocation ))
		{
			// can't get directly to where we want to be. Spawn explosion where we collide.
			Trace(HitLocation, HitNormal, BlastLocation, Instigator.Location, true);
			BlastLocation = HitLocation - (30*Normal(FaceDir));
		}

		MC = Instigator.spawn(class'MegaCharger', Instigator.Controller,,BlastLocation);
		if(MC != None)
		{
			MC.Damage = Damage;
			MC.DamageRadius = DamageRadius;
			MC.ChargeTime = ChargeTime*AdrenalineUsage;

			Instigator.Controller.Adrenaline -= (AdrenalineRequired*AdrenalineUsage);
			if (Instigator.Controller.Adrenaline < 0)
				Instigator.Controller.Adrenaline = 0;

			SetRecoveryTime(TimeBetweenUses*AdrenalineUsage);
		}
	}
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

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else if (Switch == 5000)
		return "Cannot use this artifact again yet";
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'ArtifactMegaBlastPickup'
     IconMaterial=Texture'XEffects.Skins.MuzFlashA_t'	
     ItemName="MegaBlast"
     AdrenalineRequired=200
     BlastDistance=2000

     Damage=1300.000000
     DamageRadius=1600.000000
     ChargeTime=2.0
     TimeBetweenUses=30.0
}
