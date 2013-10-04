class DruidArtifactMakeMagicWeaponPickup extends RPGArtifactPickup;

defaultproperties
{
	  InventoryType=Class'DruidArtifactMakeMagicWeapon'
	  PickupMessage="You got the artifact to make magic weapons!"
	  PickupSound=Sound'PickupSounds.ShieldPack'
	  PickupForce="ShieldPack"
	  DrawType=DT_StaticMesh
	  StaticMesh=StaticMesh'XPickups_rc.UDamagePack'
	  bAcceptsProjectors=False
	  DrawScale=0.075000
	  Skins(0)=Shader'XGameShaders.PlayerShaders.PlayerTrans'
	  AmbientGlow=255
}
