class DruidLoaded extends CostRPGAbility
	config(UT2004RPG) 
	abstract;

// these config variables just affect the server so ok
var config Array< String > Weapons;
var config Array< String > ONSWeapons;
var config Array< String > SuperWeapons;

var config float WeaponDamage;
var config float AdrenalineDamage;

static function bool AbilityIsAllowed(GameInfo Game, MutUT2004RPG RPGMut)
{
	if(RPGMut.WeaponModifierChance == 0)
		return false;

	return true;
}

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local Mutator m;
	local MutUT2004RPG RPGMut;
	local int x;
	local LoadedInv LoadedInv;
	local Inventory OInv;
	local Inventory SG;
	local Inventory AR;
	local int OldLevel;

	if (Other == None)
			return;
			
	if (Other.Level != None && Other.Level.Game != None)
	{
		for (m = Other.Level.Game.BaseMutator; m != None; m = m.NextMutator)
		if (MutUT2004RPG(m) != None)
		{
			RPGMut = MutUT2004RPG(m);
			break;
		}
	}

	LoadedInv = LoadedInv(Other.FindInventoryType(class'LoadedInv'));

	if (LoadedInv != None)
	{
		if(LoadedInv.bGotLoadedWeapons && LoadedInv.LWAbilityLevel == AbilityLevel)
			return;
	}
	else
	{
		LoadedInv = Other.spawn(class'LoadedInv');
		if(LoadedInv != None)
			LoadedInv.giveTo(Other);
	}

	if(LoadedInv == None)
		return;

	LoadedInv.bGotLoadedWeapons = true;
	OldLevel = LoadedInv.LWAbilityLevel;		// keep old level so only add new weapons
	LoadedInv.LWAbilityLevel = AbilityLevel;

	if(Other.Role != ROLE_Authority)
		return;

	for (OInv=Other.Inventory ; OInv != None && (SG == None || AR == None) ; OInv=OInv.Inventory)
	{
// You can't delete within the for, as Deleting results in OInv == None, so
// the AR is never found.  Instead, grab them both in their own var ...
		if(instr(caps(OInv.ItemName), "SHIELD GUN") > -1)
		{
			SG=OInv;
		}
		if(instr(caps(OInv.ItemName), "ASSAULT RIFLE") > -1)
		{
			AR=OInv;
		}
	}

// This stops the client from erroneously deleting the SG and AR - like
// after a ghost, getting into and out of a vehicle ... all those dumb
// cases where the client likes to run ModifyPawn when it probably
// shouldn't.

	// And delete them after they're both found.
	if(SG != None && LoadedInv != None)
		Other.DeleteInventory(SG);
	if(AR != None && LoadedInv != None)
		Other.DeleteInventory(AR);

	// so give them the weapons
	// but only ones granted as part of this upgrade. otherwise get multiple copies of each
	if (OldLevel < 1)
		for(x = 0; x < default.Weapons.length; x++)
			giveWeapon(Other, default.Weapons[x], AbilityLevel, RPGMut);
	if (OldLevel < 2)
		for(x = 0; AbilityLevel >= 2 && x < default.ONSWeapons.length; x++)
			giveWeapon(Other, default.ONSWeapons[x], AbilityLevel, RPGMut);
	if (OldLevel < 3)
		for(x = 0; Other.Level.Game.IsA('Invasion') && AbilityLevel >= 3 && x < default.SuperWeapons.length; x++)
			giveWeapon(Other, default.SuperWeapons[x], AbilityLevel, RPGMut);

}

static function giveWeapon(Pawn Other, String oldName, int AbilityLevel, MutUT2004RPG RPGMut)
{
	Local string newName;
	local class<Weapon> WeaponClass;
	local class<RPGWeapon> RPGWeaponClass;
	local Weapon NewWeapon;
	local RPGWeapon RPGWeapon;
	local int x;

	if(Other == None || Other.IsA('Monster'))
		return;

	if(oldName == "")
		return;

	if (Other.Level != None && Other.Level.Game != None && Other.Level.Game.BaseMutator != None)
	{
		newName = Other.Level.Game.BaseMutator.GetInventoryClassOverride(oldName);
		WeaponClass = class<Weapon>(Other.DynamicLoadObject(newName, class'Class'));
	}
	else
		WeaponClass = class<Weapon>(Other.DynamicLoadObject(oldName, class'Class'));

	newWeapon = Other.spawn(WeaponClass, Other,,, rot(0,0,0));
	if(newWeapon == None)
		return;
	while(newWeapon.isA('RPGWeapon'))
		newWeapon = RPGWeapon(newWeapon).ModifiedWeapon;

	if(AbilityLevel >= 4)
		RPGWeaponClass = GetRandomWeaponModifier(WeaponClass, Other, RPGMut);
	else
		RPGWeaponClass = RPGMut.GetRandomWeaponModifier(WeaponClass, Other);

	RPGWeapon = Other.spawn(RPGWeaponClass, Other,,, rot(0,0,0));
	if(RPGWeapon == None)
		return;
	RPGWeapon.Generate(None);
	
	//I'm checking the state of RPG Weapon a bunch because sometimes it becomes none mid method.
	if(RPGWeapon == None)
		return;

	if(AbilityLevel >= 5)		// need better modifier
	{
		if (AbilityLevel > 5)
		{
			RPGWeapon.Modifier = RPGWeapon.MaxModifier;
		}
		else
		{
			for(x = 0; x < 50; x++)
			{
				if(RPGWeapon.Modifier > -1)
					break;
				RPGWeapon.Generate(None);
				if(RPGWeapon == None)
					return;
			}
		}
	}

	if(RPGWeapon == None)
		return;

	RPGWeapon.SetModifiedWeapon(newWeapon, true);

	if(RPGWeapon == None)
		return;

	RPGWeapon.GiveTo(Other);

	if(RPGWeapon == None)
		return;

	if(AbilityLevel == 1)
	{
		RPGWeapon.FillToInitialAmmo();
	}
	else if(AbilityLevel > 1)
	{
		if (oldName == "XWeapons.AssaultRifle")
		{
			RPGWeapon.Loaded();
		}
		RPGWeapon.MaxOutAmmo();
	}
}

static function class<RPGWeapon> GetRandomWeaponModifier(class<Weapon> WeaponType, Pawn Other, MutUT2004RPG RPGMut)
{
	local int x, Chance;

	Chance = Rand(RPGMut.TotalModifierChance);
	for (x = 0; x < RPGMut.WeaponModifiers.Length; x++)
	{
		Chance -= RPGMut.WeaponModifiers[x].Chance;
		if (Chance < 0 && RPGMut.WeaponModifiers[x].WeaponClass.static.AllowedFor(WeaponType, Other))
			return RPGMut.WeaponModifiers[x].WeaponClass;
	}

	return class'RPGWeapon';
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(!bOwnedByInstigator)
		return;

	if(Damage > 0)
	{
		if (AbilityLevel > 5)   // extreme WM
		{
			if (ClassIsChildOf(DamageType, class'WeaponDamageType'))
				Damage *= default.WeaponDamage;
			else if (!ClassIsChildOf(DamageType, class'VehicleDamageType'))
				Damage *= default.AdrenalineDamage;
		}
	}
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (AbilityLevel <= 5)
		return false;		// don't know, so let someone else decide
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		bAllowPickup = 0;	// no enhanced or offensive artifacts allowed
		return true;
	}
	return false;		// don't know, so let someone else decide
}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
	local float AdValue;
	
	if (AbilityLevel <= 5 || Killer == None || Killed == None)
		return;
		
	if (!bOwnedByKiller)
		return;

	if (Killed.Level.Game.IsA('Invasion') && Killed.Pawn != None && Killed.Pawn.IsA('Monster'))
	{
	    // the player will have just got 'ScoringValue' worth of adrenaline. Let's take some of it back
	    AdValue = float(Killed.Pawn.GetPropertyText("ScoringValue"));
	    AdValue *= (1 - default.AdrenalineDamage);
		if (Killer.Adrenaline > AdValue)
		{
			Killer.Adrenaline -= AdValue;
		}
		else
		{
			// not enough - have to just zero
			Killer.Adrenaline = 0;
		}
	}
}

DefaultProperties
{
	  AbilityName="Loaded Weapons"
	  Description="When you spawn:|Level 1: You are granted all regular weapons with the default percentage chance for magic weapons.|Level 2: You are granted onslaught weapons and all weapons with max ammo.|Level 3: You are granted super weapons (Invasion game types only).|Level 4: Magic weapons will be generated for all your weapons.|Level 5: You receive all positive magic weapons.|Level 6: All maxed weapons and increased weapon damage, and reduced ability to use adrenaline and artifacts. |You must be level 40 before you can buy level 2 and level 55 before you can buy level 3.|Cost (per level): 10,15,20,25,30,.."
	  StartingCost=10
	  CostAddPerLevel=5
	  MaxLevel=6
	  
	  PlayerLevelReqd[1]=1
	  PlayerLevelReqd[2]=40
	  PlayerLevelReqd[3]=55
	  PlayerLevelReqd[4]=55
	  PlayerLevelReqd[5]=55
	  PlayerLevelReqd[6]=55

	  WeaponDamage=1.3
	  AdrenalineDamage=0.5

	  Weapons[0]="XWeapons.RocketLauncher"
	  Weapons[1]="XWeapons.ShockRifle"
	  Weapons[2]="UT2004RPG.RPGLinkGun"
	  Weapons[3]="XWeapons.SniperRifle"
	  Weapons[4]="XWeapons.FlakCannon"
	  Weapons[5]="XWeapons.MiniGun"
	  Weapons[6]="XWeapons.BioRifle"
	  Weapons[7]="XWeapons.ShieldGun"
	  Weapons[8]="XWeapons.AssaultRifle"

	  ONSWeapons[0]="UTClassic.ClassicSniperRifle"
	  ONSWeapons[1]="Onslaught.ONSGrenadeLauncher"
	  ONSWeapons[2]="Onslaught.ONSAVRiL"
	  ONSWeapons[3]="Onslaught.ONSMineLayer"

	  SuperWeapons[0]="XWeapons.Redeemer"
	  SuperWeapons[1]="XWeapons.Painter"
}
