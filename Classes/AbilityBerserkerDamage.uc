class AbilityBerserkerDamage extends CostRPGAbility
	config(UT2004RPG) 
	abstract;

var config float MinDamageBonus, MaxDamageBonus;
var config float MaxDamageDist;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local float damageScale, dist, distScale;
	local vector dir;

	if (DamageType == class'DamTypeRetaliation' || Injured == None || Instigator == None || Injured == Instigator || Damage <= 0)
		return;
		
	// extra damage done depends on closeness to enemy. Up close do more damage and take less damage, due to the adrenaline. Further away not so good. 
	dir = Instigator.Location - Injured.Location;
	dist = FMax(1,VSize(dir));
	
	if (dist > default.MaxDamageDist)
		distScale = 0.0;
	else
		distScale = FMin(1.0,FMax(0.0, 1.0 - (dist/default.MaxDamageDist)));		// fix between 0 and 1

	if (bOwnedByInstigator) 
	{
		// Damage done by us. The higher distScale, the closer we are, so the more damage
		damageScale = default.MinDamageBonus + (distscale * (default.MaxDamageBonus - default.MinDamageBonus));
		Damage *= (1 + (AbilityLevel * damageScale));
	}
	else
	{
		// Damage to us. The higher distScale the lower the damage bonus, as we suffer more if we are not up close
		damageScale = default.MaxDamageBonus - (distscale * (default.MaxDamageBonus - default.MinDamageBonus));
		Damage *= (1 + (AbilityLevel * damageScale));
	}
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		bAllowPickup = 0;	// no enhanced or offensive artifacts allowed
		return true;
	}
	return false;
}

DefaultProperties
{
	AbilityName="Berserker Damage Bonus"
	Description="Increases your cumulative total damage bonus by up to 15% per level, depending on closeness to enemy. However, you also take up to 15% extra damage per level, again depending on how close. The closer the better. |Cost (per level): 10. You must be level 60 to purchase the first level of this ability, level 62 to purchase the second level, and so on."
	
	MinDamageBonus=0.000000
	MaxDamageBonus=0.150000
	MaxDamageDist=1800
	StartingCost=10
	CostAddPerLevel=0
	MaxLevel=20

	MinPlayerLevel=60
	PlayerLevelStep=2
}