class ArtifactPoisonBlastPickup extends RPGArtifactPickup;

defaultproperties
{
     InventoryType=Class'ArtifactPoisonBlast'
     PickupMessage="You got the PoisonBlast!"
     PickupSound=Sound'PickupSounds.SniperRiflePickup'		
     PickupForce="SniperRiflePickup"				
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AW-2004Particles.Weapons.AcidSphere'	
     DrawScale=0.180000
     AmbientGlow=255
     Physics=PHYS_Rotating
     RotationRate=(Yaw=24000)
}
