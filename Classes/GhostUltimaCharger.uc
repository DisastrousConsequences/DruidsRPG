class GhostUltimaCharger extends Actor;

var xEmitter ChargeEmitter;
var float ChargeTime;
var float Damage, DamageRadius;
var class<DamageType> DamageType;
var float MomentumTransfer;
var AvoidMarker Fear;
var Controller InstigatorController;

function DoDamage(float Radius)
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local bool gotPawn;
	local bool isEnemy;

	if (Instigator == None && InstigatorController != None)
		Instigator = InstigatorController.Pawn;

	//HurtRadius(), with some modifications

	if(bHurtEntry)
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors(class 'Actor', Victims, Radius, Location)
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if ( Victims != self && Victims != Instigator && Victims.Role == ROLE_Authority && !Victims.IsA('FluidSurfaceInfo'))
		{
			isEnemy = true;		// hit everything unless on same team
			if ( Pawn(Victims) != None)
			{
				gotPawn = true;
				if (Pawn(Victims).Health <= 0)
					isEnemy = false;	// no point hitting it, already dead
				else if (TeamGame(Level.Game) != None && TeamGame(Level.Game).FriendlyFireScale == 0)
				{
					// may be on same side, and so not an enemy
					if (InstigatorController == None || Pawn(Victims).Controller == None || Pawn(Victims).Controller.SameTeamAs(InstigatorController)) 
					{	// if either controller None then cant tell which team it is on - so leave
						isEnemy = false;
					}
				}
			}
			else
			{
				// most non pawns will be hit unless owned by the correct team
				if (Victims.Owner != None && Pawn(Victims.Owner) != None && Pawn(Victims.Owner).Controller != None && InstigatorController != None && Pawn(Victims.Owner).Controller.SameTeamAs(InstigatorController))
					isEnemy = false;
				else
					gotPawn = false;		// isEnemy but not pawn
			}
			if ( isEnemy )
			{
				// ok, hit it
				//set HitDamageType early so AbilityUltima.ScoreKill() can use it
				if (gotPawn)
					Pawn(Victims).HitDamageType = DamageType;
				Victims.SetDelayedDamageInstigatorController(InstigatorController);

				dir = Victims.Location - Location;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

				Victims.TakeDamage
				(
					damageScale * Damage,
					Instigator,
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(damageScale * MomentumTransfer * dir),
					DamageType
				);
				//now see if we killed it
				if (gotPawn && Instigator != None)
				{
					if(Victims == None || Pawn(Victims) == None || Pawn(Victims).Health <= 0 )
						class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator, class'WeaponUltima');	// assume killed. Could be ghosting, but this is only for the F3 stats
				}
	
			}
		}
	}
	bHurtEntry = false;
}

simulated function PostBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
		ChargeEmitter = spawn(class'UltimaChargeEmitter');

	if (Role == ROLE_Authority)
		InstigatorController = Controller(Owner);

	Super.PostBeginPlay();
}

simulated function Destroyed()
{
	if (ChargeEmitter != None)
		ChargeEmitter.Destroy();

	Super.Destroyed();
}

auto state Charging
{
Begin:
	Fear = spawn(class'AvoidMarker');
	Fear.SetCollisionSize(DamageRadius, 200);
	Fear.StartleBots();

	Sleep(ChargeTime);
	spawn(class'UltimaExplosion');
	bHidden = true; //for netplay - makes it irrelevant
	if (ChargeEmitter != None)
		ChargeEmitter.Destroy();
	MakeNoise(1.0);
	PlaySound(sound'WeaponSounds.redeemer_explosionsound');
	DoDamage(DamageRadius*0.125);
	Sleep(0.5);
	DoDamage(DamageRadius*0.300);
	Sleep(0.2);
	DoDamage(DamageRadius*0.475);
	Sleep(0.2);
	DoDamage(DamageRadius*0.650);
	Sleep(0.2);
	DoDamage(DamageRadius*0.825);
	Sleep(0.2);
	DoDamage(DamageRadius);

	if (Fear != None)
		Fear.Destroy();
	Destroy();
}

defaultproperties
{
     Damage=250.000000
     DamageRadius=2000.000000
     DamageType=Class'UT2004RPG.DamTypeUltima'
     MomentumTransfer=200000.000000
     DrawType=DT_None
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000
}
