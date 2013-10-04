class DruidArtifactLightningRod extends EnhancedRPGArtifact
	config(UT2004RPG);

var config float CostPerHit;
var config float HealthMultiplier;
var config int MaxDamagePerHit;
var config int MinDamagePerHit;

// copied from ArtifactLightningRod since no longer derived from it
var float TargetRadius;
var class<xEmitter> HitEmitterClass;

var RPGRules Rules;

function PostBeginPlay()
{
	super.PostBeginPlay();

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

function EnhanceArtifact(float Adusage)
{
	AdrenalineUsage = (AdUsage + 2.0)/3.0;	// getting double from the rod would be too much. So only step one third the way.
}

function BotConsider()
{
	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
	{
		Activate();		// switch off if no enemies
		return;
	}
		
	if (Instigator.Controller.Adrenaline < 30)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive())
	{ 
		if (Instigator.HasUDamage())
			Activate();			// works a treat with the DD
		else if( FRand() < 0.7 )
			Activate();
	}
}

function Activate()
{
	if (class'DruidDoubleModifier'.static.HasTripleRunning(Instigator))
		return; // cant run with triple

	Super.Activate();
}

state Activated
{
	function Timer()
	{
		local Controller C, NextC;
		local int DamageDealt;
		local xEmitter HitEmitter;
		local int lCost;
		local int UDamageAdjust;
		local bool RunningTriple;
		local int ExtraDamage;

		if(Instigator == None || Instigator.Controller == None)
			return; //must have a controller when active. (Otherwise they're probably ghosting)

		//need to be moving for it to do anything... so can't just sit somewhere and camp
		if (VSize(Instigator.Velocity) ~= 0)
			return;

		// now check if we have a udamage running, and want to limit damage
		RunningTriple = false;
		If (Instigator.HasUDamage())
		{
			UDamageAdjust = 2;				                	// assume double damage. If it is the triple, and not invasion, then they do more damage but use more adrenaline
			if (class'DruidDoubleModifier'.static.HasTripleRunning(Instigator))     // not allowed to get triple bonus
			{
			    RunningTriple = true;                           // shouldn't be - but just in case
			}
		}
		else
			UDamageAdjust = 1;

		C = Level.ControllerList;
		while (C != None)
		{
			// get next controller here because C may be destroyed if it's a nonplayer and C.Pawn is killed
			NextC = C.NextController;
			
			//Is this just some sort of weird unreal script bug? Sometimes C is None
			if(C == None)
			{
				C = NextC;
				break;
			}
			
			if ( C.Pawn != None && Instigator != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller)
			     && VSize(C.Pawn.Location - Instigator.Location) < TargetRadius && FastTrace(C.Pawn.Location, Instigator.Location) )
			{
				//deviation from Mysterial's class to figure out the damage and adrenaline drain.
				// notincreasing the max damage as that would drain too fast.
				DamageDealt = max(min(C.Pawn.HealthMax * HealthMultiplier, MaxDamagePerHit), MinDamagePerHit);
				
				lCost = (DamageDealt * CostPerHit) * AdrenalineUsage;
				
				if(lCost < 1)
					lCost = 1;
				
				if(lCost < Instigator.Controller.Adrenaline)
				{
					// now check if we have a udamage running, and want to limit damage and grant extra xp (since RPG doesn't do it for superweapon damage
					if (UDamageAdjust > 1)
					{   // running a double or triple
						if (RunningTriple)     // not allowed to get triple bonus
						{
							DamageDealt = DamageDealt/UDamageAdjust;          // adjust intended damage down so expected damage done after triple ups it, but leave cost the same
						}
						// now check if we need to add xp on for the extra damage done by the double
						if (C.Pawn.Health > DamageDealt)
						{
						    ExtraDamage = min(DamageDealt, C.Pawn.Health - DamageDealt);
						    if (Rules == None)
						        CheckRPGRules();
							if (Rules != None)
							    Rules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), C.Pawn, ExtraDamage);
						}
					}
					//Is this just some sort of weird unreal script bug? Sometimes C is None
					if(C == None)
					{
						C = NextC;
						break;
					}

					HitEmitter = spawn(HitEmitterClass,,, Instigator.Location, rotator(C.Pawn.Location - Instigator.Location));
					if (HitEmitter != None)
						HitEmitter.mSpawnVecA = C.Pawn.Location;

					if(C == None)
					{
						C = NextC;
						break;
					}

					if ( Instigator != None && Instigator.Controller != None)
					{
						C.Pawn.TakeDamage(DamageDealt, Instigator, C.Pawn.Location, vect(0,0,0), class'DamTypeEnhLightningRod');
						Instigator.Controller.Adrenaline -=lCost;
						if (Instigator.Controller.Adrenaline < 0)
							Instigator.Controller.Adrenaline = 0;

						//now see if we killed it
						if (C == None || C.Pawn == None || C.Pawn.Health <= 0 )
							if ( Instigator != None)
								class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator, class'WeaponRod');	// assume killed

					}
				}
			}
			C = NextC;
		}
	}

	function BeginState()
	{
		SetTimer(0.5, true);
		bActive = true;
	}

	function EndState()
	{
		SetTimer(0, false);
		bActive = false;
	}
}

simulated function Tick(float deltaTime)
{
	if (bActive)
	{
		if (Instigator != None && Instigator.Controller != None)	// not ghosting
		{
			Instigator.Controller.Adrenaline -= deltaTime * CostPerSec;
			if (Instigator.Controller.Adrenaline <= 0.0)
			{
				Instigator.Controller.Adrenaline = 0.0;
				UsedUp();
			}
		}
	}
}

defaultproperties
{
     TargetRadius=2000.000000
     //The actual damage per hit is calculated off the base health of the target
     MaxDamagePerHit=70
     MinDamagePerHit=5
     HitEmitterClass=Class'XEffects.LightningBolt'
     //deviation from Mysterial's class This is the slow drain when nothing is occurring.
     CostPerSec=1
     //CostPerHit is the amount of adrenaline drained when you do a point of damage to a monster
     CostPerHit=0.250000
     //HealthMultiplier is the percentage of life that will be taken from a single hit of the LR.
     HealthMultiplier=0.100000
     PickupClass=Class'DruidArtifactLightningRodPickup'
     IconMaterial=Texture'UTRPGTextures.Icons.LightningIcon'
     ItemName="Lightning Rod"
}