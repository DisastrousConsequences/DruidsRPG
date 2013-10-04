class AutoGun extends ASTurret;

static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheMaterial( Material'AS_Weapons_TX.Sentinels.FloorTurret' );		// Skins

	L.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.FloorTurretSwivel' );
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.FloorTurretSwivel' );

	super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( Material'AS_Weapons_TX.Sentinels.FloorTurret' );		// Skins

	super.UpdatePrecacheMaterials();
}

simulated event PostBeginPlay()
{
	DefaultWeaponClassName=string(class'DruidWeaponAutoGun');

	super.PostBeginPlay();
}

simulated function PlayFiring(optional float Rate, optional name FiringMode )
{
	PlayAnim('Fire', 0.75);
}

defaultproperties
{
	TransientSoundVolume=0.75
	TransientSoundRadius=512
	bNetNotify=true
	Health=1000
	HealthMax=1000
	DefaultWeaponClassName=""	// class'DruidWeaponAutoGun'

	bSimulateGravity=false
	Physics=PHYS_Rotating
	AirSpeed=0.0
	WaterSpeed=0.0
	AccelRate=0.0
	JumpZ=0.0
	MaxFallSpeed=0.0

	bIgnoreEncroachers=true
    bCollideWorld=false

	bIgnoreForces=true
	bShouldBaseAtStartup=false
	bAutoTurret=true
	AutoTurretControllerClass=None
	SightRadius=+25000.0
	bNonHumanControl=true
	bDefensive=true
	bStationary=true

	bNoTeamBeacon=false

    CollisionHeight=0.0
    CollisionRadius=0.0

	VehicleProjSpawnOffset=(X=45,Y=0,Z=0)

	TurretBaseClass=class'AutoGunBase'
	TurretSwivelClass=class'AutoGunSwivel'

	DrawType=DT_Mesh
	Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
    DrawScale=0.25
    AmbientGlow=48
	VehicleNameString="AutoGun"
	bCanBeBaseForPawns=false
}
