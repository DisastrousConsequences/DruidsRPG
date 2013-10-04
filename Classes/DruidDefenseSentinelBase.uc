class DruidDefenseSentinelBase extends ASTurret_Base;
#exec OBJ LOAD FILE=..\Animations\AS_Vehicles_M.ukx

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretBase'
	DrawScale=0.14
	Skins(0)=FinalBlend'DCText.DomShaders.DefensePanFinal'
	Skins(1)=FinalBlend'DCText.DomShaders.DefensePanFinal'

	CollisionHeight=70.0
	CollisionRadius=30.0
	AmbientGlow=1
}