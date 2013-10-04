class FM_DruidMiniTurret_Fire extends FM_Turret_Minigun_Fire;

function DoTrace(Vector Start, Rotator Dir)
{
	local Vector X, End, HitLocation, HitNormal, RefNormal;
	local Actor Other;
	local int Damage;
	local bool bDoReflect;
	local int ReflectNum;
	local RPGStatsInv StatsInv, HealerStatsInv;
	local float old_xp,cur_xp,xp_each,xp_diff,xp_given_away;
	local int i;
    local int DriverLevel;
    local Controller C;

	MaxRange();

	ReflectNum = 0;
	while (true)
	{
		bDoReflect = false;
		X = Vector(Dir);
		End = Start + TraceRange * X;

		Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

		if ( Other != None && (Other != Instigator || ReflectNum > 0) )
		{
			if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
			{
				bDoReflect = true;
				HitNormal = Vect(0,0,0);
			}
			else if ( !Other.bWorldGeometry )
			{
				Damage = DamageMin;
				if ( (DamageMin != DamageMax) && (FRand() > 0.5) )
					Damage += Rand(1 + DamageMax - DamageMin);
				Damage = Damage * DamageAtten;

				// Update hit effect except for pawns (blood) other than vehicles.
				if ( Other.IsA('Vehicle') || (!Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume')) )
					WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other, HitLocation, HitNormal);

				// find the current dataobject
				if (DruidMinigunTurret(Instigator) != None && DruidMinigunTurret(Instigator).Driver != None)
				{
					StatsInv = RPGStatsInv(DruidMinigunTurret(Instigator).Driver.FindInventoryType(class'RPGStatsInv'));
					if (StatsInv != None && StatsInv.DataObject != None)
					{
						old_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
						DriverLevel = StatsInv.DataObject.Level;

						if (Level.TimeSeconds > (DruidMinigunTurret(Instigator).LastHealTime + class'EngineerLinkGun'.default.HealTimeDelay) && (DruidMinigunTurret(Instigator).NumHealers > 0))
						{
							Damage = Damage * class'RW_EngineerLink'.static.DamageIncreasedByLinkers(DruidMinigunTurret(Instigator).NumHealers);
						}
					}
				}

				Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
				HitNormal = Vect(0,0,0);

				if (StatsInv != None && StatsInv.DataObject != None && DriverLevel == StatsInv.DataObject.Level)		// if the driver has levelled, then do not share xp
				{
					cur_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
					xp_diff = cur_xp - old_xp;
					if (xp_diff > 0 && DruidMinigunTurret(Instigator).NumHealers > 0)
//					if (xp_diff > 0 && Level.TimeSeconds > DruidMinigunTurret(Instigator).LastHealTime + class'EngineerLinkGun'.default.HealTimeDelay && DruidMinigunTurret(Instigator).NumHealers > 0)
					{
						// split the xp amongst the healers
						xp_each = class'RW_EngineerLink'.static.XPForLinker(xp_diff , DruidMinigunTurret(Instigator).Healers.length);
						xp_given_away = 0;

						for(i = 0; i < DruidMinigunTurret(Instigator).Healers.length; i++)
						{
							if (DruidMinigunTurret(Instigator).Healers[i].Pawn != None && DruidMinigunTurret(Instigator).Healers[i].Pawn.Health >0)
							{
							    C = DruidMinigunTurret(Instigator).Healers[i];
							    if (DruidLinkSentinelController(C) != None)
									HealerStatsInv = DruidLinkSentinelController(C).StatsInv;
							    else
									HealerStatsInv = RPGStatsInv(C.Pawn.FindInventoryType(class'RPGStatsInv'));
								if (HealerStatsInv != None && HealerStatsInv.DataObject != None)
								{
									HealerStatsInv.DataObject.AddExperienceFraction(xp_each, DruidMinigunTurret(Instigator).RPGMut, DruidMinigunTurret(Instigator).Healers[i].Pawn.PlayerReplicationInfo);
								}
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
					// DruidMinigunTurret(Instigator).Healers.length = 0;	// we have just paid them, so scrub their names
				}

			}
			else if ( WeaponAttachment(Weapon.ThirdPersonActor) != None )
				WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
		}
		else
		{
			HitLocation = End;
			HitNormal = Vect(0,0,0);
			WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
		}

		SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

		if (bDoReflect && ++ReflectNum < 4)
		{
			Start = HitLocation;
			Dir = Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
		}
		else
		{
			break;
		}
	}
}

defaultproperties
{
}
