class DruidLinkSentinelController extends Controller
	config(UT2004RPG);

var Controller PlayerSpawner;
var RPGStatsInv StatsInv;
var MutUT2004RPG RPGMut;

var config float TimeBetweenShots;
var config float LinkRadius;
var config float VehicleHealPerShot;
var class<xEmitter> TurretLinkEmitterClass;        // for linking to turrets where we get xp
var class<xEmitter> VehicleLinkEmitterClass;       // for linking to vehicles where we do not get xp

simulated event PostBeginPlay()
{
	local Mutator m;

	super.PostBeginPlay();

	if (Level.Game != None)
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutUT2004RPG(m) != None)
			{
				RPGMut = MutUT2004RPG(m);
				break;
			}
}

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
		StatsInv = RPGStatsInv(PlayerSpawner.Pawn.FindInventoryType(class'RPGStatsInv'));

	}
	SetTimer(TimeBetweenShots, true);
}

function Timer()
{
	// lets see if we can link to anything
	Local Pawn LoopP;
	Local Controller C;
	local xEmitter HitEmitter;

	if (Pawn == None || PlayerSpawner == None)
	    return;
	    
	foreach DynamicActors(class'Pawn', LoopP)
	{
		// first check if the pawn is anywhere near
	    if (LoopP != None &&  LoopP.Health > 0 && Pawn != None && VSize(LoopP.Location - Pawn.Location) < LinkRadius && FastTrace(LoopP.Location, Pawn.Location) && LoopP != Pawn)
	    {
			// ok, let's go for it
			C = LoopP.Controller;
			// must be either not controlled, or on same team
			if (C == None || C.SameTeamAs(self) )
			{
				//ok lets see if we can help.
			    if (Vehicle(LoopP) != None || DruidEnergyWall(LoopP) != None)
			    {
			        // lets see what we can do to help. If a turret, then establish a link. If just a vehicle or sentinel, just heal if it needs it
			        if (DruidMinigunTurret(LoopP) != None || DruidBallTurret(LoopP) != None || DruidEnergyTurret(LoopP) != None || DruidIonCannon(LoopP) != None)
					{   // not a link turret :(
					    // estalish an xp link
						LoopP.HealDamage(VehicleHealPerShot, self, class'DamTypeLinkShaft');
						HitEmitter = spawn(TurretLinkEmitterClass,,, Pawn.Location, rotator(LoopP.Location - Pawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = LoopP.Location;
					}
				    else if (LoopP.Health < LoopP.HealthMax)
				    {
					    // can at least add some health
						LoopP.GiveHealth(VehicleHealPerShot, LoopP.HealthMax);
						HitEmitter = spawn(VehicleLinkEmitterClass,,, Pawn.Location, rotator(LoopP.Location - Pawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = LoopP.Location;
						// and probably ought to get same xp as armor healing powerup on defsent. But sadly that is zero, so nothing.
					}
				}
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
	LinkRadius=700.000000
	TurretLinkEmitterClass=Class'DruidLinkSentinelBeamEffect'	
	VehicleLinkEmitterClass=Class'BronzeBoltEmitter'
	TimeBetweenShots=0.25
	VehicleHealPerShot=20
}