class DamTypeLightningSent extends VehicleDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth)
{
    HitEffects[0] = class'HitSmoke';
    if (Rand(25) > VictemHealth)
	HitEffects[1] = class'HitFlame';
}

DefaultProperties
{
	DeathString="%o was electrocuted by %k's lightning sentinel."
	FemaleSuicide="%o had an electrifying experience."
	MaleSuicide="%o had an electrifying experience."
	
	bDelayedDamage=true
	VehicleClass=class'DruidLightningSentinel'
	
	bArmorStops=True
	bSuperWeapon=True
	
	bCauseConvulsions=True
	DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LightningHit'
	DamageOverlayTime=1.000000
	GibPerterbation=0.250000
}

