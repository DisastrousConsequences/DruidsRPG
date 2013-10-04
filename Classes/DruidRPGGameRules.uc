class DruidRPGGameRules extends GameRules
		config(UT2004RPG);

// for pets that do not have a weapon that causes weapon damagetype, use this table to extract the pet name, for F3 stats
struct PetDamageHolder
{
	var class<Monster> PetClass;
	var class<WeaponDamageType> PetDamageType;
};
var config array<PetDamageHolder> PetDamageHolders;

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local bool bAlreadyPrevented;
	local int x;
	local RPGStatsInv StatsInv;
	local Controller KilledController;
	local class<RPGDeathAbility> DeathAbility;
	local Controller PlayerSpawner;
	local FriendlyMonsterKillMarker M;
	local TeamPlayerReplicationInfo TPRI;

	bAlreadyPrevented = Super.PreventDeath(Killed, Killer, damageType, HitLocation);
	if(bAlreadyPrevented)
		return true;

	if (Killed.Controller != None)
		KilledController = Killed.Controller;
	else if (Killed.DrivenVehicle != None && Killed.DrivenVehicle.Controller != None)
		KilledController = Killed.DrivenVehicle.Controller;
	if (KilledController != None)
		StatsInv = class'RPGClass'.static.getPlayerStats(KilledController);

	if (StatsInv != None && StatsInv.DataObject != None)
	{
		//FIXME Pawn should probably still call PreventDeath() in cases like this, 
		//but it might be wiser to ignore the value -- Mysterial
		//I dont have the knowledge to change this iflogic -- DRU
		if
		(
			!KilledController.bPendingDelete && 
			(
				KilledController.PlayerReplicationInfo == None || 
				!KilledController.PlayerReplicationInfo.bOnlySpectator
			)
		)
		{
			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if(ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					bAlreadyPrevented = DeathAbility.static.PrePreventDeath(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
					if(bAlreadyPrevented)
						return true;
				}
			}

			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if(ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					DeathAbility.static.PotentialDeathPending(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
				}
			}

			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if(ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					bAlreadyPrevented = DeathAbility.static.GenuinePreventDeath(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
					if(bAlreadyPrevented)
						return true;
				}
			}

			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if(ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					DeathAbility.static.GenuineDeath(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
				}
			}
		}
	}

	//Hack to give master credit for all his/her sentinel's kills
	PlayerSpawner = None;
	if (DruidSentinelController(Killer) != None)
		PlayerSpawner = DruidSentinelController(Killer).PlayerSpawner;
	else if (DruidBaseSentinelController(Killer) != None)
		PlayerSpawner = DruidBaseSentinelController(Killer).PlayerSpawner;
	else if (DruidLightningSentinelController(Killer) != None)
		PlayerSpawner = DruidLightningSentinelController(Killer).PlayerSpawner;
	else if (DruidEnergyWallController(Killer) != None)
		PlayerSpawner = DruidEnergyWallController(Killer).PlayerSpawner;
	else if (AutoGunController(Killer) != None)
		PlayerSpawner = AutoGunController(Killer).PlayerSpawner;
	if (PlayerSpawner != None)
	{
		M = spawn(class'FriendlyMonsterKillMarker', Killed);
		M.Killer = PlayerSpawner;
		M.Health = Killed.Health;
		M.DamageType = damageType;
		M.HitLocation = HitLocation;
		return true;
	}
	
	// now lets just check if the kill was by a pet, if the damage type is not a weapondamagetype or vehicledamagetype it will not get logged in the F3 stats
	if (FriendlyMonsterController(Killer) != None && Killer.Pawn != None)
	{
		if (!ClassIsChildOf(damageType,class'WeaponDamageType') && !ClassIsChildOf(damageType,class'VehicleDamageType'))
		{
			// then it wouldn't normally get logged to the F3 stats
			if ( FriendlyMonsterController(Killer).Master != None && FriendlyMonsterController(Killer).Master.bIsPlayer) 
			{
				// lets see if we can get a different damagetype that will log the pet
				TPRI = TeamPlayerReplicationInfo(FriendlyMonsterController(Killer).Master.PlayerReplicationInfo);
				if ( TPRI != None )
				{
					for (x = 0; x < PetDamageHolders.length; x++)
					{
						if (Killer.Pawn.Class == PetDamageHolders[x].PetClass)
						{
							TPRI.AddWeaponKill(PetDamageHolders[x].PetDamageType);
							break;
						}
					}
				}
			}
		}
	}
	
// Technically, by this point, bAlreadyPrevented should never be true.
// If it were, it would have already been returned so.  BF
	if (bAlreadyPrevented)
		return true;
	else
		return false;
}
