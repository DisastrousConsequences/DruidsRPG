class AutoGunSwivel extends ASTurret_Minigun_Swivel;

var rotator startrot;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	startrot = Rotation;
}

simulated function UpdateSwivelRotation( Rotator TurretRotation )
{
	local Rotator SwivelRotation;

	SwivelRotation			= TurretRotation;
	SwivelRotation.Pitch	= 0;
	SwivelRotation.Roll		= startrot.roll;
	SetRotation( SwivelRotation );
}

defaultproperties
{
    StaticMesh=StaticMesh'AS_Weapons_SM.FloorTurretSwivel'
    DrawScale=0.25

    CollisionHeight=50.0
    CollisionRadius=50.0
	PrePivot=(Z=150)
}