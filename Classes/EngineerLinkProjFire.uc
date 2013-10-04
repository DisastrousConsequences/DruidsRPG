
class EngineerLinkProjFire extends LinkAltFire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local EngineerLinkProjectile Proj;

    Start += Vector(Dir) * 10.0 * LinkGun(Weapon).Links;
    Proj = Weapon.Spawn(class'EngineerLinkProjectile',,, Start, Dir);
    if ( Proj != None )
    {
		Proj.Links = LinkGun(Weapon).Links;
		Proj.LinkAdjust();
	}
    return Proj;
}

defaultproperties
{
    FireRate=0.4
}
