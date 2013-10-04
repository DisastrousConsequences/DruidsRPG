class CostRPGAbility extends RPGAbility
	abstract;

var int MinWeaponSpeed;
var int MinHealthBonus;
var int MinAdrenalineMax;
var int MinDB;
var int MinDR;
var int MinAmmo;

var int WeaponSpeedStep;
var int HealthBonusStep;
var int AdrenalineMaxStep;
var int DBStep;
var int DRStep;
var int AmmoStep;

var int MinPlayerLevel;
var int PlayerLevelStep;
// or
var Array< int > PlayerLevelReqd;

// if LevelCost set, takes precedence over (default.StartingCost + default.CostAddPerLevel * CurrentLevel)
var Array< int > LevelCost;		

var Array<class<RPGAbility> > ExcludingAbilities;	// if you have one of these you cannot purchase
var Array<class<RPGAbility> > RequiredAbilities;	// you must have all of these

static simulated function int GetCost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local int ab;
	local bool gotab;
	
	if (Data == None)
		return 0;
	
	// check the stats
	if (Data.WeaponSpeed < default.MinWeaponSpeed + (CurrentLevel * default.WeaponSpeedStep))
		return 0;
	if (Data.HealthBonus < default.MinHealthBonus + (CurrentLevel * default.HealthBonusStep))
		return 0;
	if (Data.AdrenalineMax < default.MinAdrenalineMax + (CurrentLevel * default.AdrenalineMaxStep))
		return 0;
	if (Data.Attack < default.MinDB + (CurrentLevel * default.DBStep))
		return 0;
	if (Data.Defense < default.MinDR + (CurrentLevel * default.DRStep))
		return 0;
	if (Data.AmmoMax < default.MinAmmo + (CurrentLevel * default.AmmoStep))
		return 0;

	// now check the player level
	if(Data.Level < (default.MinPlayerLevel + CurrentLevel*default.PlayerLevelStep))
		return 0;

	if (default.PlayerLevelReqd.length > CurrentLevel+1)		// since zero based need +1
		if (default.PlayerLevelReqd[CurrentLevel+1] > Data.Level)
			return 0;

	// check if already maxed
	if (CurrentLevel >= default.MaxLevel)
		return 0;
		
	// check for excluding abilities
	for (ab = 0; ab < default.ExcludingAbilities.length; ab++)
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == default.ExcludingAbilities[ab])
				return 0;
	// now check for required abilities
	for (ab = 0; ab < default.RequiredAbilities.length; ab++)
	{
		gotab = false;
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == default.RequiredAbilities[ab])
				gotab = true;
		if (!gotab)
			return 0;
	}

	// wow. Can buy
	if (default.LevelCost.length <= CurrentLevel)
		return default.StartingCost + default.CostAddPerLevel * CurrentLevel;
	else
		return default.LevelCost[CurrentLevel+1];
}

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	// this is called serverside from ServerAddAbility. 
	// Need to do standard processing, and add a subclass check just in case
	// pass in dummy subclass. It will then go and find it.
	return static.SubClassCost(Data, CurrentLevel, "");		
}

static simulated function int SubClassCost(RPGPlayerDataObject Data, int CurrentLevel, string curSubClass)
{
	// this is a clientside request from the StatsMenu
	// and we should have already checked the ability is valid if subClass is set.
	// if subClass is not set, then it will be a server side call from ServerAddAbility
	local int curSubClasslevel;
	local class<RPGClass> curClass;
	local int CostValue;
	local int x;
	local int y;

	// first check the basics
	CostValue = static.GetCost(Data, CurrentLevel);
	if (CostValue <= 0)
		return 0;
	
	// ok, passed that. Now let's check class and subclass
	// now really want to do a if ( Level.NetMode == NM_Client)
	// but have no actors to work with.
	// instead bodge on the fact the ownerid isnt set in Data on clients
	if ( Data.OwnerID == "")
	{
		// we are clientside, so can't really do any more testing
		if (curSubClass == "")
		{
			// shouldn't really happen. SubClass should have been set. 
			// Must be the stats menu misbehaving somehow, and the old call must have been used
			return 0;		// return 0 to stop people buying what they shouldnt
		}
		return CostValue;		
	}
	
	curSubClasslevel = -1;
	if (curSubClass == "")
	{
		// first find class and subclass
		curClass = None;
		// first lets find the class
		for (y = 0; y < Data.Abilities.length; y++)
			if (ClassIsChildOf(Data.Abilities[y], class'RPGClass'))
			{
				// found the class
				curClass = class<RPGClass>(Data.Abilities[y]);
			}
			else
			if (ClassIsChildOf(Data.Abilities[y], class'SubClass'))
			{
				//found the subclass
				curSubClassLevel = Data.AbilityLevels[y];
			}
		
		// ok now check the subclass text
		if (curClass == None)
			curSubClasslevel = 0;		// for no class
		else
		{
			if (curSubClass == "")
			{
				// if got a class but no sub class, the abilities are configured under the class ability name
				curSubClass = curClass.default.AbilityName;								
			}
		}
	}
	// now convert subclass name to index
	if (curSubClassLevel < 0) 
	{	// havent found subclass ability, so must be none.
		for (y = 0; y < class'SubClass'.default.SubClasses.length; y++)
			if (curSubClass == class'SubClass'.default.SubClasses[y])
				curSubClassLevel = y;
		if (curSubClasslevel < 0)
			curSubClassLevel = 0;		// default to none.
	}
	// now check ability is available
	for (x = 0; x < class'SubClass'.default.AbilityConfigs.length; x++)
	{
		if ( default.Class == class'SubClass'.default.AbilityConfigs[x].AvailableAbility)
		{
			if (class'SubClass'.default.AbilityConfigs[x].MaxLevels.Length > curSubClassLevel)
			{
				if (CurrentLevel < class'SubClass'.default.AbilityConfigs[x].MaxLevels[curSubClassLevel])
					return CostValue;
				else
					return 0;
			}
			else
				return 0;		// not properly configured - not enough entries to this subclass
		}
	}

	return CostValue;
}

DefaultProperties
{
	AbilityName="Costed RPG Ability"
	Description=""
	
	MinWeaponSpeed=0
	MinHealthBonus=0
	MinAdrenalineMax=100
	MinDB=0
	MinDR=0
	MinAmmo=0
	MinPlayerLevel=0

	WeaponSpeedStep=0
	HealthBonusStep=0
	AdrenalineMaxStep=0
	DBStep=0
	DRStep=0
	AmmoStep=0
	PlayerLevelStep=0
}