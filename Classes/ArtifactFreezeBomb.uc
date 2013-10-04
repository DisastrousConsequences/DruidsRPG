class ArtifactFreezeBomb extends EnhancedRPGArtifact
		config(UT2004RPG);

var config int AdrenalineRequired;
var config int BlastDistance;
var config float ChargeTime;
var config float MaxFreezeTime;
var config float FreezeRadius;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < AdrenalineRequired)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.2 )
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
	local FreezeBombCharger FBC;

	if (Instigator != None)
	{
		if(Instigator.Controller.Adrenaline < AdrenalineRequired*AdrenalineUsage)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired*AdrenalineUsage, None, None, Class);
			bActive = false;
			GotoState('');
			return;
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

		FBC = Instigator.spawn(class'FreezeBombCharger', Instigator.Controller,,BlastLocation);
		if(FBC != None)
		{
			FBC.MaxFreezeTime = MaxFreezeTime;
			FBC.FreezeRadius = FreezeRadius;
			FBC.ChargeTime = ChargeTime*AdrenalineUsage;

			Instigator.Controller.Adrenaline -= AdrenalineRequired*AdrenalineUsage;
			if (Instigator.Controller.Adrenaline < 0)
				Instigator.Controller.Adrenaline = 0;
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
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'ArtifactFreezeBombPickup'
     IconMaterial=Texture'Engine.DefaultTexture'
     ItemName="FreezeBomb"
     AdrenalineRequired=75
     BlastDistance=1500

     MaxFreezeTime=15.000000
     FreezeRadius=2000.000000
     ChargeTime=2.0
}
