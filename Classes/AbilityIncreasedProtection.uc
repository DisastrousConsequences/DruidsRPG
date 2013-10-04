class AbilityIncreasedProtection extends CostRPGAbility
	config(UT2004RPG) 
	abstract;

var config float ProtectionMultiplier;
var config float SpeedMultiplier;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(bOwnedByInstigator)
		return; //if the instigator is doing the damage, ignore this.
	if(Damage > 0)
	{
		Damage *= (abs(1-(AbilityLevel * default.ProtectionMultiplier)));
		if (Damage == 0)
			Damage = 1;
	}
}

// need to reduce movement speed.
static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	class'RW_Speedy'.static.quickfoot(0, Other);	// let this deal with it
}

static simulated function SlowDown(Pawn Other, int AbilityLevel)
{	// override everything else and set speed based on default
	Other.GroundSpeed = Other.default.GroundSpeed * (1.0 - (default.SpeedMultiplier * float(AbilityLevel)));
	Other.WaterSpeed = Other.default.WaterSpeed * (1.0 - (default.SpeedMultiplier * float(AbilityLevel)));
	Other.AirSpeed = Other.default.AirSpeed * (1.0 - (default.SpeedMultiplier * float(AbilityLevel)));
}


DefaultProperties
{
	AbilityName="Increased Damage Protection"
	Description="Increases your cumulative total damage reduction by 5% per level. Does not apply to self damage. However, the extra armor slows you down.|Cost (per level): 10."
	
	ProtectionMultiplier=0.050000
	SpeedMultiplier=0.025
	StartingCost=10
	CostAddPerLevel=0
	MaxLevel=20

}