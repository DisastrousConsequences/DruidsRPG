class ArtifactFireBall extends EnhancedRPGArtifact
		config(UT2004RPG);

var config int AdrenalineRequired;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < AdrenalineRequired)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.3 )	// fairly rare
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
	local Vector FaceVect;
	local Rotator FaceDir;
    local Projectile p;


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
		FaceDir = Instigator.Controller.GetViewRotation();
		FaceVect = Vector(FaceDir);

	    p = Instigator.Spawn(class'FireballProjectile',,, Instigator.Location + Instigator.EyePosition() + (FaceVect * Instigator.Collisionradius * 1.1), FaceDir);
		if (p != None)
		{
			Instigator.Controller.Adrenaline -= (AdrenalineRequired*AdrenalineUsage);
			if (Instigator.Controller.Adrenaline < 0)
				Instigator.Controller.Adrenaline = 0;
	
			SetRecoveryTime(TimeBetweenUses*AdrenalineUsage);

			p.PlaySound(Sound'WeaponSounds.RocketLauncher.RocketLauncherFire',,Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
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
     PickupClass=None
     IconMaterial=Texture'AW-2004Particles.Fire.NapalmSpot'	
     ItemName="FireBall"
     AdrenalineRequired=10

     TimeBetweenUses=1.6
}
