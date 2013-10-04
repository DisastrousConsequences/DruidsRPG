class ArtifactSphereHealingPickup extends RPGArtifactPickup;

defaultproperties
{
     InventoryType=Class'ArtifactSphereHealing'
     PickupMessage="You got the Sphere of Healing!"
     PickupSound=Sound'PickupSounds.SniperRiflePickup'		
     PickupForce="SniperRiflePickup"				
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Editor.TexPropSphere'	 
     bAcceptsProjectors=False
     DrawScale=0.075000
     Skins(0)=Shader'UTRPGTextures2.Overlays.PulseBlueShader1'
     AmbientGlow=255
}
