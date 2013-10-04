class ArtifactLightningBeam extends EnhancedRPGArtifact
		config(UT2004RPG);

var RPGRules Rules;
var class<xEmitter> HitEmitterClass;
var config float MaxRange;
var config int DamagePerAdrenaline;
var config int AdrenalineForMiss;
var config int MaxDamage;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < 20)
		return;

	if ( !bActive && NoArtifactsActive() && FRand() < 0.3 && BotFireBeam())
		Activate();
}

function PostBeginPlay()
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

function bool BotFireBeam()
{
	local Vector FaceDir;
	local Vector BeamEndLocation;
	local Vector StartTrace;
	local vector HitLocation;
	local vector HitNormal;
	local Pawn  HitPawn;
	local Actor AHit;

	FaceDir = Vector(Instigator.Controller.GetViewRotation());
	StartTrace = Instigator.Location + Instigator.EyePosition();
	BeamEndLocation = StartTrace + (FaceDir * MaxRange);

	AHit = Trace(HitLocation, HitNormal, BeamEndLocation, StartTrace, true);
	if ((AHit == None) || (Pawn(AHit) == None) || (Pawn(AHit).Controller == None))
		return false;

	HitPawn = Pawn(AHit);
	if ( HitPawn != Instigator && HitPawn.Health > 0 && !HitPawn.Controller.SameTeamAs(Instigator.Controller)
		&& VSize(HitPawn.Location - StartTrace) < MaxRange && HitPawn.Controller.bGodMode == False)
	{
		return true;
	}

	return false;
}

function Activate()
{
	local Vehicle V;
	local Vector FaceDir;
	local Vector BeamEndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;
	local Pawn  HitPawn;
	local Vector StartTrace;
	local xEmitter HitEmitter;
	local int StartHealth;
	local int NewHealth;
	local int HealthTaken;
	local Actor A;
	local int UDamageAdjust;
	local int DamageToDo;
	local float ataken;
	local bool RunningTriple;
	local int ExtraDamage;

	if ((Instigator == None) || (Instigator.Controller == None))
	{
		bActive = false;
		GotoState('');
		return;	// really corrupt
	}

	if (LastUsedTime  + (TimeBetweenUses*AdrenalineUsage) > Instigator.Level.TimeSeconds)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 5000, None, None, Class);
		bActive = false;
		GotoState('');
		return;	// cannot use yet
	}
	if (Instigator.Controller.Adrenaline < (AdrenalineForMiss*AdrenalineUsage))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineForMiss*AdrenalineUsage, None, None, Class);
		bActive = false;
		GotoState('');
		return;	// not enough power to charge
	}

	V = Vehicle(Instigator);
	if (V != None )
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
		bActive = false;
		GotoState('');
		return;	// can't use in a vehicle
	}

	// lets see what we hit then
	FaceDir = Vector(Instigator.Controller.GetViewRotation());
	StartTrace = Instigator.Location + Instigator.EyePosition();
	BeamEndLocation = StartTrace + (FaceDir * MaxRange);

	// See if we hit something.
	AHit = Trace(HitLocation, HitNormal, BeamEndLocation, StartTrace, true);
	if ((AHit == None) || (Pawn(AHit) == None) || (Pawn(AHit).Controller == None))
	{
		// missed. Take off the miss adrenaline penalty
		Instigator.Controller.Adrenaline -= (AdrenalineForMiss*AdrenalineUsage);
		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		bActive = false;
		GotoState('');
		return;	// didn't hit an enemy
	}

	HitPawn = Pawn(AHit);
	if ( HitPawn != Instigator && HitPawn.Health > 0 && !HitPawn.Controller.SameTeamAs(Instigator.Controller)
	     && VSize(HitPawn.Location - StartTrace) < MaxRange && HitPawn.Controller.bGodMode == False)
	{
		// got it.
		HitEmitter = spawn(HitEmitterClass,,, (StartTrace + Instigator.Location)/2, rotator(HitLocation - ((StartTrace + Instigator.Location)/2)));
		if (HitEmitter != None)
		{
			HitEmitter.mSpawnVecA = HitPawn.Location;
		}

		A = spawn(class'BlueSparks',,, Instigator.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
		}
		A = spawn(class'BlueSparks',,, HitPawn.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*HitPawn.TransientSoundVolume,,HitPawn.TransientSoundRadius);
		}

		// damage it
		StartHealth = HitPawn.Health;

		// damage it. First limit the damage. Otherwise get instagibs which are not fair
		// and also limit according to how much adrenaline we have
		DamageToDo = min(MaxDamage,DamagePerAdrenaline * (Instigator.Controller.Adrenaline/AdrenalineUsage));
            
		// now check if we have a udamage running, and want to limit damage
		RunningTriple = false;
		If (Instigator.HasUDamage())
		{
			UDamageAdjust = 2;				                	// assume double damage. If it is the triple, and not invasion, then they do more damage but use more adrenaline
			if (class'DruidDoubleModifier'.static.HasTripleRunning(Instigator))     // not allowed to get triple bonus
			{
			    RunningTriple = true;
				DamageToDo = DamageToDo/UDamageAdjust;          // adjust intended damage down so expected damage done after triple ups it
			}
			// now check if we need to add xp on for the extra damage done by the double
			if (StartHealth > DamageToDo)
			{
			    ExtraDamage = min(DamageToDo, StartHealth - DamageToDo); 
			    if (Rules == None)
			        CheckRPGRules();
				if (Rules != None)
				    Rules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), HitPawn, ExtraDamage);
			}
		}
		else
			UDamageAdjust = 1;

		HitPawn.TakeDamage(DamageToDo, Instigator, HitPawn.Location, vect(0,0,0), class'DamTypeLightningBolt');
			
		//first see if we killed it
		if (HitPawn == None || HitPawn.Health <= 0)
			AddArtifactKill(Instigator,class'WeaponBeam');

		// see how much damage we caused, and remove only that much adrenaline
		// If UseWithUDamage set, then only half (or 1/3) of the adrenaline should be taken if UDamage active
		NewHealth = 0;
		if (HitPawn != None)
			NewHealth = HitPawn.Health;
		if (NewHealth < 0)
			NewHealth = 0;
		HealthTaken = StartHealth - NewHealth;
		if (HealthTaken < 0)
			HealthTaken = StartHealth;	// Ghost knocks the health up to 9999

		// now check for double/triple damage, and adjust adrenaline taken accordingly
		if (!RunningTriple)
			ataken = (HealthTaken*AdrenalineUsage) / (DamagePerAdrenaline * UDamageAdjust);	    // take less adrenaline
		else
			ataken = (HealthTaken*AdrenalineUsage) / DamagePerAdrenaline;	    				// take single damage adrenaline
		Instigator.Controller.Adrenaline -= ataken;                          

		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		SetRecoveryTime(TimeBetweenUses*AdrenalineUsage);
	}

}

static function AddArtifactKill(Pawn P,class<Weapon> W)
{
	local int i;
	local TeamPlayerReplicationInfo TPPI;
	local TeamPlayerReplicationInfo.WeaponStats NewWeaponStats;

	// When you kill someone, it calls AddWeaponKill. Unfortunately this checks the damage type is from a weapon.
	// so lightning rod/beam/bolt etc do not get kills logged. So bodge in as weapon kills so show on stats
	if (P == None || W == None)
		return;

  // not sure if I need the next two lines. I don't think so. Assault seems to also give a list of weapon kills
  //      if (!P.Level.Game.IsA('Invasion'))
  //		return;

	TPPI = TeamPlayerReplicationInfo(P.PlayerReplicationInfo);
	if (TPPI == None)
		return;

	for ( i=0; i<TPPI.WeaponStatsArray.Length && i<200; i++ )
	{
		if ( TPPI.WeaponStatsArray[i].WeaponClass == W )
		{
			TPPI.WeaponStatsArray[i].Kills++;
			return;
		}
	}

	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.Kills = 1;
	TPPI.WeaponStatsArray[TPPI.WeaponStatsArray.Length] = NewWeaponStats;
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else if (Switch == 5000)
		return "Cannot use this artifact again yet";
	else
		return "At least" @ switch @ "adrenaline is required to use this artifact";
}

defaultproperties
{
     CostPerSec=1
     MinActivationTime=0.000001
     MaxRange=3000.000000
     HitEmitterClass=Class'LightningBeamEmitter'
     DamagePerAdrenaline=7
     AdrenalineForMiss=4
     PickupClass=Class'ArtifactLightningBeamPickup'
     IconMaterial=Texture'DCText.Icons.LightningBeamIcon'
     ItemName="Lightning Beam"
     MaxDamage=180
     TimeBetweenUses=0.5
}
