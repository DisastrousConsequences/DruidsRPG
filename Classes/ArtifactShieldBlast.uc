class ArtifactShieldBlast extends RPGArtifact
		config(UT2004RPG);

var config int AdrenalineRequired;
var config int BlastDistance;

var config float ChargeTime;
var config float MaxHealing;
var config float MinHealing;
var config float HealingRadius;

var float EXPMultiplier;
var RPGRules Rules;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < AdrenalineRequired)
		return;

	if (!bActive && NoArtifactsActive() && FRand() < 0.8 && Instigator.ShieldStrength < 50)
		Activate();
}

function PreBeginPlay()
{
	local GameRules G;
	Local HealableDamageGameRules SG;
	super.PreBeginPlay();

	if (Level.Game == None)
		return;

	if ( Level.Game.GameRulesModifiers == None )
	{
		SG = Level.Game.Spawn(class'HealableDamageGameRules');
		if(SG == None)
			log("Warning: Unable to spawn HealableDamageGameRules for ShieldBlast artifact. EXP for Healing will not occur.");
		else
			Level.Game.GameRulesModifiers = SG;
	}
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if(G.isA('HealableDamageGameRules'))
			{
				SG = HealableDamageGameRules(G);
				break;
			}
			if(G.NextGameRules == None)
			{
				SG = Level.Game.Spawn(class'HealableDamageGameRules');
				if(SG == None)
				{
					log("Warning: Unable to spawn HealableDamageGameRules for ShieldBlast artifact. EXP for Healing will not occur.");
					return; //try again next time?
				}

				//this will also add it after UT2004RPG, which will be necessary.
				Level.Game.GameRulesModifiers.AddGameRules(SG);
				break;
			}
		}
	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');

	CheckRPGRules();
}

function CheckRPGRules()
{
	Local GameRules G;

	if (Level.Game == None)
		return;		//try again later

	for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if(G.isA('RPGRules'))
		{
			Rules = RPGRules(G);
			break;
		}
	}

	if(Rules == None)
		Log("WARNING: Unable to find RPGRules in GameRules. EXP will not be properly awarded");
}

function Activate()
{
	local Vehicle V;
	local Vector FaceDir;
	local Vector BlastLocation;
	local vector HitLocation;
	local vector HitNormal;
	local ShieldBlastCharger SBC;

	if (Instigator != None)
	{
		if(Instigator.Controller.Adrenaline < AdrenalineRequired)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired, None, None, Class);
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

		if(Rules == None)
			CheckRPGRules();

		// see what xp we get
		ExpMultiplier = getExpMultiplier();

		// change the guts of it
		FaceDir = Vector(Instigator.Controller.GetViewRotation());
		BlastLocation = Instigator.Location + (FaceDir * BlastDistance);
		if (!FastTrace(Instigator.Location, BlastLocation ))
		{
			// can't get directly to where we want to be. Spawn explosion where we collide.
       			Trace(HitLocation, HitNormal, BlastLocation, Instigator.Location, true);
			// then lets just step back a touch
			BlastLocation = HitLocation - (30*Normal(FaceDir));
		}

		SBC = Instigator.spawn(class'ShieldBlastCharger', Instigator.Controller,,BlastLocation);
		if(SBC != None)
		{
			SBC.MaxHealing = MaxHealing;
			SBC.MinHealing = MinHealing;
			SBC.HealingRadius = HealingRadius;
			SBC.ChargeTime = ChargeTime;
			SBC.RPGRules = Rules;
			SBC.EXPMultiplier = EXPMultiplier;

			Instigator.Controller.Adrenaline -= AdrenalineRequired;
			if (Instigator.Controller.Adrenaline < 0)
				Instigator.Controller.Adrenaline = 0;
		}

	}
}

function float getExpMultiplier()
{
	// get the blast as part of ShieldHealing level 3
	// so we know the person has shield healing level 3
 
	return class'RW_EngineerLink'.default.ShieldHealingXPPercent * 3;
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
     PickupClass=Class'ArtifactShieldBlastPickup'
     IconMaterial=Texture'XEffectMat.Link.link_muz_yellow'	
     ItemName="ShieldBlast"
     AdrenalineRequired=25
     BlastDistance=1500

     MaxHealing=600.000000
     MinHealing=50.000000
     HealingRadius=2200.000000
     ChargeTime=2.0
}
