class ArtifactLightningBolt extends EnhancedRPGArtifact
		config(UT2004RPG);

var RPGRules Rules;
var class<xEmitter> HitEmitterClass;
var config float TargetRadius;
var config int DamagePerAdrenaline;
var config int MaxDamage;
var config int AdrenalineForMiss;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < 30)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.5 )
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

function Activate()
{
	local Controller C, BestC;
	local xEmitter HitEmitter;
	local int MostHealth;
	local int NewHealth;
	local int HealthTaken;
	local Actor A;
	local int UDamageAdjust;
	local Vehicle V;
	local int DamageToDo;
	local bool RunningTriple;
	local int ExtraDamage;

	if ((Instigator == None) || (Instigator.Controller == None))
	{
		bActive = false;
		GotoState('');
		return;	// really corrupt
	}

	if (LastUsedTime + TimeBetweenUses > Instigator.Level.TimeSeconds)		// no reduction in time otherwise get spamming of bolt
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

	C = Level.ControllerList;
	BestC = None;
	MostHealth = 0;
	while (C != None)
	{
		// loop round finding strongest enemy to attack
		if ( C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller)
		     && VSize(C.Pawn.Location - Instigator.Location) < TargetRadius && FastTrace(C.Pawn.Location, Instigator.Location) && C.bGodMode == False)
		{
			if (C.Pawn.Health > MostHealth)
			{
				MostHealth = C.Pawn.Health;
				BestC = C;
			}
		}
		C = C.NextController;
	}
	if ((MostHealth > 0) && (BestC != None) && (BestC.Pawn != None))
	{
		HitEmitter = spawn(HitEmitterClass,,, Instigator.Location, rotator(BestC.Pawn.Location - Instigator.Location));
		if (HitEmitter != None)
			HitEmitter.mSpawnVecA = BestC.Pawn.Location;

		A = spawn(class'BlueSparks',,, Instigator.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
		}
		A = spawn(class'BlueSparks',,, BestC.Pawn.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*BestC.Pawn.TransientSoundVolume,,BestC.Pawn.TransientSoundRadius);
		}
		
		// damage it. First limit the damage. Otherwise get instagibs which are not fair
		//now limit according to how much adrenaline we have
		DamageToDo = min(MaxDamage,DamagePerAdrenaline * (Instigator.Controller.Adrenaline/AdrenalineUsage));

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
			if (BestC.Pawn.Health > DamageToDo)
			{
			    ExtraDamage = min(DamageToDo, BestC.Pawn.Health - DamageToDo);
			    if (Rules == None)
			        CheckRPGRules();
				if (Rules != None)
				    Rules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), BestC.Pawn, ExtraDamage);
			}
		}
		else
			UDamageAdjust = 1;
				
		BestC.Pawn.TakeDamage(DamageToDo, Instigator, BestC.Pawn.Location, vect(0,0,0), class'DamTypeLightningBolt');
        
		//first see if we killed it
		if (BestC == None || BestC.Pawn == None || BestC.Pawn.Health <= 0 )
			class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator, class'WeaponBolt');

		// see how much damage we caused, and remove only that much adrenaline
		NewHealth = 0;
		if (BestC != None && BestC.Pawn != None)
			NewHealth = BestC.Pawn.Health;
		if (NewHealth < 0)
			NewHealth = 0;
		HealthTaken = MostHealth - NewHealth;
		if (HealthTaken < 0)
			HealthTaken = MostHealth;	// Ghost knocks the health up to 9999

		// now check for double/triple damage, and adjust adrenaline taken accordingly
		if (!RunningTriple)
			Instigator.Controller.Adrenaline -= (HealthTaken*AdrenalineUsage) / (DamagePerAdrenaline * UDamageAdjust);	    // take less adrenaline
		else
			Instigator.Controller.Adrenaline -= (HealthTaken*AdrenalineUsage) / DamagePerAdrenaline;	    				// take single damage adrenaline

		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		SetRecoveryTime(TimeBetweenUses);
	}
	else
	{
    	// missed. Take off the miss adrenaline penalty
		Instigator.Controller.Adrenaline -= (AdrenalineForMiss*AdrenalineUsage);
		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		SetRecoveryTime(TimeBetweenUses);	// tough life isnt it?
	}

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
     TargetRadius=2000.000000
     HitEmitterClass=Class'LightningBoltEmitter'
     DamagePerAdrenaline=4
     AdrenalineForMiss=10
     PickupClass=Class'ArtifactLightningBoltPickup'
     IconMaterial=Texture'DCText.Icons.LightningBoltIcon'
     ItemName="Lightning Bolt"
     MaxDamage=100
     TimeBetweenUses=1.5
}
