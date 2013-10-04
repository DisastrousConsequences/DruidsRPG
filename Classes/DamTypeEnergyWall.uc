class DamTypeEnergyWall extends VehicleDamageType
	abstract;

defaultproperties
{
	DeathString="%o was SIZZLED by the power of %k's wall!"
	FemaleSuicide="%o was SIZZLED!"
	MaleSuicide="%o was SIZZLED!"
	bArmorStops=True
	bKUseOwnDeathVel=True
	bDelayedDamage=True
	KDeathVel=0.000000
	KDeathUpKick=0.000000
	VehicleClass=class'DruidEnergyWall'
}

