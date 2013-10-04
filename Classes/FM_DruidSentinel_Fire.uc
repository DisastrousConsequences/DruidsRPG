class FM_DruidSentinel_Fire extends FM_Sentinel_Fire;

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
	
	if (Instigator != None && Instigator.Controller != None && DruidSentinelController(Instigator.Controller) != None)
	{
		p.Damage *= DruidSentinelController(Instigator.Controller).DamageAdjust;		// set by LoadedEngineer
	}
	
	return p;
}


defaultproperties
{
    FireRate=0.33
}
