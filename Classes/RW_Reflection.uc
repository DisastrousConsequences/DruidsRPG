class RW_Reflection extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(UT2004RPG);

var config float DamageBonus;
var config float BaseChance;
var config float Growth;

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
		Momentum *= 1.0 +DamageBonus * Modifier;
	}
}

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int Damage )
{
	//make the call first in case the weapon actually does the reflect on it's own.
	if(super.CheckReflect(HitLocation, RefNormal, Damage))
		return true;

	if(Damage > 0)
	{
		RefNormal=normal(HitLocation-Location);
		if(rand(99) < int((Growth**float(Modifier))*BaseChance))
		{
			Instigator.SetOverlayMaterial(ModifierOverlay, 1.0, false);
			return true;
		}
	}
	return false;
}

defaultproperties
{
	BaseChance=30.000000
	Growth=1.210000
	DamageBonus=0.030000
	AIRatingBonus=0.060000
	PrefixPos="Reflecting "
	bCanHaveZeroModifier=True
	MaxModifier=7
	MinModifier=1
	ModifierOverlay=TexEnvMap'VMVehicles-TX.Environments.ReflectionEnv'
}