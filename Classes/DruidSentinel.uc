class DruidSentinel extends ASVehicle_Sentinel_Floor;

simulated event PostBeginPlay()
{
	DefaultWeaponClassName=string(class'DruidWeaponSentinel');

	super.PostBeginPlay();
}

defaultproperties
{
	bNoTeamBeacon=false
	DefaultWeaponClassName=""	// class'DruidWeaponSentinel'
}
