class FM_DruidBallTurret_Fire extends FM_BallTurret_Fire;


function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

	p = Weapon.Spawn(class'PROJ_DruidBallTurretPlasma', Instigator, , Start, Dir);
    if ( p == None )
        return None;

    p.Damage *= DamageAtten;
    return p;
}

defaultproperties
{
}
