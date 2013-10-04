class FX_DruidIonCannon_BeamFire extends FX_Turret_IonCannon_BeamFire;

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local RPGStatsInv StatsInv, HealerStatsInv;
	local float old_xp,cur_xp,xp_each,xp_diff,xp_given_away;
	local int i;
    local int DriverLevel;
	local Pawn P;
	local bool bSameTeam;
    local Controller C;


	if( bHurtEntry )
		return;

	if ( Role != ROLE_Authority )
		return;

	bHurtEntry = true;

	// find the current dataobject
	if (DruidIonCannon(Instigator) != None && DruidIonCannon(Instigator).Driver != None)
	{
		StatsInv = RPGStatsInv(DruidIonCannon(Instigator).Driver.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None && StatsInv.DataObject != None)
		{
			old_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
			DriverLevel = StatsInv.DataObject.Level;
			
			if (Level.TimeSeconds > DruidIonCannon(Instigator).LastHealTime + class'EngineerLinkGun'.default.HealTimeDelay && DruidIonCannon(Instigator).NumHealers > 0)
				DamageAmount *= class'RW_EngineerLink'.static.DamageIncreasedByLinkers(DruidIonCannon(Instigator).NumHealers);
		}
	}
		
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != instigator) && (Victims != self) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			bSameTeam = false;
			P = Pawn(Victims);
			if (P != None && P.Controller != None && P.Health > 0 && Instigator != None && P.Controller.SameTeamAs(Instigator.Controller))
			    bSameTeam = true;
			if (!bSameTeam)
			{
				Victims.TakeDamage
				(
					damageScale * DamageAmount,
					Instigator,
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(damageScale * Momentum * dir),
					DamageType
				);
	//			Log("****Ion Beam Fire hitting:" $ Victims @ "for damage:" $ (damageScale * DamageAmount));
				if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
					Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
			}
		}
	}

	if (StatsInv != None && StatsInv.DataObject != None && DriverLevel == StatsInv.DataObject.Level)		// if the driver has levelled, then do not share xp
	{
		cur_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
		xp_diff = cur_xp - old_xp;
		if (xp_diff > 0 && DruidIonCannon(Instigator).NumHealers > 0)
//		if (xp_diff > 0 && Level.TimeSeconds > DruidIonCannon(Instigator).LastHealTime + class'EngineerLinkGun'.default.HealTimeDelay && DruidIonCannon(Instigator).NumHealers > 0)
		{
			// split the xp amongst the healers
			xp_each = class'RW_EngineerLink'.static.XPForLinker(xp_diff , DruidIonCannon(Instigator).Healers.length);		// use Healers.length rather than NumHealers - should be same but 
			xp_given_away = 0;

			for(i = 0; i < DruidIonCannon(Instigator).Healers.length; i++)
			{
				if (DruidIonCannon(Instigator).Healers[i].Pawn != None && DruidIonCannon(Instigator).Healers[i].Pawn.Health >0)
				{
				    C = DruidIonCannon(Instigator).Healers[i];
				    if (DruidLinkSentinelController(C) != None)
						HealerStatsInv = DruidLinkSentinelController(C).StatsInv;
				    else
						HealerStatsInv = RPGStatsInv(C.Pawn.FindInventoryType(class'RPGStatsInv'));
					if (HealerStatsInv != None && HealerStatsInv.DataObject != None)
						HealerStatsInv.DataObject.AddExperienceFraction(xp_each, DruidIonCannon(Instigator).RPGMut, DruidIonCannon(Instigator).Healers[i].Pawn.PlayerReplicationInfo);
					xp_given_away += xp_each;
				}
			}
			// now adjust the turret operator
			if (xp_given_away > 0)
			{
				StatsInv.DataObject.ExperienceFraction -= xp_given_away;
				while (StatsInv.DataObject.ExperienceFraction < 0)
				{
					StatsInv.DataObject.ExperienceFraction += 1.0;
					StatsInv.DataObject.Experience -= 1;
				}
			}
		}
	}

	bHurtEntry = false;
}

defaultproperties
{
    Damage=120.0
    DamageRadius=1700.0
    MinRange=700.0
    MaxRange=10000.0
}
