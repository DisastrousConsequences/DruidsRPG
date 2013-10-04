class DruidLinkSentinel extends ASTurret;
#exec OBJ LOAD FILE=..\Animations\AS_Vehicles_M.ukx

simulated event PostNetBeginPlay()
{
	// Static (non rotating) base
	if ( TurretBaseClass != None )
	{
	    // now check if on ceiling or floor. Passed in rotation yaw. 0=ceiling.
	    if (OriginalRotation.Yaw == 0)
			TurretBase = Spawn(TurretBaseClass, Self,, Location+vect(0,0,37), OriginalRotation);
	    else
			TurretBase = Spawn(TurretBaseClass, Self,, Location-vect(0,0,37), OriginalRotation);
	}

	// Swivel, rotates left/right (Yaw)
	if ( TurretSwivelClass != None )
	{
		TurretSwivel = Spawn(TurretSwivelClass, Self,, Location, OriginalRotation);
	}

	super(ASVehicle).PostNetBeginPlay();
}

function AddDefaultInventory()
{
	// do nothing. Do not want default weapon adding
}

defaultproperties
{
	CollisionHeight=0.0
	CollisionRadius=0.0
	Skins(0)=shader'epicparticles.shaders.inbisthing'
	Skins(1)=shader'epicparticles.shaders.inbisthing'

	TurretBaseClass=class'DruidLinkSentinelBase'
	TurretSwivelClass=class'DruidLinkSentinelSwivel'
	DefaultWeaponClassName=""		// perhaps causes 2 null class load errors?
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
	DrawScale=0.25
	AmbientGlow=250
	VehicleNameString="Link Sentinel"
	bCanBeBaseForPawns=false
	bAutoTurret=true
}

