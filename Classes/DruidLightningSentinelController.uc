class DruidLightningSentinelController extends Controller
	config(UT2004RPG);

var Controller PlayerSpawner;
var class<xEmitter> HitEmitterClass;

var config float MaxHealthMultiplier;
var config float MinHealthMultiplier;
var config int MaxDamagePerHit;
var config int MinDamagePerHit;
var config float TargetRadius;

var float DamageAdjust;		// set by AbilityLoadedEngineer 

function SetPlayerSpawner(Controller PlayerC)
{
	PlayerSpawner = PlayerC;
	if (PlayerSpawner.PlayerReplicationInfo != None && PlayerSpawner.PlayerReplicationInfo.Team != None )
	{
		if (PlayerReplicationInfo == None)
			PlayerReplicationInfo = spawn(class'PlayerReplicationInfo', self);
		PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName$"'s Sentinel";
		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bBot = true;
		PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
		PlayerReplicationInfo.RemoteRole = ROLE_None;
	}
}

function PostBeginPlay()
{
	SetTimer(1.0, true);
	Super.PostBeginPlay();
}

function Timer()
{
	// lets target some enemies
	local Controller C, NextC;
	local int DamageDealt;
	local xEmitter HitEmitter;
	local float damageScale, dist;
	local vector dir;

	if (PlayerSpawner == None || PlayerSpawner.Pawn == None)
		return;

	C = Level.ControllerList;
	while (C != None)
	{
		// get next controller here because C may be destroyed if it's a nonplayer and C.Pawn is killed
		NextC = C.NextController;
			
		if (C != None && C.Pawn != None && Pawn != None && C.Pawn != Pawn && C.Pawn != PlayerSpawner.Pawn && C.Pawn.Health > 0
		  && VSize(C.Pawn.Location - Pawn.Location) < TargetRadius && FastTrace(C.Pawn.Location, Pawn.Location)
		   && ((TeamGame(Level.Game) != None && !C.SameTeamAs(PlayerSpawner)) 	// on a different team
			|| (TeamGame(Level.Game) == None && C.Pawn.Owner != PlayerSpawner)))		// or just not me
		{
			// scale damage done according to distnace from sentinel
			dir = C.Pawn.Location - Pawn.Location;
			dist = FMax(1,VSize(dir));
			damageScale = 1 - FMax(0,dist/TargetRadius);

			DamageDealt = C.Pawn.HealthMax * DamageAdjust * ((damageScale * (MaxHealthMultiplier-MinHealthMultiplier)) + MinHealthMultiplier);
			DamageDealt = max(MinDamagePerHit * DamageAdjust, DamageDealt);
			DamageDealt = min(MaxDamagePerHit * DamageAdjust, DamageDealt);
			C.Pawn.TakeDamage(DamageDealt, Pawn, C.Pawn.Location, vect(0,0,0), class'DamTypeLightningSent');

			if (C != None && C.Pawn != None && Pawn != None)
			{
				HitEmitter = spawn(HitEmitterClass,,, Pawn.Location, rotator(C.Pawn.Location - Pawn.Location));
				if (HitEmitter != None)
					HitEmitter.mSpawnVecA = C.Pawn.Location;
			}

			//hack for invasion monsters so they'll fight back
			if (C != None && C.Pawn != None && MonsterController(C) != None && FriendlyMonsterController(C) == None && Pawn != None 
		     	  && C.Enemy != Pawn && FastTrace(Pawn.Location,C.Pawn.Location))
		    {
		    	if (C.Enemy == None || FRand() < 0.15 )
					MonsterController(C).ChangeEnemy(Pawn, C.CanSee(Pawn));
			}
		}
		C = NextC;
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
     TargetRadius=1200.000000
     //The actual damage per hit is calculated off the base health of the target, and the closeness to the sentinel
     MaxHealthMultiplier=0.100000
     MinHealthMultiplier=0.020000
     MaxDamagePerHit=30
     MinDamagePerHit=3
     HitEmitterClass=Class'XEffects.LightningBolt'
     //HealthMultiplier is the percentage of life that will be taken from a single hit.

     DamageAdjust=1.0
}