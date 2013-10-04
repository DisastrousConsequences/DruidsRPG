class DruidWeaponAutoGun extends Weapon_Sentinel
    config(user)
    HideDropDown
	CacheExempt;

defaultproperties
{
    ItemName="AutoGun weapon"

    FireModeClass(0)=FM_DruidAutoGun_Fire
    FireModeClass(1)=FM_DruidAutoGun_Fire

}
