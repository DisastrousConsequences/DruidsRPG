class DruidCeilingLightningSentinel extends ASTurret;
#exec OBJ LOAD FILE=..\Animations\AS_Vehicles_M.ukx

function AddDefaultInventory()
{
	// do nothing. Do not want default weapon adding
}

defaultproperties
{
	CollisionHeight=60.0
	CollisionRadius=45.0

	TurretBaseClass=None
	TurretSwivelClass=None

	DefaultWeaponClassName=""		// perhaps causes 2 null class load errors?
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'AS_Vehicles_M.CeilingTurretBase'
	Skins(0)=Combiner'DCText.Turrets.CeilingLightning_C'
	Skins(1)=Combiner'DCText.Turrets.CeilingLightning_C'
	DrawScale=0.3
	AmbientGlow=120
	VehicleNameString="Ceiling LightSentinel"
	bCanBeBaseForPawns=false
	bAutoTurret=true
}
