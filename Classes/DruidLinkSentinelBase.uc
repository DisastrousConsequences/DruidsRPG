class DruidLinkSentinelBase extends ASTurret_Base;
#exec OBJ LOAD FILE=..\Animations\AS_Vehicles_M.ukx

defaultproperties
{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'WeaponStaticMesh.SniperAmmoPickup'
	DrawScale=1.8
	Skins(0)=Shader'WeaponSkins.AmmoPickups.BioRifleGlassRef'
	Skins(1)=Shader'WeaponSkins.AmmoPickups.BioRifleGlassRef'

	CollisionHeight=60.0
	CollisionRadius=20.0
	AmbientGlow=10
}
