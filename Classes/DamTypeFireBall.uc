class DamTypeFireBall extends DamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
    DeathString="%o was fried by %k's fireball."
    MaleSuicide="%o snuffed himself with the fireball."
    FemaleSuicide="%o snuffed herself with the fireball."

    bDetonatesGoop=true

    DamageOverlayMaterial=Shader'DCText.DomShaders.PulseRedShader'
    DamageOverlayTime=0.8
    bDelayedDamage=true
}

