//-----------------------------------------------------------
//
//-----------------------------------------------------------
class OneDropRPGWeapon extends RPGWeapon
	abstract;

var config float MinDamagePercent;

simulated function bool CanThrow()
{
	if (Modifier < 0)
		return false; //can't throw cursed weapons
	return true;
}

function DropFrom(vector StartLocation)
{
	local RPGStatsInv StatsInv;
	local int x;

	super.DropFrom(StartLocation);

	if(Instigator == None)
		return;

	StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv == None)
		return;

	for (x = 0; x < StatsInv.OldRPGWeapons.length; x++)
		if(self == StatsInv.OldRPGWeapons[x].Weapon)
			break;

	if(x == StatsInv.OldRPGWeapons.length)
		return;

	StatsInv.OldRPGWeapons.Remove(x, 1);
}

simulated function ConstructItemName()
{
	super.ConstructItemName();
		
	if (Modifier > -1)
		ItemName = ItemName @ "*";
}

static function bool CheckCorrectDamage(Weapon W, class<DamageType> DamageType)
{
	local int x;
	local class<ProjectileFire> ProjFire;
	local class<InstantFire> InstFire;

	if (!ClassIsChildOf(DamageType, class'WeaponDamageType'))
		return false;		// cannot be damage done by this weapon

	for (x = 0; x < NUM_FIRE_MODES && x < 50; x++)
	{
		if (ClassIsChildOf(W.default.FireModeClass[x], class'ProjectileFire'))
		{
			ProjFire = class<ProjectileFire>(W.default.FireModeClass[x]);
			if (ProjFire != None && ProjFire.default.ProjectileClass != none 
			  && DamageType == ProjFire.default.ProjectileClass.default.MyDamageType)
				return true;
		}
		else
		{
			if (ClassIsChildOf(W.default.FireModeClass[x], class'InstantFire'))
			{
				InstFire = class<InstantFire>(W.default.FireModeClass[x]);
				if (InstFire != None && DamageType == InstFire.default.DamageType)
					return true;
			}
		}
	}
	
	// ok, time for the specials. Why can't things ever be simple?
	if ( ClassIsChildOf(W.Class,class'RocketLauncher') && ClassIsChildOf(DamageType,class'DamTypeRocketHoming'))
		return true;
	else
	if ( ClassIsChildOf(W.Class,class'Painter') && ClassIsChildOf(DamageType,class'DamTypeIonBlast'))
		return true;
	else
	if ( ClassIsChildOf(W.Class,class'ShockRifle') && ClassIsChildOf(DamageType,class'DamTypeShockCombo'))
		return true;
	else
	if ( ClassIsChildOf(W.Class,class'SniperRifle') && ClassIsChildOf(DamageType,class'DamTypeSniperHeadShot'))
		return true;
	else
	if ( ClassIsChildOf(W.Class,class'ShieldGun') && ClassIsChildOf(DamageType,class'DamTypeShieldImpact'))
		return true;
	else
	if ( ClassIsChildOf(W.Class,class'LinkGun') && ClassIsChildOf(DamageType,class'DamTypeLinkShaft'))
		return true;
	
	// log("*****CheckCorrectDamage debug: Weapon:"@W@"does not support damagetype"@DamageType);
	return false;	// wrong damage type
}

simulated function int MaxAmmo(int mode)
{	// bug fix for HolderStatsInv being None
	if (bNoAmmoInstances && HolderStatsInv != None)
		return (ModifiedWeapon.MaxAmmo(mode) * (1.0 + 0.01 * HolderStatsInv.Data.AmmoMax));

	return ModifiedWeapon.MaxAmmo(mode);
}

defaultproperties
{
	MinDamagePercent=0.50
}
