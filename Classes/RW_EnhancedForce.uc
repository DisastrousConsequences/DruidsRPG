class RW_EnhancedForce extends RW_Force
	HideDropDown
	CacheExempt
	config(UT2004RPG);

var config float DamageBonus;

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
		if(Modifier > 0)
			Momentum *= 1.0 + DamageBonus * Modifier;
		if(Modifier < 0)
			Momentum /= 1.0 + DamageBonus * abs(Modifier); //fractionally get smaller as the modifier gets smaller
	}
	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

simulated function int MaxAmmo(int mode)
{
	if (bNoAmmoInstances && HolderStatsInv != None)
		return (ModifiedWeapon.MaxAmmo(mode) * (1.0 + 0.01 * HolderStatsInv.Data.AmmoMax));

	return ModifiedWeapon.MaxAmmo(mode);
}

defaultproperties
{
	DamageBonus=0.040000
	MaxModifier=5
	MinModifier=-5
	PostfixNeg=" of Slow Motion"
}
