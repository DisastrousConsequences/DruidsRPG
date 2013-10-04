class FireBallProjectile extends Projectile;

var FireBall FireBallEffect;
var	xEmitter SmokeTrail;
var Material ModifierOverlay;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    if( Pawn(Owner) != None )
        Instigator = Pawn( Owner );
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
	{
        FireBallEffect = Spawn(class'FireBall', self);
        FireBallEffect.SetBase(self);
        SmokeTrail = Spawn(class'BelchFlames',self);
	}

	Velocity = Speed * Vector(Rotation); 

    SetTimer(0.4, false);
}

simulated function PostNetBeginPlay()
{
	local PlayerController PC;
	
	Super.PostNetBeginPlay();
	
	if ( Level.NetMode == NM_DedicatedServer )
		return;
		
	PC = Level.GetLocalPlayerController();
	if ( (Instigator != None) && (PC == Instigator.Controller) )
		return;
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
}

function Timer()
{
    SetCollisionSize(20, 20);
}

simulated function Destroyed()
{
    if (FireBallEffect != None)
    {
		if ( bNoFX )
			FireBallEffect.Destroy();
		else
			FireBallEffect.Kill();
	}
	if ( SmokeTrail != None )
		SmokeTrail.mRegen = False;
	Super.Destroyed();
}

simulated function DestroyTrails()
{
    if (FireBallEffect != None)
        FireBallEffect.Destroy();
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) ) 
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}
					
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local bool VictimPawn;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;
			VictimPawn = false;
			if (Pawn(Victims) != None)
			{
				VictimPawn = true;
			}
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
			//now see if we killed it
			if (VictimPawn)
			{
				if (Victims == None || Pawn(Victims) == None || Pawn(Victims).Health <= 0 )
					class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator, class'WeaponFireBall');	// assume killed
			}
			if (Victims != None)
			{
				Victims.SetOverlayMaterial(ModifierOverlay, 1.0, false);
				if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
					Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
			}

		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;
		damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);
		VictimPawn = false;
		if (Pawn(Victims) != None)
		{
			VictimPawn = true;
		}
		Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			(damageScale * Momentum * dir),
			DamageType
		);
		//now see if we killed it
		if (VictimPawn)
		{
			if (Victims == None || Pawn(Victims) == None || Pawn(Victims).Health <= 0 )
				class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator, class'WeaponFireBall');	// assume killed
		}
		if (Victims != None)
		{
			Victims.SetOverlayMaterial(ModifierOverlay, 1.0, false);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
		}
	}

	bHurtEntry = false;
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
	local PlayerController PC;
	
	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'NewExplosionA',,,HitLocation + HitNormal*20,rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
	}
    if ( Role == ROLE_Authority )
    {
        HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
    }
	SetCollisionSize(0.0, 0.0);
	Destroy();
}

defaultproperties
{
    ExplosionDecal=class'RocketMark'
    Speed=3500
    MaxSpeed=4000
    Damage=200
    DamageRadius=220
    MomentumTransfer=70000
    MyDamageType=class'DamTypeFireBall'
    bNetTemporary=True
    LifeSpan=10.0
    DrawType=DT_Sprite
    Skins(0)=Texture'XEffects.Skins.MuzFlashWhite_t'
    Texture=Texture'AW-2004Particles.Fire.NapalmSpot'
    Style=STY_Translucent
    bAlwaysFaceCamera=true
    DrawScale=0.15
    CollisionRadius=10
    CollisionHeight=10
    bProjTarget=True
    bDynamicLight=true
    LightType=LT_Steady
    LightEffect=LE_QuadraticNonIncidence
    LightBrightness=255
    LightHue=195
    LightSaturation=85
    LightRadius=4
    AmbientSound=Sound'WeaponSounds.ShockRifle.ShockRifleProjectile'
    SoundRadius=100
    SoundVolume=50
    ImpactSound=Sound'WeaponSounds.ShockRifle.ShockRifleExplosion'
    ForceType=FT_Constant
    ForceScale=5.0
    ForceRadius=40.0
    bSwitchToZeroCollision=true
    bOnlyDirtyReplication=true
    FluidSurfaceShootStrengthMod=8.0
    MaxEffectDistance=7000.0
    CullDistance=+4000.0
	ModifierOverlay=Texture'AW-2004Particles.Cubes.RedS1'
}
