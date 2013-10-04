class ClassWeaponsMaster extends RPGClass
	config(UT2004RPG)
	abstract;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	class'ClassWeaponsMaster'.static.AddLowLevelRegen(Other, 0);
}

static simulated function AddLowLevelRegen(Pawn Other, int AdditionalLevelAdd)
{
	local RPGStatsInv StatsInv;
	local int y;
	local int RegenLevel;
	local int RegenIndex;
	RegenIndex = -1;
	
	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
 	if (StatsInv != None && StatsInv.DataObject != None && StatsInv.DataObject.Level <= default.MediumLevel)
 	{
 		for (y = 0; y < StatsInv.Data.Abilities.length; y++)
 		{
 			if (ClassIsChildOf(StatsInv.Data.Abilities[y], class'AbilityRegen'))
 			{
 				RegenLevel = StatsInv.Data.AbilityLevels[y];
 				RegenIndex = y;
 			}
 		}

		if(StatsInv.DataObject.Level <= default.LowLevel)
		{
			if(RegenIndex >= 0)
				StatsInv.Data.Abilities[RegenIndex].static.ModifyPawn(Other, RegenLevel + 3 + AdditionalLevelAdd);
			else
				class'DruidRegen'.static.ModifyPawn(Other, RegenLevel + 3 + AdditionalLevelAdd);
		}
		else if(StatsInv.DataObject.Level <= default.MediumLevel)
		{
			if(RegenIndex >= 0)
				StatsInv.Data.Abilities[RegenIndex].static.ModifyPawn(Other, RegenLevel + 2 + AdditionalLevelAdd);
			else
				class'DruidRegen'.static.ModifyPawn(Other, RegenLevel + 2 + AdditionalLevelAdd);
		}
 	}	
}

static function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local RPGStatsInv StatsInv;
	
	StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
 	if (StatsInv != None && StatsInv.DataObject.Level <= default.MediumLevel)
 	{
		if(StatsInv.DataObject.Level <= default.LowLevel)
			class'DruidVampire'.static.HandleDamage(Damage, Injured, Instigator, Momentum, DamageType, bOwnedByInstigator, 3);
		else if(StatsInv.DataObject.Level <= default.MediumLevel)
			class'DruidVampire'.static.HandleDamage(Damage, Injured, Instigator, Momentum, DamageType, bOwnedByInstigator, 2);
 	}
}

defaultproperties
{
	AbilityName="Class: Weapons Master"
	Description="This class is the prerequisite for all weapon related abilities.|You can not be more than one class at any time."
	BotChance=10
}
