class RW_EnhancedPiercing extends RW_Piercing
	HideDropDown
	CacheExempt
	config(UT2004RPG);

var config float DamageBonus;

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local bool RunningTriple;

	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if(Damage > 0)
	{
	    // so we either take the original damage, or we take the triple boosted damage. ignore DD in this calculation

		RunningTriple = false;
		If (Instigator.HasUDamage())
		{
			if (class'DruidDoubleModifier'.static.HasTripleRunning(Instigator))     // triple bonus only works on damage
			{
		    	Damage *= 2;
			    RunningTriple = true;
			}
		}
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));

		// so now damage is what it will be under non-piercing conditions
		if (Damage < OriginalDamage)
		{
		    // better taking the original
		    Damage = OriginalDamage;
		}
	    if (RunningTriple)
	        Damage = Damage / 2;        // triple will double damage later, so reduce now since we have already doubled or are piercing.

		// and double will kick in later

		Momentum *= 1.0 + DamageBonus * Modifier;
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
	DamageBonus=0.030000
	MaxModifier=6
	MinModifier=-2
	PrefixNeg="Piercing "
}
