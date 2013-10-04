class ArtifactChainLightning extends EnhancedRPGArtifact
		config(UT2004RPG);

var class<xEmitter> HitEmitterClass;
var config float MaxRange;
var config float MaxStepRange;
var config int AdrenalineForMiss;
var config int AdrenalineForHit;
var config int FirstDamage;
var config float StepDamageFraction;
var config int MaxSteps;				// maximum number of steps. 0 means just hit target like beam. 1 means one additional step

var array<Pawn> ChainHitPawn;			// list of those we have hit
var array<int> ChainStepNumber;			// what step number they were hit with
var array<vector> ChainHitLocation;		// location of hit, just in case they are dead
var array<int> ChainActive;				// if 1, this pawn has yet to fire (bool didnt work for some reason)
var RPGRules Rules;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < 20)
		return;

	if ( !bActive && NoArtifactsActive() && FRand() < 0.8 && BotFireBeam())
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

function ChainPawn(Pawn Victim, vector HitLocation, vector StartLocation, int StepNumber)
{
	local Actor A;
	local int DamageToDo;
	local int UDamageAdjust;
	local xEmitter HitEmitter;
	local int i;
	local float CurPercent;
	local bool RunningTriple;
	local int ExtraDamage;

	if (StepNumber > MaxSteps)
		return;	// shouldn't have got this far
		
	// now check if Victim is already in the list
	for (i=0; i< ChainHitPawn.length; i++)
		if (ChainHitPawn[i] == Victim)
			return;		// already got.

	if (StepNumber < MaxSteps)
	{
		// add this victim to the list of those chaining
		ChainHitPawn[ChainHitPawn.length] = Victim;
		ChainStepNumber[ChainStepNumber.length] = StepNumber;
		ChainHitLocation[ChainHitLocation.length] = HitLocation;
		ChainActive[ChainActive.length] = 1;
	}

	// first draw the emitter.
	HitEmitter = spawn(HitEmitterClass,,,StartLocation , rotator(HitLocation - StartLocation));
	if (HitEmitter != None)
	{
		HitEmitter.mSpawnVecA = Victim.Location;
	}

	A = spawn(class'BlueSparks',,, Victim.Location);
	if (A != None)
	{
		A.RemoteRole = ROLE_SimulatedProxy;
		A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Victim.TransientSoundVolume,,Victim.TransientSoundRadius);
	}

	// work out what factor we are at
	CurPercent = 1.0;
	for (i=0; i<StepNumber; i++)
		CurPercent *= StepDamageFraction;
	// damage it. First limit the damage. Otherwise get instagibs which are not fair
    DamageToDo = FirstDamage * CurPercent;
        
	// now check if we have a udamage running, and want to limit damage
	RunningTriple = false;
	If (Instigator != None && Instigator.HasUDamage())
	{
		UDamageAdjust = 2;				                	// assume double damage. If it is the triple, and not invasion, then they do more damage but use more adrenaline
		if (class'DruidDoubleModifier'.static.HasTripleRunning(Instigator))     // not allowed to get triple bonus
		{
		    RunningTriple = true;
			DamageToDo = DamageToDo/UDamageAdjust;          // adjust intended damage down so expected damage done after triple ups it
		}
		// now check if we need to add xp on for the extra damage done by the double
		if (Victim.Health > DamageToDo)
		{
		    ExtraDamage = min(DamageToDo, Victim.Health - DamageToDo);
		    if (Rules == None)
		        CheckRPGRules();
			if (Rules != None)
			    Rules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), Victim, ExtraDamage);
		}
	}
	else
		UDamageAdjust = 1;

	Victim.TakeDamage(DamageToDo, Instigator, Victim.Location, vect(0,0,0), class'DamTypeLightningBolt');
		
	//first see if we killed it
	if (Victim == None || Victim.Health <= 0)
		class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator,class'WeaponChainLightning');

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
	local Actor A;

	if ((Instigator == None) || (Instigator.Controller == None))
		return;
	
	if (LastUsedTime + (TimeBetweenUses*AdrenalineUsage) > Instigator.Level.TimeSeconds)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 5000, None, None, Class);
		bActive = false;
		GotoState('');
		return;	// cannot use yet
	}
	if (Instigator.Controller.Adrenaline < (AdrenalineForHit*AdrenalineUsage))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineForHit*AdrenalineUsage, None, None, Class);
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
	
	//ok so we hit something. clear out any old hit data
	ChainHitPawn.length = 0;
	ChainStepNumber.length = 0;
	ChainHitLocation.length = 0;
	ChainActive.length = 0;

	HitPawn = Pawn(AHit);
	if ( HitPawn != Instigator && HitPawn.Health > 0 && !HitPawn.Controller.SameTeamAs(Instigator.Controller)
	     && VSize(HitPawn.Location - StartTrace) < MaxRange && HitPawn.Controller.bGodMode == False)
	{
		// take off adrenaline penalty, and flag as being used
		Instigator.Controller.Adrenaline -= AdrenalineForHit * AdrenalineUsage;                          
	
		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;
	
		SetRecoveryTime(TimeBetweenUses*AdrenalineUsage);
		
		A = spawn(class'BlueSparks',,, Instigator.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
		}
		//This one takes damage, and then see if it spreads
		ChainPawn(HitPawn, HitLocation, (StartTrace + Instigator.Location)/2, 0);
	}

	SetTimer(0.2, true);
	
}

function Timer()
{
	local Controller C, NextC;
	local vector Ploc;
	local int i, j, besti;
	local bool bGotLive;
	local int minStepNo;
	local float CurPercent;
	local int NumActiveChainEntries;
		
	if (Instigator == None || Instigator.Controller == None || ChainHitPawn.length == 0)
	{
		// not worth continuing
		ChainHitPawn.length = 0;
		ChainStepNumber.length = 0;
		ChainHitLocation.length = 0;
		ChainActive.length = 0;
		SetTimer(0, false);
		return;		
	}
	
	// now see if we have anything left to chain
	bGotLive = false;
	for (i=0;i<ChainActive.length;i++)
		if (ChainActive[i] > 0)
			bGotLive = true;
	if (!bGotLive)
	{
		// not worth continuing
		ChainHitPawn.length = 0;
		ChainStepNumber.length = 0;
		ChainHitLocation.length = 0;
		ChainActive.length = 0;
		SetTimer(0, false);
		return;		
	}

	// lets add one to each step
	for (i=0;i<ChainStepNumber.length;i++)
		ChainStepNumber[i]++;
	NumActiveChainEntries = ChainStepNumber.length;
	
	// ok we have stuff in the chain. Lets hit it.	
	C = Level.ControllerList;
	while (C != None)
	{
		// loop round finding other enemies close by
		NextC = C.NextController;
		if ( C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller) && C.bGodMode == False)
		{
			// lets see if already in list
			bGotLive = false;
			for (i=0;i<ChainHitPawn.length;i++)
				if (ChainHitPawn[i] == C.Pawn)
					bGotLive = true;
			
			if (!bGotLive)
			{			
				// could be hit. Lets see if in range of a target
				minStepNo = MaxSteps+1;
				besti = -1;
				for (i=0;i<ChainHitPawn.length;i++)
				{
					if (ChainHitPawn[i] == None)
						Ploc = ChainHitLocation[i];
					else
						Ploc = ChainHitPawn[i].Location;
					if (ChainStepNumber[i] <= MaxSteps && FastTrace(C.Pawn.Location, Ploc))
					{
						// can see it, but is it in range
						// work out what factor we are at
						CurPercent = 1.0;
						for (j=1; j<ChainStepNumber[i]; j++)
							CurPercent *= StepDamageFraction;
						if (VSize(C.Pawn.Location - Ploc) < (MaxStepRange * CurPercent) && minStepNo > ChainStepNumber[i])
						{
							minStepNo = ChainStepNumber[i];
							besti = i;
						}
					}
				}
				if (besti >= 0)
				{
					// we have a new target
					if (ChainHitPawn[besti] == None)
						Ploc = ChainHitLocation[besti];
					else
						Ploc = ChainHitPawn[besti].Location;
					ChainPawn(C.Pawn, C.Pawn.Location, Ploc, minStepNo);
				}
			
			}		
		}

		C = NextC;
	}

	// ok, so we have fired from the ones we already had.		
	for (i=0;i<NumActiveChainEntries;i++)
		ChainActive[i] = 0;
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
     HitEmitterClass=Class'RedBoltEmitter'
     PickupClass=None
     IconMaterial=Texture'AW-2004Particles.Weapons.PlasmaHeadRed'
     ItemName="Chain Lightning"
     MaxRange=3000.000000
     MaxStepRange=650.0
     AdrenalineForHit=50
     AdrenalineForMiss=4
     FirstDamage=180
     StepDamageFraction=0.7
     MaxSteps=3
     TimeBetweenUses=2.0
}
