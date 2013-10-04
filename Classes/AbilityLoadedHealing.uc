class AbilityLoadedHealing extends CostRPGAbility
	config(UT2004RPG)
	abstract;

var config int Lev2Cap;
var config int Lev3Cap;
var config int Lev4Cap;

var config bool enableSpheres;

var config float WeaponDamage;
var config float HealingDamage;
var config float AdrenalineUsage;

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local ArtifactMakeSuperHealer AMSH;
	local ArtifactHealingBlast AHB;
	local ArtifactSphereHealing ASpH;
	local ArtifactPoisonBlast APB;
	local ArtifactRemoteBooster ARB;
	local RPGStatsInv StatsInv;
	local int x;

	if(Monster(Other) != None)
		return; //Not for pets

	AMSH = ArtifactMakeSuperHealer(Other.FindInventoryType(class'ArtifactMakeSuperHealer'));

	if(AMSH != None)
	{
		if(AMSH.AbilityLevel == AbilityLevel)
			return;
	}
	else
	{
		AMSH = Other.spawn(class'ArtifactMakeSuperHealer', Other,,, rot(0,0,0));
		if(AMSH == None)
			return; //get em next pass I guess?

		AMSH.giveTo(Other);
		// I'm guessing that NextItem is here to ensure players don't start with
		// no item selected.  So the if should stop wierd artifact scrambles.
		if(Other.SelectedItem == None)
			Other.NextItem();
	}
	AMSH.AbilityLevel = AbilityLevel;
	if(AbilityLevel == 2)
	{
		AMSH.MaxHealth = Default.Lev2Cap;

		// check if we have LA, in which case we get the blast anyway
		StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));

		for (x = 0; StatsInv != None && x < StatsInv.Data.Abilities.length; x++)
		{
			if (StatsInv.Data.Abilities[x] == class'DruidArtifactLoaded')
			{
			    if (StatsInv.Data.AbilityLevels[x] >= 2)
			    {
					AHB = ArtifactHealingBlast(Other.FindInventoryType(class'ArtifactHealingBlast'));
					if(AHB == None)
					{
						AHB = Other.spawn(class'ArtifactHealingBlast', Other,,, rot(0,0,0));
						if(AHB == None)
							return; //get em next pass I guess?

						AHB.giveTo(Other);
						// I'm guessing that NextItem is here to ensure players don't start with
						// no item selected.  So the if should stop wierd artifact scrambles.
						if(Other.SelectedItem == None)
							Other.NextItem();
					}
			    }
			}
		}
 	}
	if(AbilityLevel >= 3)
	{
		if (AbilityLevel >= 4)
		{
			AMSH.HealingDamage = default.HealingDamage;
			AMSH.MaxHealth = Default.Lev4Cap;
		}
		else
			AMSH.MaxHealth = Default.Lev3Cap;
		if(default.enableSpheres)
		{
			// ok let's give them some artifacts
			AHB = ArtifactHealingBlast(Other.FindInventoryType(class'ArtifactHealingBlast'));
			if(AHB == None)
			{
				AHB = Other.spawn(class'ArtifactHealingBlast', Other,,, rot(0,0,0));
				if(AHB == None)
					return; //get em next pass I guess?

				if (AbilityLevel >= 4)
					AHB.EnhanceArtifact(default.AdrenalineUsage);
				AHB.giveTo(Other);
				// I'm guessing that NextItem is here to ensure players don't start with
				// no item selected.  So the if should stop wierd artifact scrambles.
				if(Other.SelectedItem == None)
					Other.NextItem();
			}
			ASpH = ArtifactSphereHealing(Other.FindInventoryType(class'ArtifactSphereHealing'));
			if(ASpH == None)
			{
				ASpH = Other.spawn(class'ArtifactSphereHealing', Other,,, rot(0,0,0));
				if(ASpH == None)
					return; //get em next pass I guess?

				if (AbilityLevel >= 4)
					ASpH.EnhanceArtifact(default.AdrenalineUsage);
				ASpH.giveTo(Other);
				// I'm guessing that NextItem is here to ensure players don't start with
				// no item selected.  So the if should stop wierd artifact scrambles.
				if(Other.SelectedItem == None)
					Other.NextItem();
			}
			if (AbilityLevel >= 4)
			{
				// lets also give them a poisonblast artifact
				APB = ArtifactPoisonBlast(Other.FindInventoryType(class'ArtifactPoisonBlast'));
				if(APB == None)
				{
					APB = Other.spawn(class'ArtifactPoisonBlast', Other,,, rot(0,0,0));
					if(APB == None)
						return; //get em next pass I guess?
	
					APB.EnhanceArtifact(default.AdrenalineUsage);   // not sure we should do this. But 75 xp is still 3 healing blasts  
					
					APB.giveTo(Other);
					// I'm guessing that NextItem is here to ensure players don't start with
					// no item selected.  So the if should stop wierd artifact scrambles.
					if(Other.SelectedItem == None)
						Other.NextItem();
				}
				// and a remote booster artifact
				ARB = ArtifactRemoteBooster(Other.FindInventoryType(class'ArtifactRemoteBooster'));
				if(ARB == None)
				{
					ARB = Other.spawn(class'ArtifactRemoteBooster', Other,,, rot(0,0,0));
					if(ARB == None)
						return; //get em next pass I guess?
	
					ARB.giveTo(Other);
					// I'm guessing that NextItem is here to ensure players don't start with
					// no item selected.  So the if should stop wierd artifact scrambles.
					if(Other.SelectedItem == None)
						Other.NextItem();
				}
			}
		}
	}
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(!bOwnedByInstigator)
		return;
	if(Damage > 0 && AbilityLevel >= 4)
	{
		// half weapon damage
		if (ClassIsChildOf(DamageType, class'WeaponDamageType') || ClassIsChildOf(DamageType, class'VehicleDamageType'))
			Damage *= default.WeaponDamage;
	}
}

defaultproperties
{
     AbilityName="Loaded Medic"
     Description="Gives you bonuses towards healing.|Level 1 gives you a Medic Weapon Maker. |Level 2 allows you to use the Medic Gun to heal teammates +100 beyond their max health. |Level 3 allows you to heal teammates +150 points beyond their max health. Level 4 gives extra healing power for the medic weapon and less adrenaline requirements for healing artifacts, but less weapon damage(|Cost (per level): 3,6,9,12"
     StartingCost=3
     CostAddPerLevel=3
     Lev2Cap=100
     Lev3Cap=150
     Lev4Cap=200
     MaxLevel=4
     enableSpheres = false
     WeaponDamage=0.5
     HealingDamage=3.0
     AdrenalineUsage=0.5
     BotChance=7
}
