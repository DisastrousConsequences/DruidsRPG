class RPGDamageGameRules extends GameRules
	config(UT2004RPG);
// based on Mysterials RPGRules to slightly tweak the NetDamage code

var RPGRules UT2004RPGRules;
var config int MaxMonsterDB;
var config int MaxMonsterDR;

function ReOrderGameRules()
{
	local GameRules G, RPGG, DG;

	Warn("RPGDamageGameRules not before RPGRules.");
	// we have a problem. See if we can fix
	for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if(G.isA('RPGRules'))
		{
			if (G.isA('RPGDamageGameRules'))
			{
				if (DG != None)
					Warn("Two sets of RPGDamageGameRules in the GameModifiers list");
				DG = G;
			}
			else
			{
				if (RPGG != None)
					Warn("Two sets of RPGRules in the GameModifiers list");
				RPGG = G;
			}
		}
	}
	if (DG == None || RPGG == None)
	{
		// we are stuffed
		Warn("Not running a RPGDamageGameRules or a RPGRules");
		return;
	}
	// ok, we have the two sets of Rules
	// find the RPGRules and take it out of the list. Then add it back after the DruidRPGDamageGameRules
	if (Level.Game.GameRulesModifiers != None && Level.Game.GameRulesModifiers.IsA('RPGRules') && !Level.Game.GameRulesModifiers.IsA('RPGDamageGameRules'))
	{
		// RPGRules is at the start
		Level.Game.GameRulesModifiers = Level.Game.GameRulesModifiers.NextGameRules;
	}
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if (G.NextGameRules != None && G.NextGameRules.IsA('RPGRules') && !G.NextGameRules.IsA('RPGDamageGameRules'))
			{
				G.NextGameRules = G.NextGameRules.NextGameRules;
			}
		}
	}
	// now add RPGRules back in after DruidRPGDamageGameRules
	RPGG.NextGameRules = DG.NextGameRules;
	DG.NextGameRules = RPGG;
	Warn("RPGDamageGameRules fixed so now before RPGRules.");
}

function int ContinueNetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	// Normally we would call Super.NetDamage at the end of processing our NetDamage.
	// super.NetDamage calls NextGameRules.NetDamage
	// so we will do that instead of calling Super.NetDamage
	// However, if NextGameRules is the RPGRules then we will skip it and go onto the one after, since we are superseeding RPGRules.NetDamage
	
	// we should be in the modifiers list immediately before the RPGRules gamerules. If not, we need to put ourselves there, as we want to skip the RPGRules NetDamage
	if ( NextGameRules == None || RPGRules(NextGameRules) == None)
	{
		ReOrderGameRules();
		return Damage;		// lets not risk looping
	}
	else
	{	// do not want to do the NetDamage for RPGRules, so skip it to the next one
		if (UT2004RPGRules == None)
			UT2004RPGRules = RPGRules(NextGameRules);
		if (NextGameRules.NextGameRules != None)
		{
			return NextGameRules.NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
		}
	}

	return Damage;

}

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local RPGPlayerDataObject InjuredData, InstigatedData;
	local RPGStatsInv InjuredStatsInv, InstigatedStatsInv;
	local int x, MonsterLevel;
	local FriendlyMonsterController C;
	local bool bZeroDamage;
	local bool bCalledContinueNetDamage;

	if (UT2004RPGRules == None)
		return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);		// we can't replace RPGRules, so use original

	if (injured == None || instigatedBy == None || injured.Controller == None || instigatedBy.Controller == None)
		return ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

	C = FriendlyMonsterController(injured.Controller);
	if (C != None && C.Master != None)
	{
		if (C.Master == instigatedBy.Controller)
			Damage = OriginalDamage;
		else if (C.SameTeamAs(instigatedBy.Controller))
			Damage *= TeamGame(Level.Game).FriendlyFireScale;
	}

	// get instigatedBy's RPGStatsInv here so if we bail early we can still give exp for any damage vs monsters
	InstigatedStatsInv = UT2004RPGRules.GetStatsInvFor(instigatedBy.Controller);

	if (DamageType.default.bSuperWeapon || Damage >= 1000)
	{
		//if this is weapon damage and the player doing the damage has an RPGWeapon, let it modify the damage
		if (ClassIsChildOf(DamageType, class'WeaponDamageType') && RPGWeapon(InstigatedBy.Weapon) != None)
			RPGWeapon(InstigatedBy.Weapon).NewAdjustTargetDamage(Damage, OriginalDamage, Injured, HitLocation, Momentum, DamageType);
		if (InstigatedStatsInv != None)
			UT2004RPGRules.AwardEXPForDamage(instigatedBy.Controller, InstigatedStatsInv, injured, Damage);
		return ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	}
	else if (Monster(injured) != None && FriendlyMonsterController(injured.Controller) == None && Monster(instigatedBy) != None && FriendlyMonsterController(instigatedBy.Controller) == None)
	{
		// monster v monster. Let them fight it out.
		return ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	}

	if (Damage <= 0)
	{
		Damage = ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
		bCalledContinueNetDamage = true;
		if (Damage < 0)
			return Damage;
		else if (Damage == 0) //for zero damage, still process abilities/magic weapons so effects relying on hits instead of damage still work
			bZeroDamage = true;
	}

	//get data
	if (InstigatedStatsInv != None)
		InstigatedData = InstigatedStatsInv.DataObject;

	InjuredStatsInv = UT2004RPGRules.GetStatsInvFor(injured.Controller);
	if (InjuredStatsInv != None)
		InjuredData = InjuredStatsInv.DataObject;

	if (InstigatedData == None || InjuredData == None)
	{
		if (Level.Game.IsA('Invasion'))
		{
			MonsterLevel = (Invasion(Level.Game).WaveNum + 1) * 2;
			if (UT2004RPGRules.RPGMut.bAutoAdjustInvasionLevel && UT2004RPGRules.RPGMut.CurrentLowestLevelPlayer != None)
				MonsterLevel += Max(0, UT2004RPGRules.RPGMut.CurrentLowestLevelPlayer.Level * UT2004RPGRules.RPGMut.InvasionAutoAdjustFactor);
		}
		else if (UT2004RPGRules.RPGMut.CurrentLowestLevelPlayer != None)
			MonsterLevel = UT2004RPGRules.RPGMut.CurrentLowestLevelPlayer.Level;
		else
			MonsterLevel = 1;
		if ( InstigatedData == None && ( (instigatedBy.IsA('Monster') && !instigatedBy.Controller.IsA('FriendlyMonsterController'))
						 || TurretController(instigatedBy.Controller) != None ) )
		{
			InstigatedData = RPGPlayerDataObject(Level.ObjectPool.AllocateObject(class'RPGPlayerDataObject'));
			InstigatedData.Attack = MonsterLevel / 2 * UT2004RPGRules.PointsPerLevel;
			if (InstigatedData.Attack > MaxMonsterDB)
				InstigatedData.Attack = MaxMonsterDB;
			InstigatedData.Defense = InstigatedData.Attack;
			if (InstigatedData.Defense > MaxMonsterDR)
				InstigatedData.Defense = MaxMonsterDR;
			InstigatedData.Level = MonsterLevel;
		}
		if ( InjuredData == None && InstigatedData != None && ( (injured.IsA('Monster') && !injured.Controller.IsA('FriendlyMonsterController'))
					      || TurretController(injured.Controller) != None ) )
		{
			InjuredData = RPGPlayerDataObject(Level.ObjectPool.AllocateObject(class'RPGPlayerDataObject'));
			InjuredData.Attack = MonsterLevel / 2 * UT2004RPGRules.PointsPerLevel;
			if (InjuredData.Attack > MaxMonsterDB)
				InjuredData.Attack = MaxMonsterDB;
			InjuredData.Defense = InjuredData.Attack;
			if (InjuredData.Defense > MaxMonsterDR)
				InjuredData.Defense = MaxMonsterDR;
			InjuredData.Level = MonsterLevel;
		}
	}

	if (InstigatedData == None)
	{
		//This should never happen
		Log("InstigatedData not found for "$instigatedBy.GetHumanReadableName());
		if (!bCalledContinueNetDamage)
			Damage = ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
		return Damage;
	}
	if (InjuredData == None)
	{
		//This should never happen
		if (InstigatedStatsInv == None && InstigatedData != None)
			Level.ObjectPool.FreeObject(InstigatedData);
		Log("InjuredData not found for "$injured.GetHumanReadableName());
		if (!bCalledContinueNetDamage)
			Damage = ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
		return Damage;
	}

	//headshot bonus EXP
	if (DamageType.Name == 'DamTypeSniperHeadShot' && InstigatedStatsInv != None && !instigatedBy.Controller.SameTeamAs(injured.Controller))
	{
		InstigatedData.Experience++;
		UT2004RPGRules.RPGMut.CheckLevelUp(InstigatedData, InstigatedBy.PlayerReplicationInfo);
	}

	Damage += int((float(Damage) * (1.0 + float(InstigatedData.Attack) * 0.005)) - (float(Damage) * (1.0 + float(InjuredData.Defense) * 0.005)));

	if (Damage < 1 && !bZeroDamage)
		Damage = 1;

	//if this is weapon damage and the player doing the damage has an RPGWeapon, let it modify the damage
	if (ClassIsChildOf(DamageType, class'WeaponDamageType') && RPGWeapon(InstigatedBy.Weapon) != None)
		RPGWeapon(InstigatedBy.Weapon).NewAdjustTargetDamage(Damage, OriginalDamage, Injured, HitLocation, Momentum, DamageType);

	//Allow Abilities to react to damage
	if (InstigatedStatsInv != None)
	{
		for (x = 0; x < InstigatedData.Abilities.length; x++)
			InstigatedData.Abilities[x].static.HandleDamage(Damage, injured, instigatedBy, Momentum, DamageType, true, InstigatedData.AbilityLevels[x]);
	}
	else
	{
		if (InstigatedData != None)
			Level.ObjectPool.FreeObject(InstigatedData);
	}
	if (InjuredStatsInv != None)
	{
		for (x = 0; x < InjuredData.Abilities.length; x++)
			InjuredData.Abilities[x].static.HandleDamage(Damage, injured, instigatedBy, Momentum, DamageType, false, InjuredData.AbilityLevels[x]);
	}
	else
	{
		if (InjuredData != None)
			Level.ObjectPool.FreeObject(InjuredData);
	}

	if (bZeroDamage)
	{
		return 0;
	}
	else
	{
		if (InstigatedStatsInv != None)
		{
			if (InstigatedBy.HasUDamage())
			{
				//UDamage is applied after this function so add it in to get the real amount of damage that will be done
				UT2004RPGRules.AwardEXPForDamage(instigatedBy.Controller, InstigatedStatsInv, injured, Damage * 2);
			}
			else
			{
				UT2004RPGRules.AwardEXPForDamage(instigatedBy.Controller, InstigatedStatsInv, injured, Damage);
			}
		}
		if (!bCalledContinueNetDamage)
			Damage = ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
		return Damage;
	}
}

defaultproperties
{
    MaxMonsterDB=374		// limit so monster does 260% damage max with player maxDR = 50
    MaxMonsterDR=250		// limit so player does 15% damage min with player maxDB = 80
}
