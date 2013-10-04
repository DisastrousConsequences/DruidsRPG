class DruidWeaponSentinel extends Weapon_Sentinel
    config(user)
    HideDropDown
	CacheExempt;

defaultproperties
{
    ItemName="Sentinel weapon"

    FireModeClass(0)=FM_DruidSentinel_Fire
    FireModeClass(1)=FM_DruidSentinel_Fire

}
