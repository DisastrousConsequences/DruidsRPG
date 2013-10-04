class FM_DruidAutoGun_Fire extends FM_Sentinel_Fire;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile p;

	if (Instigator.GetTeamNum() == 255)
		p = Weapon.Spawn(TeamProjectileClasses[0], Instigator, , Start, Dir);
	else
		p = Weapon.Spawn(TeamProjectileClasses[Instigator.GetTeamNum()], Instigator, , Start, Dir);
	if ( p == None )
		return None;

	p.Damage *= DamageAtten;
	
	return p;
}


defaultproperties
{
    FireRate=0.45
	FireSound=Sound'AssaultSounds.HnShipFire01'
    ProjSpawnOffset=(X=200,Y=14,Z=-14)
	TeamProjectileClasses[0]=class'PROJ_AutoGun_Laser_Red'
	TeamProjectileClasses[1]=class'PROJ_AutoGun_Laser'
}
