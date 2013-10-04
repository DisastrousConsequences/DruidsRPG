class AutoGunController extends SentinelController;

var Controller PlayerSpawner;
var float TimeSinceCheck;

var config int AttractRange;
var config int TargetRange;

var float DamageAdjust;		// set by AbilityLoadedEngineer 
var float CollisionAdjust;
var Pawn CollisionPawn;
var() sound PickupSound;

function SetPlayerSpawner(Controller PlayerC)
{
	PlayerSpawner = PlayerC;
	if (PlayerSpawner.PlayerReplicationInfo != None && (PlayerSpawner.PlayerReplicationInfo.Team != None || TeamGame(Level.Game) == None))
	{
		if (PlayerReplicationInfo == None)
			PlayerReplicationInfo = spawn(class'PlayerReplicationInfo', self);
		PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName$"'s AutoGun";
		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bBot = false;
		PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
//		PlayerReplicationInfo.RemoteRole = ROLE_None;
	}
}

function bool IsTargetRelevant( Pawn Target )
{
	if ( (Target != None) && (Target.Controller != None) 
		&& (Target.Health > 0) && (VSize(Target.Location-Pawn.Location) < Pawn.SightRadius*1.25) 
		&& (((TeamGame(Level.Game) != None) && !SameTeamAs(Target.Controller))
		|| ((TeamGame(Level.Game) == None) && (Target.Owner != PlayerSpawner))))
		return true;

	return false;
}

function Tick(float DeltaTime)
{
	// need to check for any monsters to target

	local Pawn PawnOwner;
	local Vector FaceDir;
	local Vector StartTrace;
	local Vector EndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;
	local Pawn  HitPawn;

	super.Tick(DeltaTime);

	TimeSinceCheck+=DeltaTime;
	
	if (PlayerSpawner == None || PlayerSpawner.Pawn == None)
		return;
	PawnOwner = PlayerSpawner.Pawn;
	if (PawnOwner != CollisionPawn)
	{
	    // using a different pawn, reset collisionadjust
	    CollisionPawn = PawnOwner;
	    CollisionAdjust = default.CollisionAdjust;
	}
	
	if(TimeSinceCheck>0.2)
	{
		TimeSinceCheck = fmin(0.1,TimeSinceCheck - 0.2);        // in case running slowly
		
		if (Enemy != None && Enemy.Health > 0 && VSize(Enemy.Location - Pawn.Location) < TargetRange && FastTrace(Enemy.Location, Pawn.Location))
		    return;     // enemy still alive and in range

		// need to get a new enemy
		// find what pawn looking at
		FaceDir = Vector(PlayerSpawner.GetViewRotation());
		StartTrace = PawnOwner.Location + PawnOwner.EyePosition() +(FaceDir * (CollisionAdjust * PawnOwner.CollisionRadius));
		EndLocation = StartTrace + (FaceDir * TargetRange);

		// See if we hit something.
	   	AHit = Trace(HitLocation, HitNormal, EndLocation, StartTrace, true);
		if ((AHit == None) || (Pawn(AHit) == None) || (Pawn(AHit).Controller == None))
			return;	// didn't hit an enemy
		HitPawn = Pawn(AHit);
		if (HitPawn == PawnOwner)
		{
		    // collisionradius not correct
		    CollisionAdjust += 0.2;
		    Log("********AGC Collision radius increased to:" $ CollisionAdjust @ "for pawn:" $ CollisionPawn);
		}
		else
		if ( HitPawn.Health > 0)
		{
			 if ((TeamGame(Level.Game) != None && !HitPawn.Controller.SameTeamAs(PlayerSpawner)) 	// on a different team
				|| (TeamGame(Level.Game) == None && HitPawn.Owner != PlayerSpawner))						// or just not me
			{
				SeePlayer(HitPawn);
				PlaySound( PickupSound,SLOT_Interact );     // to let the player know

				//hack for invasion monsters so they'll fight back
				if ( HitPawn.Controller != None && MonsterController(HitPawn.Controller) != None && (HitPawn.Controller.Enemy == PlayerSpawner.Pawn || HitPawn.Controller.Enemy == None)
				    && FRand() < 0.2 && VSize(HitPawn.Location - Pawn.Location) < AttractRange)
					MonsterController(HitPawn.Controller).ChangeEnemy(Pawn, HitPawn.Controller.CanSee(Pawn));
			}
		}
	}
}

function Destroyed()
{
	if (PlayerReplicationInfo != None)
		PlayerReplicationInfo.Destroy();

	Super.Destroyed();
}

defaultproperties
{
	AttractRange=1000
	TargetRange=15000

	DamageAdjust=1.0
	CollisionAdjust=1.4
    PickupSound=sound'PickupSounds.AdrenelinPickup'
}
