class DruidBlock extends Pawn;
#exec OBJ LOAD FILE=..\StaticMeshes\DCStatic.usx
var byte Team;

function SetTeamNum(byte T)
{
    Team = T;
}

simulated function int GetTeamNum()
{
	return Team;
}

function Landed(vector hitNormal)
{
	Super.Landed(hitNormal);
	Velocity = vect(0,0,0);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	local int actualDamage;
	local Controller Killer;
	
	if ( damagetype == None )
	{
		if ( InstigatedBy != None )
			warn("No damagetype for damage by "$instigatedby$" with weapon "$InstigatedBy.Weapon);
		DamageType = class'DamageType';
	}

	if ( Role < ROLE_Authority )
		return;

	if ( Health <= 0 )
		return;

	if ((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
		instigatedBy = DelayedDamageInstigatorController.Pawn;

	if ( (InstigatedBy != None) && InstigatedBy.HasUDamage() )
		Damage *= 2;

	momentum = vect(0,0,0);		// blocks do not move

	if (self != None)
	{
		actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, momentum, DamageType);
		momentum = vect(0,0,0);		// reset in case changed
	}

	Health -= actualDamage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;

	PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, momentum);
	if ( Health <= 0 )
	{
		// pawn died
		if ( DamageType.default.bCausedByWorld && (instigatedBy == None || instigatedBy == self) && LastHitBy != None )
			Killer = LastHitBy;
		else if ( instigatedBy != None )
			Killer = instigatedBy.GetKillerController();
		if ( Killer == None && DamageType.Default.bDelayedDamage )
			Killer = DelayedDamageInstigatorController;
		Died(Killer, damageType, HitLocation);
	}
	else
	{
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, momentum);
		if ( instigatedBy != None && instigatedBy != self )
			LastHitBy = instigatedBy.Controller;
	}
	MakeNoise(1.0);

	if (Health <= 0)
		destroy();
	else
		Velocity = vect(0,0,0);
}

//event EncroachedBy( actor Other )
//{
	// do nothing. Adding this stub stops telefragging of blocks
//}

defaultproperties
{
	bUseCollisionStaticMesh=true
	bUseCylinderCollision=false
	CollisionHeight=15.0
	CollisionRadius=29.5			// even tho bUseCylinderCollision is false, it uses cylinder collision as it falls. So keep these values inside the width.
	RemoteRole=ROLE_SimulatedProxy

	bStatic=False
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'DCStatic.Block.TestBlock'
	Physics=PHYS_Falling
	DrawScale=1.2
	AmbientGlow=10
	bCanBeBaseForPawns=true
	Health=2000
	healthMax=2000
	Mass=10000.0

	bMovable=true
	 bOrientOnSlope=true

	bShouldBaseAtStartup=false		// 2nd to change
	bIgnoreEncroachers=false
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bCollideWorld=true
	bBlockKarma=false
	bNoTeamBeacon=true
	bProjTarget=true
	bBlockZeroExtentTraces=true
	bBlockNonZeroExtentTraces=true

	bSkipActorPropertyReplication=false
	bReplicateMovement=true
	bUpdateSimulatedPosition=true
	NetUpdateFrequency=4
	ControllerClass=None
	bAlwaysRelevant=true
}
