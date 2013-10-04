class EngineerLinkGun extends RPGLinkGun
	HideDropDown
	CacheExempt;

var config float HealTimeDelay;		// when linking to turrets how long after healing before get damage boost

defaultproperties
{
    FireModeClass(0)=Class'EngineerLinkProjFire'
	FireModeClass(1)=Class'EngineerLinkFire'
	HealTimeDelay=0.5			// time delay before which healers provide extra damage and get xp
}
