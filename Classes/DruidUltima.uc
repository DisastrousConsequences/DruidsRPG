class DruidUltima extends RPGDeathAbility
	abstract;

/* Note that the comment below was in when we originally had
 * this class based off of AbilityUltima from UT2004RPG.
 */
//single Inheritance, so we'll just simulate the AdjustCost. 

static function bool AbilityIsAllowed(GameInfo Game, MutUT2004RPG RPGMut)
{
	return true;
}

// Basically like AbilityUltima's PreventDeath, but calling GhostUltimaCharger instead of UltimaCharger
static function PotentialDeathPending(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local GhostUltimaCharger guc;
	if(Vehicle(Killed) != None)
		return;
// If this stops Ultima from going off, change it to:
//		Vehicle(Killed).Driver.spawn(class'GhostUltimaCharger', Vehicle(Killed).Driver.Controller).ChargeTime = 4.0 / AbilityLevel;
	else if(!Killed.Level.Game.IsA('ASGameInfo') && Killed.Location.Z > Killed.Region.Zone.KillZ &&
	  Killed.FindInventoryType(class'KillMarker') != None)
	{
		guc = Killed.spawn(class'GhostUltimaCharger', Killed.Controller);
		if (guc != None)
		{
			guc.ChargeTime = 4.0 / AbilityLevel;							// 4, 2, 1.25 secs
			guc.Damage = guc.default.Damage * (AbilityLevel+2) / 3.0;		// 1.0, 1.33, 1.66
			guc.DamageRadius = guc.default.DamageRadius * (AbilityLevel+2) / 4.0;	// 0.75, 1.0, or 1.25
		}
	} 
  
	return;
}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
        if (!Killed.Level.Game.IsA('ASGameInfo'))
                class'AbilityUltima'.static.ScoreKill(Killer, Killed, bOwnedByKiller, AbilityLevel); 
}

defaultproperties
{
	AbilityName="Ultima"
	Description="This ability causes your body to release energy when you die. The energy will collect at a single point which will then cause a Redeemer-like nuclear explosion. Level 2 of this ability causes the energy to collect for the explosion in half the time. The ability will only trigger if you have killed at least one enemy during your life. You need to have a Damage Bonus stat of at least 80 to purchase this ability. (Max Level: 2)|Cost (per level): 50,50"
	StartingCost=50
	CostAddPerLevel=0
	MaxLevel=4

	ExcludingAbilities[0]=class'AbilityUltima'
	ExcludingAbilities[1]=class'AbilityGhost'
}
