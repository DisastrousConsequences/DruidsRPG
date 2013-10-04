class ArtifactPlusAddonPickup extends RPGArtifactPickup;

defaultproperties
{
     InventoryType=Class'ArtifactPlusAddon'
     PickupMessage="You got a Modifier Plus Powerup"
     skins(0)=FinalBlend'EpicParticles.Shaders.IonFallFinal'
     MaxDesireability=0.600000
     RespawnTime=30.000000
     PickupSound=Sound'PickupSounds.AdrenelinPickup'
     PickupForce="AdrenelinPickup"
     DrawType=DT_StaticMesh
     StaticMesh=staticmesh'NewWeaponPickups.AssaultPickupSM'
     Physics=PHYS_Rotating
     DrawScale=0.250000
     AmbientGlow=255
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     CollisionRadius=32.000000
     CollisionHeight=23.000000
     Mass=10.000000
     RotationRate=(Yaw=24000)
     UV2Mode=UVM_Skin 
}
