class RPGClass extends RPGDeathAbility
	config(UT2004RPG) 
	abstract;

var config int LowLevel;
var config int MediumLevel;
var config float MaxXPperHit;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	if(CurrentLevel > 1)
		return 0;

	for (x = 0; x < Data.Abilities.length; x++)
	{
		if(ClassIsChildOf(Data.Abilities[x], Class'RPGClass') && Data.Abilities[x] != default.Class)
			return 0;
	}
	return default.StartingCost;
}

static simulated function RPGStatsInv getPlayerStats(Controller c)
{
	Local GameRules G;
	Local RPGRules RPG;
	for(G = C.Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if(G.isA('RPGRules'))
		{
			RPG = RPGRules(G);
			break;
		}
	}

	if(RPG == None)
	{
		Log("WARNING: Unable to find RPGRules in GameRules.");
		return None;
	}
	return RPG.GetStatsInvFor(C);
}

static function bool PrePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	Local InvulnerabilityInv IInv;
	Local float XPGained;

	if(Killed == None)
		return false;

	IInv = InvulnerabilityInv(Killed.FindInventoryType(class'InvulnerabilityInv'));
	if (IInv != None)
	{
	    if (Killed == IInv.PlayerPawn)
			Killed.Health = max(IInv.PlayerHealth,10);  // keep alive
	    else
			Killed.Health = max(10,Killed.Health);  // keep alive
	    // killed player is in a invulnerability sphere. Give them 10 health and give xp to sphere spawner
		if ( Killer != None && Killer.Pawn != None && Killed != Killer.Pawn && Killed.Controller != None
			&& !Killed.Controller.SameTeamAs(Killer) )
		{
		    // saved some damage from an enemy. Let's give xp.
		    if (IInv.InvPlayerController != None && IInv.InvPlayerController.Pawn != None && IInv.Rules != None && IInv.InvPlayerController != Killer && IInv.InvPlayerController != Killed.Controller)
		    {
		        XPGained = fmin(fmax(3.0, Killed.Health*IInv.ExpPerDamage),default.MaxXPperHit); // between 3 and 10 xp for preventing death
		        IInv.Rules.ShareExperience(RPGStatsInv(IInv.InvPlayerController.Pawn.FindInventoryType(class'RPGStatsInv')), XPGained);
		        //Log("******* Player:" $ IInv.InvPlayerController.Pawn @ "is getting" @ XPGained @ "xp for preventing death to" @ Killed @ "Damagetype:" $ DamageType);
			}
		}
		return true;
	}

	return false;
}

static function bool GenuinePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local RPGStatsInv StatsInv;
	local int y;
	local int GhostLevel;
	local int GhostIndex;
	GhostIndex = -1;
	
	StatsInv = RPGStatsInv(Killed.FindInventoryType(class'RPGStatsInv'));
 	if (StatsInv != None && StatsInv.DataObject.Level <= default.MediumLevel)
 	{
 		for (y = 0; y < StatsInv.Data.Abilities.length; y++)
 		{
 			if (ClassIsChildOf(StatsInv.Data.Abilities[y], class'AbilityGhost'))
 			{
 				GhostLevel = StatsInv.Data.AbilityLevels[y];
 				GhostIndex = y;
 			}
 		}

		if(StatsInv.DataObject.Level <= default.LowLevel)
		{
			if(GhostIndex >= 0)
				return StatsInv.Data.Abilities[GhostIndex].static.PreventDeath(Killed, Killer, DamageType, HitLocation, 2, false);
			else
				return class'DruidGhost'.static.GenuinePreventDeath(Killed, Killer, DamageType, HitLocation, 2);
			
		}
		else if(StatsInv.DataObject.Level <= default.MediumLevel)
		{
			if(GhostIndex >= 0)
				return StatsInv.Data.Abilities[GhostIndex].static.PreventDeath(Killed, Killer, DamageType, HitLocation, 1, false);
			else
				return class'DruidGhost'.static.GenuinePreventDeath(Killed, Killer, DamageType, HitLocation, 1);
		}
 	}
}

static function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType, int AbilityLevel)
{
	local RPGStatsInv StatsInv;
	Local InvulnerabilityInv IInv;
	local int y;
	local int GhostLevel;
	local int GhostIndex;
	GhostIndex = -1;
	
	IInv = InvulnerabilityInv(Killed.FindInventoryType(class'InvulnerabilityInv'));
	if (IInv != None)
	{
	    return true;
	}

	StatsInv = RPGStatsInv(Killed.FindInventoryType(class'RPGStatsInv'));
 	if (StatsInv != None && StatsInv.DataObject.Level <= default.MediumLevel)
 	{
 		for (y = 0; y < StatsInv.Data.Abilities.length; y++)
 		{
 			if (ClassIsChildOf(StatsInv.Data.Abilities[y], class'AbilityGhost'))
 			{
 				GhostLevel = StatsInv.Data.AbilityLevels[y];
 				GhostIndex = y;
 			}
 		}

		if(StatsInv.DataObject.Level <= default.LowLevel)
		{
			if(GhostIndex >=0)
				return StatsInv.Data.Abilities[GhostIndex].static.PreventSever(Killed, boneName, Damage, DamageType, 3);
			else
				return class'DruidGhost'.static.PreventSever(Killed, boneName, Damage, DamageType, 3);
		}
		else if(StatsInv.DataObject.Level <= default.MediumLevel)
		{
			if(GhostIndex >=0)
				return StatsInv.Data.Abilities[GhostIndex].static.PreventSever(Killed, boneName, Damage, DamageType, Min(3, GhostLevel + 2));
			else
				return class'DruidGhost'.static.PreventSever(Killed, boneName, Damage, DamageType, 2);
		}
 	}
}

static simulated function ModifyVehicle(Vehicle V, int AbilityLevel)
{
	// called when player enters a vehicle
	// UT2004RPG resets the vehicle health back to defaults when you get in. We need to reapply bonus
	local float Healthperc;

	if (V.SuperHealthMax == 199)
		return;					// not spawned by Engineer

	// need to undo the change done by the MutUT2004RPG.DriverEnteredVehicle function
	Healthperc = float(V.Health) / V.HealthMax;	// current health percent
	V.HealthMax = V.SuperHealthMax;
	V.Health =Healthperc * V.HealthMax;		// now applied to new max

}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
	Local DamageInv DInv;
	Local float XPGained;

	if (!bOwnedByKiller)
		return;
		
    if (Killer == None || Killer.Pawn == None || Killed == None || Killed.Pawn == None)
        return; // nothing we can do
		
	if (!Killer.Pawn.IsA('Monster') && Killer.Pawn.HasUDamage())
	{
		DInv = DamageInv(Killer.Pawn.FindInventoryType(class'DamageInv'));
		if (DInv != None)
		{
		    // player has DamageInv, which means they have their Damage Boosted by another player. So lets give them a bit of xp
		    if (DInv.DamagePlayerController != None && DInv.DamagePlayerController.Pawn != None && DInv.Rules != None && DInv.DamagePlayerController != Killer)
		    {
		        XPGained = DInv.KillXPPerc * float(Killed.Pawn.GetPropertyText("ScoringValue"));
		        DInv.Rules.ShareExperience(RPGStatsInv(DInv.DamagePlayerController.Pawn.FindInventoryType(class'RPGStatsInv')), XPGained);
			}
		}
	}
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	Local float OriginalDamage;
	Local InvulnerabilityInv IInv;
	Local float XPGained;

	if(bOwnedByInstigator || Injured == None)
		return; //if the instigator is doing the damage, ignore this.
		
	if(Damage > 0)
	{
		IInv = InvulnerabilityInv(Injured.FindInventoryType(class'InvulnerabilityInv'));
		if (IInv != None)
		{
		    // injured player is in a invulnerability sphere. Reduce damage and give xp to sphere spawner
		    OriginalDamage = Damage;
			Damage = 0;
			Momentum = vect(0,0,0);
		    // check for not same team before awarding xp
			if ( Instigator != None && Injured != Instigator && Injured.Health > 0 && Instigator.Controller != None
				&& Injured.Controller != None && !Injured.Controller.SameTeamAs(Instigator.Controller) )
			{
			    // saved some damage from an enemy. Let's give xp.
			    if (IInv.InvPlayerController != None && IInv.InvPlayerController.Pawn != None && IInv.Rules != None && IInv.InvPlayerController != Instigator.Controller && IInv.InvPlayerController != Injured.Controller)
			    {
			        XPGained = fmin(IInv.ExpPerDamage * OriginalDamage, default.MaxXPperHit); // max 10 xp per hit
			        IInv.Rules.ShareExperience(RPGStatsInv(IInv.InvPlayerController.Pawn.FindInventoryType(class'RPGStatsInv')), XPGained);
			        //Log("******* Player:" $ IInv.InvPlayerController.Pawn @ "is getting" @ XPGained @ "xp for preventing" @ OriginalDamage @ "to" @ Injured @ "Damagetype:" $ DamageType);
				}
			}
			// now let's do a status check on the pawn
			if (Injured == IInv.PlayerPawn)
			{
			    IInv.PlayerHealth = Injured.Health;
			}
			else
			{
			    IInv.PlayerPawn = Injured;
			    IInv.PlayerHealth = Injured.Health;
			}
		}
	}
}

defaultproperties
{
	LowLevel = 20
	MediumLevel = 40
	MaxLevel=1
	StartingCost=1
	MaxXPperHit=10.0
}