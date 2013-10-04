class WeaponDruidIonCannon extends Weapon_Turret_IonCannon
    config(user)
    HideDropDown
	CacheExempt;

defaultproperties
{
	bCanThrow=false
	bNoInstagibReplace=true
    ItemName="Ion Cannon Turret weapon"

	PickupClass=None
    AttachmentClass=class'WA_Turret_IonCannon'

    FireModeClass(0)=FM_DruidIonCannon_Fire
    FireModeClass(1)=FM_Turret_Minigun_AltFire

	Priority=1
    InventoryGroup=1

	DrawType=DT_None
    PlayerViewOffset=(X=0,Y=0,Z=-40)
    SmallViewOffset=(X=0,Y=0,Z=-40)
	CenteredRoll=0
    DisplayFOV=90

	EffectOffset=(X=0,Y=0,Z=0)

	AIRating=+0.68
	CurrentRating=+0.68
}
