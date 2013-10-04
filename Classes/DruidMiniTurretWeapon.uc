class DruidMiniTurretWeapon extends Weapon_Turret_Minigun
    config(user)
    HideDropDown
	CacheExempt;

defaultproperties
{
    FireModeClass(0)=FM_DruidMiniTurret_Fire
    FireModeClass(1)=FM_Turret_Minigun_AltFire
}
