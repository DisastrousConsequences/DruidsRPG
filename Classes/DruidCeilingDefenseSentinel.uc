class DruidCeilingDefenseSentinel extends DruidDefenseSentinel ;
#exec OBJ LOAD FILE=..\Animations\AS_Vehicles_M.ukx

defaultproperties
{
	CollisionHeight=60.0
	CollisionRadius=45.0

	TurretBaseClass=None
	TurretSwivelClass=None

	DefaultWeaponClassName=""		// perhaps causes 2 null class load errors?
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'AS_Vehicles_M.CeilingTurretBase'

	Skins(0)=Combiner'DCText.Turrets.CeilingDefense_C'
	Skins(1)=Combiner'DCText.Turrets.CeilingDefense_C'
	DrawScale=0.3
	VehicleNameString="Ceiling Defense Sentinel"
}
