class DruidEnergyWeapon extends ONSManualGun;

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    local int Damage;
    local RPGStatsInv StatsInv, HealerStatsInv;
    local float old_xp,cur_xp,xp_each,xp_diff,xp_given_away;
    local int i;
    local int DriverLevel;
    local Controller C;

    X = Vector(Dir);
    End = Start + TraceRange * X;

    //skip past vehicle driver
    if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
    {
      	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
       	Other = Trace(HitLocation, HitNormal, End, Start, True);
       	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
       	Other = Trace(HitLocation, HitNormal, End, Start, True);

    if (Other != None)
    {
		if (!Other.bWorldGeometry)
		{
			Damage = (DamageMin + Rand(DamageMax - DamageMin));

			// find the current dataobject
			if (DruidEnergyTurret(Instigator) != None && DruidEnergyTurret(Instigator).Driver != None)
			{
				StatsInv = RPGStatsInv(DruidEnergyTurret(Instigator).Driver.FindInventoryType(class'RPGStatsInv'));
				if (StatsInv != None && StatsInv.DataObject != None)
				{
					old_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
					DriverLevel = StatsInv.DataObject.Level;

					if (Level.TimeSeconds > DruidEnergyTurret(Instigator).LastHealTime + class'EngineerLinkGun'.default.HealTimeDelay && DruidEnergyTurret(Instigator).NumHealers > 0)
						Damage = Damage * class'RW_EngineerLink'.static.DamageIncreasedByLinkers(DruidEnergyTurret(Instigator).NumHealers);
				}
			}
	
	
			if (ONSPowerCore(Other) == None && ONSPowerNodeEnergySphere(Other) == None)  // Sweet Hackaliciousness
				Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
			HitNormal = vect(0,0,0);
	
			if (StatsInv != None && StatsInv.DataObject != None && DriverLevel == StatsInv.DataObject.Level)		// if the driver has levelled, then do not share xp
			{
				cur_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
				xp_diff = cur_xp - old_xp;
				if (xp_diff > 0 && DruidEnergyTurret(Instigator).NumHealers > 0)
	//			if (xp_diff > 0 && Level.TimeSeconds > DruidEnergyTurret(Instigator).LastHealTime + class'EngineerLinkGun'.default.HealTimeDelay && DruidEnergyTurret(Instigator).NumHealers > 0)
				{
					// split the xp amongst the healers
					xp_each = class'RW_EngineerLink'.static.XPForLinker(xp_diff , DruidEnergyTurret(Instigator).Healers.length);		// use Healers.length rather than NumHealers - should be same but 
					xp_given_away = 0;
	
					for(i = 0; i < DruidEnergyTurret(Instigator).Healers.length; i++)
					{
						if (DruidEnergyTurret(Instigator).Healers[i].Pawn != None && DruidEnergyTurret(Instigator).Healers[i].Pawn.Health >0)
						{
						    C = DruidEnergyTurret(Instigator).Healers[i];
						    if (DruidLinkSentinelController(C) != None)
								HealerStatsInv = DruidLinkSentinelController(C).StatsInv;
						    else
								HealerStatsInv = RPGStatsInv(C.Pawn.FindInventoryType(class'RPGStatsInv'));
							if (HealerStatsInv != None && HealerStatsInv.DataObject != None)
								HealerStatsInv.DataObject.AddExperienceFraction(xp_each, DruidEnergyTurret(Instigator).RPGMut, DruidEnergyTurret(Instigator).Healers[i].Pawn.PlayerReplicationInfo);
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
				// DruidEnergyTurret(Instigator).Healers.length = 0;	// we have just paid them, so scrub their names
			}

        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

    HitCount++;
    LastHitLocation = HitLocation;
    SpawnHitEffects(Other, HitLocation, HitNormal);
}

DefaultProperties
{
    DamageMin=30
    DamageMax=40
}
