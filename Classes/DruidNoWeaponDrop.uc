class DruidNoWeaponDrop extends RPGDeathAbility
	abstract;

static function GenuineDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local DruidOldWeaponHolder OldWeaponHolder;
	Local Inventory inv;
	local int x;
	Local Array<Weapon> Weapons;

	if(Killed.isA('Vehicle'))
	{
		Killed = Vehicle(Killed).Driver;
	}
// Wierdness - looks like sometimes PD called twice, particularly in VINV?
// Killed can become "None" somewhere along the line.
	if(Killed == None)
	{
		return;
	}

	if(Killed.Controller == Killer)
		return;

	if(DamageType == class'Suicided')
		return;

	if (Killed.Controller != None && Killed.Weapon != None)
	{
		if (RPGWeapon(Killed.Weapon) != None)
			Killed.Controller.LastPawnWeapon = RPGWeapon(Killed.Weapon).ModifiedWeapon.Class;
		else
			Killed.Controller.LastPawnWeapon = Killed.Weapon.Class;
	}

	if (AbilityLevel == 2)
	{
		if(Killed.Weapon != None)
		{
			OldWeaponHolder = Killed.spawn(class'DruidOldWeaponHolder',Killed.Controller);
			storeOldWeapon(Killed, Killed.Weapon, OldWeaponHolder);
		}
	}
	else if(AbilityLevel == 3)
	{
		for (Inv = Killed.Inventory; Inv != None; Inv = Inv.Inventory)
			if(Weapon(Inv) != None)
				Weapons[Weapons.length] = Weapon(Inv);

		OldWeaponHolder = Killed.spawn(class'DruidOldWeaponHolder',Killed.Controller);

		for(x = 0; x < Weapons.length; x++)
			storeOldWeapon(Killed, Weapons[x], OldWeaponHolder);
	}

	Killed.Weapon = None;

	return;
}

static function storeOldWeapon(Pawn Killed, Weapon Weapon, DruidOldWeaponHolder OldWeaponHolder)
{
	Local DruidOldWeaponHolder.WeaponHolder holder;

	if(Weapon == None)
		return;
	
	if(RPGWeapon(Weapon) != None)
	{
		if(instr(caps(string(RPGWeapon(Weapon).ModifiedWeapon.class)), "TRANSLAUNCHER") > -1)
			return;
	}
	else
	{
		if(instr(caps(string(Weapon.class)), "TRANSLAUNCHER") > -1)
			return;
	}

	Weapon.DetachFromPawn(Killed);
	holder.Weapon = Weapon;
	holder.AmmoAmounts1 = Weapon.AmmoAmount(0);
	holder.AmmoAmounts2 = Weapon.AmmoAmount(1);

	OldWeaponHolder.WeaponHolders[OldWeaponHolder.WeaponHolders.length] = holder;

	Killed.DeleteInventory(holder.Weapon);
	//this forces the weapon to stay relevant to the player who will soon reclaim it
	holder.Weapon.SetOwner(Killed.Controller); 
	if (RPGWeapon(holder.Weapon) != None)
		RPGWeapon(holder.Weapon).ModifiedWeapon.SetOwner(Killed.Controller);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local DruidOldWeaponHolder OldWeaponHolder;
	Local DruidOldWeaponHolder.WeaponHolder holder;
	local Inventory OInv;
	local Inventory SG;
	local Inventory AR;
	local bool bok;

	if (Other.Role != ROLE_Authority || AbilityLevel < 2)
		return;

	foreach Other.DynamicActors(class'DruidOldWeaponHolder', OldWeaponHolder)
		if (OldWeaponHolder.Owner == Other.Controller)
		{
			while(OldWeaponHolder.WeaponHolders.length > 0)
			{
				Holder = oldWeaponHolder.WeaponHolders[0];
				if(Holder.Weapon != None)
				{
					if (instr(caps(Holder.Weapon.ItemName), "SHIELD GUN") > -1 || instr(caps(Holder.Weapon.ItemName), "ASSAULT RIFLE") > -1)
					{
						// Go ahead and find them both in the Other's inventory.  This way if we end up
						// having to do them both, we'll only have to do the loop once. However, we use
						// a bool instead of the double check (see DruidLoaded) as we'd end up making 
						// SG or AR None again when we destroy the first one and doing the loop again.
						for (OInv=Other.Inventory ; OInv != None && !bok ; OInv=OInv.Inventory)
						{
							if(instr(caps(OInv.ItemName), "SHIELD GUN") > -1)
								SG=OInv;
							if(instr(caps(OInv.ItemName), "ASSAULT RIFLE") > -1)
								AR=OInv;
							if (SG != None && AR != None)
								bok = true;
						}
						if (instr(caps(Holder.Weapon.ItemName), "SHIELD GUN") > -1 && SG != None)
							Other.DeleteInventory(SG);
						if (instr(caps(Holder.Weapon.ItemName), "ASSAULT RIFLE") > -1 && AR != None)
							Other.DeleteInventory(AR);
					}
							
					Holder.Weapon.GiveTo(Other); //somehow it can be destroyed.
					if(Holder.Weapon == None)
						Continue;
					Holder.Weapon.AddAmmo
					(
						Holder.AmmoAmounts1 - Holder.Weapon.AmmoAmount(0), 
						0
					);
					Holder.Weapon.AddAmmo
					(
						Holder.AmmoAmounts2 - Holder.Weapon.AmmoAmount(1), 
						1
					);
				}
				OldWeaponHolder.WeaponHolders.remove(0, 1);
			}
			OldWeaponHolder.Destroy();
			return;
		}
}

defaultproperties
{
     AbilityName="Denial"
     Description="The first level of this ability simply prevents you from dropping a weapon when you die (but you don't get it either). The second level allows you to respawn with the weapon and ammo you were using when you died. The third level will save all your weapons when you die. You need to be at least Level 25 to purchase this ability. |This ability does not trigger for self-inflicted death.|Cost (per level): 15,20,20"
     MaxLevel=3
     
     MinPlayerLevel=25
     LevelCost[1]=15
     LevelCost[2]=20
     LevelCost[3]=20
     BotChance=1
}
