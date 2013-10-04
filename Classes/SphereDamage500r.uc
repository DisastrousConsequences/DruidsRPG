class SphereDamage500r extends Emitter
	placeable;

// for changing the size of the sphere:
// A radius of 900 requires Sizescale set to 200, and StartSizeRange set to 7.
// if you want a radius of 1800, double the StartSizeRange to 14.
 
defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'DCStatic.Meshes.SphereDamage'
         RenderTwoSided=True
         UseParticleColor=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=10.000000),Y=(Max=10.000000),Z=(Max=10.000000))
         SizeScale(0)=(RelativeSize=200.000000)
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         SecondsBeforeInactive=0.000000
         StartSizeRange=(X=(Min=3.880000,Max=3.880000),Y=(Min=3.880000,Max=3.880000),Z=(Min=3.880000,Max=3.880000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.000000,Max=0.000000)
     End Object
     Emitters(0)=MeshEmitter'SphereDamage500r.MeshEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     Style=STY_Masked
     bDirectional=True
     bCollideActors=false
     bBlockZeroExtentTraces=false
     bBlockNonZeroExtentTraces=false
     bBlockKarma=false
     bBlockActors=false
     bCollideWorld=false
     bBlockPlayers=false
     bWorldGeometry=false
     bProjTarget=false
}
