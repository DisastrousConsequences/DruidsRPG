class DruidVampireSurge extends CostRPGAbility
	abstract;

static function GiveVampire(int VampHealth, Controller Killer)
{
	local Pawn P;

	if (Killer == None || Killer.Pawn == None)
	    return;
	P = Killer.Pawn;
	    
	if (Vehicle(P) != None)
	{
		P = Vehicle(P).Driver;
		if (P == None)
		{
			return;
		}
	}

	P.GiveHealth(VampHealth, P.HealthMax + Class'DruidVampire'.default.AdjustableHealingDamage);
}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
	if (!bOwnedByKiller)
		return;

	if ( Killed == Killer || Killed == None || Killer == None || Killed.Level == None || Killed.Level.Game == None)
		return;

	if (Killed.Level.Game.IsA('Invasion') && Killed.Pawn != None && Killed.Pawn.IsA('Monster'))
	{
		GiveVampire(int(Killed.Pawn.GetPropertyText("ScoringValue")) * AbilityLevel, Killer);
		return;
	}


	if (Killed.Level.Game.bTeamGame)
	{
		if ( (Killer.PlayerReplicationInfo == None) || (Killed.PlayerReplicationInfo == None) || (Killer.PlayerReplicationInfo.Team == Killed.PlayerReplicationInfo.Team))
			return;	//no bonus for team kills
	}

	if (Killer.bIsPlayer && Killed.bIsPlayer)
		GiveVampire(Deathmatch(Killed.Level.Game).ADR_Kill * AbilityLevel, Killer);
}

defaultproperties
{
     AbilityName="Vampire Surge"
     Description="For each level of this ability, you gain health from all kills. You must have at least 50 Damage Bonus and at least 150 Health Bonus stat at least 150 to purchase this ability. |Cost (per level): 5,6,7..."
     StartingCost=5
     CostAddPerLevel=1

     minDB=50
     MinHealthBonus=150
     MaxLevel=20
}