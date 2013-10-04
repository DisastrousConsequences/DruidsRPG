class DruidCeilingSentinel extends ASVehicle_Sentinel_Ceiling;

simulated function PostBeginPlay()
{
	DefaultWeaponClassName=string(class'DruidWeaponSentinel');

	super.PostBeginPlay();
}

defaultproperties
{
	bNoTeamBeacon=false
	DefaultWeaponClassName=""	// class'DruidWeaponSentinel'
}
