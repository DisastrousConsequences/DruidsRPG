class RW_EnhancedProtection extends RPGWeapon
	HideDropDown
	CacheExempt
	config(UT2004RPG);

var config float DamageBonus;
var config int HealthCap;
var config float ProtectionRepeatLifespan;

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
	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

function AdjustPlayerDamage(out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	Local ProtectionInv inv;
	if (!bIdentified)
		Identify();

	Damage -= Damage * (0.1 * Modifier);

	Super.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);

	if(Modifier > 0 && Damage >= Instigator.Health && Instigator.Health > HealthCap)
	{
		inv = ProtectionInv(Instigator.FindInventoryType(class'ProtectionInv'));
		if(Inv == None)
		{
			Damage = Instigator.Health - 1; //help protect them for the first shot Damage reduction still applies though.
			inv = spawn(class'ProtectionInv', Instigator,,, rot(0,0,0));
			inv.Lifespan = (ProtectionRepeatLifespan / float(Modifier));
			if(inv != None)
				inv.giveTo(Instigator);
		}
	}
}

simulated function int MaxAmmo(int mode)
{
	if (bNoAmmoInstances && HolderStatsInv != None)
		return (ModifiedWeapon.MaxAmmo(mode) * (1.0 + 0.01 * HolderStatsInv.Data.AmmoMax));

	return ModifiedWeapon.MaxAmmo(mode);
}

defaultproperties
{
	DamageBonus=0.010000
	ProtectionRepeatLifespan=6.000000
	HealthCap=10
	ModifierOverlay=Shader'XGameShaders.PlayerShaders.PlayerShieldSh'
	MaxModifier=4
	MinModifier=-3
	AIRatingBonus=0.040000
	PostfixPos=" of Protection"
	PostfixNeg=" of Harm"
}