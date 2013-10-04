class DruidUpgradeInv extends Inventory
	config(DruidUpgrade);

var DruidUpgradeObj Obj;

function Tick(float deltaTime)
{
	Local RPGStatsInv Inv;
	local String CurrentVersion;
	Local MutUT2004RPG RPGMut;
	local Mutator m;
	Local String Entry;

	if(Instigator == None || Instigator.Controller == None || PlayerController(Instigator.Controller) == None || PlayerController(Instigator.Controller).PlayerReplicationInfo == None)
	{
		super.Tick(deltaTime);
		return; //early out. something is busted, hopefully it'll be worked out soon.
	}

	Inv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));

	if(Inv != None)
	{
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutUT2004RPG(m) != None)
			{
				RPGMut = MutUT2004RPG(m);
				break;
			}

		if(RPGMut != None)
		{
			Entry = PlayerController(Instigator.Controller).getPlayerIDHash() @ PlayerController(Instigator.Controller).PlayerReplicationInfo.GetHumanReadableName();

			Obj = new(None, Entry) class'DruidUpgradeObj';
			if(Obj != None)
			{
				CurrentVersion = getCurrentVersion();
				//Go go gadget upgrade.
				if(Obj.Version != CurrentVersion)
				{
					doUpgrade(Obj.Version, CurrentVersion, Inv);
					Obj.Version = CurrentVersion;
					Obj.saveConfig();
					Inv.DataObject.saveConfig();
					//now, recalculate their stats
					Inv.DataObject.CreateDataStruct(Inv.Data, false);
					RPGMut.ValidateData(Inv.DataObject);
					Inv.DataObject.CreateDataStruct(Inv.Data, false);
				}
				disable('Tick'); //we're done. Cash it out.
			}
		}
		
	} //if something isn't found, try next tick.
	
	super.Tick(deltaTime);
}

Function doUpgrade(String oldVersion, String newVersion, RPGStatsInv inv)
{
	//you may want to override this method for your upgrade. If you do so, you may not want to call super so my upgrade doesn't run...
	if(newVersion == "182")
		do182Upgrade(Inv);
}

//you probably dont want to override this method. This one is mine.
Function do182Upgrade(RPGStatsInv inv)
{
	Local int x;
	Local bool NeedAdrenalineMaster;
	Local bool NeedWeaponsMaster;

	Local bool FoundAdrenalineMaster;
	Local bool FoundWeaponsMaster;
	Local bool FoundMonsterMaster;
	Local bool FoundEngineer;
	Local bool GotAwareness;
	Local int AwareIdx;


	for (x = 0; x < Inv.DataObject.Abilities.length; x++)
	{
		if (Inv.DataObject.Abilities[x] == class'ClassAdrenalineMaster')
		{
			FoundAdrenalineMaster = True;
			break;
		}
		else if (Inv.DataObject.Abilities[x] == class'ClassWeaponsMaster')
		{
			FoundWeaponsMaster = True;
			break;
		}
		else if (Inv.DataObject.Abilities[x] == class'ClassMonsterMaster')
		{
			FoundMonsterMaster = True;
			NeedAdrenalineMaster = False;
			NeedWeaponsMaster = False;
// No break here - we've got something to look for. BF
		}
		else if (Inv.DataObject.Abilities[x] == class'ClassEngineer')
		{
			FoundEngineer = True;
			break;
		}
		else if(!NeedAdrenalineMaster && !NeedWeaponsMaster && !FoundMonsterMaster)
		{
			if (Inv.DataObject.Abilities[x] == class'DruidLoaded')
				NeedWeaponsMaster = True;
			else if (Inv.DataObject.Abilities[x] == class'DruidVampire')
				NeedWeaponsMaster = True;
			else if (Inv.DataObject.Abilities[x] == class'DruidRegen')
				NeedWeaponsMaster = True;

			else if (Inv.DataObject.Abilities[x] == class'DruidArtifactLoaded')
				NeedAdrenalineMaster = True;
			else if (Inv.DataObject.Abilities[x] == class'DruidEnergyVampire')
				NeedAdrenalineMaster = True;
			else if (Inv.DataObject.Abilities[x] == class'DruidAdrenalineSurge')
				NeedAdrenalineMaster = True;
			else if (Inv.DataObject.Abilities[x] == class'DruidAdrenalineRegen')
				NeedAdrenalineMaster = True;
		}
		else if (Inv.DataObject.Abilities[x] == class'DruidAwareness')
		{
			AwareIdx = x;
			GotAwareness = True;
		}
	}

	if(FoundAdrenalineMaster || FoundWeaponsMaster || FoundEngineer)
	{
		//hmm... Guess I didn't need to upgrade?!
		return;
	}

// I think this is best, all things considered. BF
	if (!FoundMonsterMaster && GotAwareness)
		NeedWeaponsMaster = True;

	if(FoundMonsterMaster && GotAwareness)
	{
		log(Inv.DataObject.Name@"Needed Awareness Switch");
		Inv.DataObject.Abilities[AwareIdx] = class'AbilityMedicAwareness';
// OW!  This will disconnect them, but this is the easiest way to
// get the change replicated to the client: Disconnect them. BF
		Instigator.Controller.Destroy();
	}
	else if(NeedAdrenalineMaster)
	{
		log(Inv.DataObject.Name@"Needed Adrenaline Master");

		Inv.DataObject.Abilities[Inv.DataObject.Abilities.length] = class'ClassAdrenalineMaster';
		Inv.DataObject.AbilityLevels[Inv.DataObject.AbilityLevels.length] = 1;
		Inv.ClientAddAbility(class'ClassAdrenalineMaster', 1);
	}
	else if(NeedWeaponsMaster)
	{
		log(Inv.DataObject.Name@"Needed Weapons Master");

		Inv.DataObject.Abilities[Inv.DataObject.Abilities.length] = class'ClassWeaponsMaster';
		Inv.DataObject.AbilityLevels[Inv.DataObject.AbilityLevels.length] = 1;
		Inv.ClientAddAbility(class'ClassAdrenalineMaster', 1);
	}
	log("182 Upgrade complete for"@Inv.DataObject.Name);
	
	//upgrade complete.
}

Function String getCurrentVersion()
{
	return "182"; 
	//this version only needs to be incremented when a schema change is made. Therefore, it wont be the exact same version
	//that is the build number.

	//You might want to override this method for your own mutator if you need to do your own upgrading ;)
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	enable('Tick');
	Super.GiveTo(Other);
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
}
