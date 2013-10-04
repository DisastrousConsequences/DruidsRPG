class RW_Vampire extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(UT2004RPG);

var config float DamageBonus;
var config float VampireAmount;

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	if(damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent))
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;
	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if(damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}
	
	if(Pawn(Victim) == None)
		return;

	Class'DruidVampire'.static.LocalHandleDamage(Damage, Pawn(Victim), Instigator, Momentum, DamageType, true, Float(Modifier) * VampireAmount);
}

defaultproperties
{
	DamageBonus=0.030000
	VampireAmount=0.750000
	ModifierOverlay=Shader'WeaponSkins.ShockLaser.LaserShader'
	MinModifier=3
	MaxModifier=7
	AIRatingBonus=0.080000
	PrefixPos="Vampiric "
}