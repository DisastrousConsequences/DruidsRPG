class AbilityExtremeEngineer extends AbilityLoadedEngineer
	config(UT2004RPG)
	abstract;

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		bAllowPickup = 0;	// no enhanced or offensive artifacts allowed
		return true;
	}
	return super.OverridePickupQuery(Other, item,  bAllowPickup, AbilityLevel);
}

defaultproperties
{
     AbilityName="Extreme Engineer"
     
     WeaponDamage=0.8
     AdrenalineDamage=0.5
     VehicleDamage=1.2
     SentinelDamage=1.2
}
