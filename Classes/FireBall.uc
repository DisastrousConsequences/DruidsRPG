class FireBall extends Emitter;

simulated function PostBeginPlay()
{
	local PlayerController PC;
	
	Super.PostBeginPlay();
		
	PC = Level.GetLocalPlayerController();
	if ( (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 4000) )
		Emitters[2].Disabled = true;
}

DefaultProperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        ResetAfterChange=True
        AutoReset=True
        SpinParticles=True
        UniformSize=True
        FadeOutStartTime=0.320000
        FadeInEndTime=0.050000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartSpinRange=(X=(Min=0.132000,Max=0.900000))
        StartSizeRange=(X=(Min=45.000000,Max=45.000000),Y=(Min=65.000000,Max=65.000000),Z=(Min=65.000000,Max=65.000000))
        Texture=XEffects.Skins.MuzFlashWhite_t
        LifetimeRange=(Min=0.350000,Max=0.350000)
        WarmupTicksPerSecond=20.000000
        RelativeWarmupTime=1.000000
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        FadeOut=True
        FadeIn=True
        ResetAfterChange=True
        AutoReset=True
        SpinParticles=True
        UniformSize=True
        FadeOutStartTime=0.200000
        FadeInEndTime=0.250000
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        SpinsPerSecondRange=(X=(Min=0.100000,Max=0.300000))
        StartSpinRange=(X=(Min=0.154000,Max=0.913000))
        StartSizeRange=(X=(Min=60.000000,Max=60.000000))
        InitialParticlesPerSecond=2.000000
        Texture=AW-2004Explosions.Fire.FireBall3
        LifetimeRange=(Min=0.400000,Max=0.400000)
        WarmupTicksPerSecond=20.000000
        RelativeWarmupTime=1.000000
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        FadeOut=True
        FadeIn=True
        ResetAfterChange=True
        DetailMode=DM_High
        AutoReset=True
        UniformSize=True
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartSizeRange=(X=(Min=4.500000,Max=4.500000))
        Texture=AW-2004Explosions.Fire.FireBall4
        LifetimeRange=(Min=0.350000,Max=0.350000)
        StartVelocityRange=(X=(Min=-70.000000,Max=70.000000),Y=(Min=-70.000000,Max=70.000000),Z=(Min=-70.000000,Max=70.000000))
        VelocityScale(0)=(RelativeTime=1.000000,RelativeVelocity=(X=-1.000000,Y=-1.000000,Z=-1.000000))
        WarmupTicksPerSecond=50.000000
        RelativeWarmupTime=1.000000
        Name="SpriteEmitter2"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter2'
    bNoDelete=False
}
