class DruidAdrenalineSurge extends CostRPGAbility
	abstract;

static simulated function int GetCost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool gotab;
	
	if (Data == None)
		return 0;
	
	// now check for LoadedArtifacts 5
	if (CurrentLevel >= 2)
	{
		gotab = false;
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == class'DruidArtifactLoaded' && Data.AbilityLevels[x] >= 5)
				gotab = true;
		if (!gotab)
			return 0;
	}

	return super.GetCost(Data, CurrentLevel);
}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
	if (!bOwnedByKiller)
		return;

	if (Killed.Level.Game.IsA('Invasion') && Killed.Pawn != None && Killed.Pawn.IsA('Monster'))
	{
		Killer.AwardAdrenaline(float(Killed.Pawn.GetPropertyText("ScoringValue")) * 0.5 * AbilityLevel);
		return;
	}

	if ( !(!Killed.Level.Game.bTeamGame || ((Killer != None) && (Killer != Killed) && (Killed != None)
		&& (Killer.PlayerReplicationInfo != None) && (Killed.PlayerReplicationInfo != None)
		&& (Killer.PlayerReplicationInfo.Team != Killed.PlayerReplicationInfo.Team))) )
		return;	//no bonus for team kills or suicides

	if (UnrealPlayer(Killer) != None && UnrealPlayer(Killer).MultiKillLevel > 0)
		Killer.AwardAdrenaline(Deathmatch(Killer.Level.Game).ADR_MajorKill * 0.5 * AbilityLevel);

	if (UnrealPawn(Killed.Pawn) != None && UnrealPawn(Killed.Pawn).spree > 4)
		Killer.AwardAdrenaline(Deathmatch(Killer.Level.Game).ADR_MajorKill * 0.5 * AbilityLevel);

	if ( Killer.PlayerReplicationInfo.Kills == 1 && TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo) != None
	     && TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo).bFirstBlood )
		Killer.AwardAdrenaline(Deathmatch(Killer.Level.Game).ADR_MajorKill * 0.5 * AbilityLevel);

	if (Killer.bIsPlayer && Killed.bIsPlayer)
		Killer.AwardAdrenaline(Deathmatch(Killer.Level.Game).ADR_Kill * 0.5 * AbilityLevel);
}

defaultproperties
{
     AbilityName="Adrenal Surge"
     Description="For each level of this ability, you gain 50% more adrenaline from all kill related adrenaline bonuses. You must have a Damage Bonus of at least 50 and an Adrenaline Max stat at least 150 to purchase this ability. |Cost (per level): 2,8..."
     StartingCost=2
     CostAddPerLevel=6

     minDB=50
     minAdrenalineMax=150
     MaxLevel=4
}