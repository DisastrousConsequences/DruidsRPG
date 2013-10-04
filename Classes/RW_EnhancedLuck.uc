class RW_EnhancedLuck extends RW_Luck
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
		Momentum *= 1.0 + DamageBonus * Modifier;
	}
}

function class<Pickup> ChoosePickupClass()
{
	local array<class<Pickup> > Potentials;
	local Inventory Inv;
	local Weapon W;
	local class<Pickup> AmmoPickupClass;
	local int i, Count;

	if (Instigator.Health < Instigator.HealthMax)
	{
		Potentials[i++] = class'HealthPack';
		Potentials[i++] = class'MiniHealthPack';
	}
	else
	{
		if (Instigator.Health < Instigator.HealthMax + 99)
		{
			Potentials[i++] = class'MiniHealthPack';
			Potentials[i++] = class'MiniHealthPack';
		}
		if (Instigator.ShieldStrength < 50)
			Potentials[i++] = class'ShieldPack';
	}
	for (Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		W = Weapon(Inv);
		if (W != None)
		{
			if (W.NeedAmmo(0))
			{
				AmmoPickupClass = W.AmmoPickupClass(0);
				if (AmmoPickupClass != None)
					Potentials[i++] = AmmoPickupClass;
			}
			else if (W.NeedAmmo(1))
			{
				AmmoPickupClass = W.AmmoPickupClass(1);
				if (AmmoPickupClass != None)
					Potentials[i++] = AmmoPickupClass;
			}
		}
		Count++;
		if (Count > 1000)
			break;
	}
	if (FRand() < 0.015 * Modifier)
		Potentials[i++] = class'UDamagePack';
	if (i == 0 || (Instigator.Controller != None && Instigator.Controller.Adrenaline < Instigator.Controller.AdrenalineMax))
		Potentials[i++] = class'AdrenalinePickup';

	return Potentials[Rand(i)];
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
	MaxModifier=7
	MinModifier=2
	ModifierOverlay=FinalBlend'MutantSkins.Shaders.MutantGlowFinal'
}
