class MegaCharger extends Actor;

var xEmitter ChargeEmitter;
var class<DamageType> DamageType;
var float MomentumTransfer;
var AvoidMarker Fear;
var Controller InstigatorController;

var float ChargeTime;
var float Damage;
var float DamageRadius;

function DoDamage(float BlastDamage,float Radius)
{
	local float damageScale, dist;
	local vector dir;
	local Controller C, NextC;

	if (Instigator == None && InstigatorController != None)
		Instigator = InstigatorController.Pawn;

	if (Instigator == None || Instigator.Health <= 0 || Instigator.Controller == None)
		return;

	C = Level.ControllerList;
	while (C != None)
	{
		// get next controller here because C may be destroyed if it's a nonplayer and C.Pawn is killed
		NextC = C.NextController;
		if ( C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller)
		     && VSize(C.Pawn.Location - Location) < Radius && FastTrace(C.Pawn.Location, Location) )
		{
			dir = C.Pawn.Location - Location;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,dist/DamageRadius);
			C.Pawn.TakeDamage(damageScale * BlastDamage, Instigator, C.Pawn.Location, (damageScale * MomentumTransfer * dir), DamageType);

			//now see if we killed it
			if (C == None || C.Pawn == None || C.Pawn.Health <= 0 )
				class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator, class'WeaponMegaBlast');	// assume killed
		}
		C = NextC;
	}
}

simulated function PostBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
		ChargeEmitter = spawn(class'MegaChargeEmitter');

	if (Role == ROLE_Authority)
		InstigatorController = Controller(Owner);

	Super.PostBeginPlay();
}

simulated function Destroyed()
{
	if (ChargeEmitter != None)
		ChargeEmitter.Destroy();

	Super.Destroyed();
}

auto state Charging
{
Begin:
	if (Instigator != None)
	{
		Fear = spawn(class'AvoidMarker');
		Fear.SetCollisionSize(DamageRadius, 200);
		Fear.StartleBots();

		Sleep(ChargeTime);
		if (Instigator != None && Instigator.Health > 0)
		{
			spawn(class'MegaExplosion');
			MakeNoise(1.0);
			PlaySound(sound'WeaponSounds.redeemer_explosionsound');
			DoDamage(Damage*0.3,DamageRadius*0.4);
		}
		bHidden = true; //for netplay - makes it irrelevant
		if (ChargeEmitter != None)
			ChargeEmitter.Destroy();
		Sleep(0.05);
		if (Instigator != None && Instigator.Health > 0)
		{
			DoDamage(Damage*0.2,DamageRadius*0.6);
			Sleep(0.05);
		}
		if (Instigator != None && Instigator.Health > 0)
		{
			DoDamage(Damage*0.2,DamageRadius*0.8);
			Sleep(0.05);
		}
		if (Instigator != None && Instigator.Health > 0)
			DoDamage(Damage*0.3,DamageRadius);
	}
	else if (ChargeEmitter != None)
		ChargeEmitter.Destroy();


	if (Fear != None)
		Fear.Destroy();
	Destroy();
}

defaultproperties
{
     DamageType=Class'DamTypeMegaExplosion'
     MomentumTransfer=20000.000000
     DrawType=DT_None
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000

     Damage=1300.000000
     DamageRadius=1600.000000
     ChargeTime=2.0
}
