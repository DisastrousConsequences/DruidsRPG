class RW_Rage extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(UT2004RPG);

var config float DamageBonus;
var config float DamageReturn;
var config int MinimumHealth;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	if ( Weapon.default.FireModeClass[0] != None && Weapon.default.FireModeClass[0].default.AmmoClass != None
	          && class'MutUT2004RPG'.static.IsSuperWeaponAmmo(Weapon.default.FireModeClass[0].default.AmmoClass) )
		return false;

	if (ClassIsChildOf(Weapon, class'LinkGun') || ClassIsChildOf(Weapon, class'Minigun'))
		return false;

	return true;
}

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local int localDamage;
	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if(damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent))
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;

		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 +DamageBonus * Modifier;

		localDamage = Max(1, DamageReturn * Damage);
		if(localDamage >= Instigator.Health - MinimumHealth)
			localDamage = Instigator.Health - MinimumHealth;
		if(localDamage > 0)
			if(Instigator.Controller == None || Instigator.Controller.bGodMode == False)
				Instigator.Health -= localDamage; //ouch. Done this way to prevent damage reduction. It's dirty, but it works
	}
}

defaultproperties
{
	DamageBonus=0.100000
	DamageReturn=0.100000
	MinimumHealth=70
	PostfixPos=" of Rage"
	MinModifier=6
	MaxModifier=10
	ModifierOverlay=Combiner'EpicParticles.Shaders.Combiner3';
}