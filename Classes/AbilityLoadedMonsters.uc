class AbilityLoadedMonsters extends CostRPGAbility
	config(UT2004RPG)
	abstract;

struct MonsterConfig
{
	Var String FriendlyName;
	var Class<Monster> Monster;
	var int Adrenaline;
	var int MonsterPoints;
	var int Level;
};

var config Array<MonsterConfig> MonsterConfigs;

var config int MaxNormalLevel;
var config float PetHealthFraction;

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local int i;
	local LoadedInv LoadedInv;
	Local RPGArtifact Artifact;
	Local bool PreciseLevel;

	LoadedInv = LoadedInv(Other.FindInventoryType(class'LoadedInv'));

	if(LoadedInv != None)
	{
		if(LoadedInv.bGotLoadedMonsters)
		{
			if (LoadedInv.LMAbilityLevel == AbilityLevel)
				return;
			PreciseLevel = true; //only giving artifacts for this level.
		}
	}
	else
	{
		LoadedInv = Other.spawn(class'LoadedInv');
		LoadedInv.giveTo(Other);
		PreciseLevel = false; 	//give all artifacts up to this level.
	}

	if(LoadedInv == None)
		return;

	LoadedInv.bGotLoadedMonsters = true;
	LoadedInv.LMAbilityLevel = AbilityLevel;

	for(i = 0; i < Default.MonsterConfigs.length; i++)
	{
		if(Default.MonsterConfigs[i].Monster != None) //make sure the object is sane.
		{
			if(PreciseLevel && Default.MonsterConfigs[i].Level != AbilityLevel) //checkertrap for purchases during a game.
				continue;
			if(Default.MonsterConfigs[i].Level <= AbilityLevel)
			{
				Artifact = Other.spawn(class'DruidMonsterMasterArtifactMonsterSummon', Other,,, rot(0,0,0));
				if(Artifact == None)
					continue; // wow.
				DruidMonsterMasterArtifactMonsterSummon(Artifact).Setup(Default.MonsterConfigs[i].FriendlyName, Default.MonsterConfigs[i].Monster, Default.MonsterConfigs[i].Adrenaline, Default.MonsterConfigs[i].MonsterPoints);
				Artifact.GiveTo(Other);
			}
		}
	}

	if(!PreciseLevel)
	{
		Artifact = Other.spawn(class'ArtifactKillAllPets', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
		Artifact = Other.spawn(class'ArtifactKillOnePet', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
	}
	
	if (AbilityLevel > default.MaxNormalLevel)
		LoadedInv.DirectMonsters = true;
	else
		LoadedInv.DirectMonsters = false;
	
// I'm guessing that NextItem is here to ensure players don't start with
// no item selected.  So the if should stop wierd artifact scrambles.
	if(Other.SelectedItem == None)
		Other.NextItem();
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	// need to check that summoned monsters do not get xp for not doing damage to same species
	local FriendlyMonsterController C;
	
	if (Instigator == None || Injured == None)
		return;

	if(!bOwnedByInstigator)
	{   // this is hitting a pet, so the pet will not get xp.
	    // while we are here, let's make sure the pet is not hurt by the spawner. This is a deliberate ommission in RPGRules
		C = FriendlyMonsterController(injured.Controller);
		if (C != None && C.Master != None && C.Master == Instigator.Controller)
		{
			Damage *= TeamGame(injured.Level.Game).FriendlyFireScale;
		}
		return;
 	}

	if (Monster(Instigator) == None || Monster(Injured) == None)
		return;
		
	// now know this is damage done by a monster on a pet
	if ( Monster(Injured).SameSpeciesAs(Instigator) )
		Damage = 0;

}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (AbilityLevel <= default.MaxNormalLevel)
		return false;		// don't know, so let someone else decide
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		bAllowPickup = 0;	// no enhanced or offensive artifacts allowed
		return true;
	}
	return false;		// don't know, so let someone else decide
}

defaultproperties
{
     AbilityName="Loaded Monsters"
     Description="Learn new monsters to summon with Monster Points. At each level, you can summon a better monster. |Cost (per level): 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,.."
     StartingCost=2
     CostAddPerLevel=1
     MaxLevel=30
//I assume you'll either use the provided config, or come up with your own. This one is provided as reference.
     MonsterConfigs(0)=(FriendlyName="Pupae",Monster=Class'SkaarjPack.SkaarjPupae',Adrenaline=15,MonsterPoints=1,Level=1)
     PetHealthFraction=0.75
     
     MaxNormalLevel=15
}
