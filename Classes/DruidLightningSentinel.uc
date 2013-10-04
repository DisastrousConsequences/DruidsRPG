class DruidLightningSentinel extends ASTurret;
#exec OBJ LOAD FILE=..\Animations\AS_Vehicles_M.ukx

function AddDefaultInventory()
{
	// do nothing. Do not want default weapon adding
}

defaultproperties
{
	CollisionHeight=0.0
	CollisionRadius=0.0

	TurretBaseClass=class'DruidLightningSentinelBase'
	DefaultWeaponClassName=""		// perhaps causes 2 null class load errors?
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
	DrawScale=0.5
	AmbientGlow=120
	VehicleNameString="Lightning Sentinel"
	bCanBeBaseForPawns=false
	bAutoTurret=true
}
