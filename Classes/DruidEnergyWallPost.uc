class DruidEnergyWallPost extends Actor;

var DruidEnergyWall wall;


simulated function PostNetBeginPlay()
{
	super.PostBeginPlay();
	
	self.SetDrawScale3D( vect(0.8,0.8,1.3) );
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType) 
{
	// Defer damage to Wall...
	if ( Role == Role_Authority && InstigatedBy != Owner )
	{
		if (wall != None)
		{
			if (wall.DamageFraction > 0)
				wall.TakeDamage(Damage/wall.DamageFraction, instigatedBy, hitlocation, momentum, damageType) ;  // since direct hit on post, need to do whole of damage to wall
			// else if Damagefraction <=0 then do not pass on damage.
		}
		else
			wall.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType) ;  
	}
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleBomb'
     DrawScale=0.220000		// to get the mesh about the right size

	bUseCollisionStaticMesh=false
	bUseCylinderCollision=true
	CollisionHeight=60.0
	CollisionRadius=8.0		
	RemoteRole=ROLE_DumbProxy

	bStatic=False
	AmbientGlow=10
	Mass=1000.0

	bMovable=false
	bShouldBaseAtStartup=false		
	bIgnoreEncroacherstrue
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bCollideWorld=true
	bBlockKarma=false
	bProjTarget=true
	bBlockZeroExtentTraces=true
	bBlockNonZeroExtentTraces=true

	bSkipActorPropertyReplication=false
	bReplicateMovement=false
	bUpdateSimulatedPosition=true
	NetUpdateFrequency=4
	bAlwaysRelevant=false
}

