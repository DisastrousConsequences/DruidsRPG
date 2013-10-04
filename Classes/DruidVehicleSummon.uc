class DruidVehicleSummon extends Summonifact
	config(UT2004RPG);

function bool SpawnIt(TranslocatorBeacon Beacon, Pawn P, EngineerPointsInv epi)
{
	Local Vehicle NewVehicle;
	local Vector SpawnLoc;

	SpawnLoc = Beacon.Location;
	SpawnLoc.z += 30;		// lift just off ground
	if (!CheckSpace(SpawnLoc,700,400))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}
	NewVehicle = epi.SummonVehicle(SummonItem, Points, P, SpawnLoc);
	if (NewVehicle == None)
		return false;
		
	if (DruidGoliath(NewVehicle) != None)
	    DruidGoliath(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (DruidHellBender(NewVehicle) != None)
	    DruidHellBender(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (DruidScorpion(NewVehicle) != None)
	    DruidScorpion(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (DruidPaladin(NewVehicle) != None)
	    DruidPaladin(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (DruidManta(NewVehicle) != None)
	    DruidManta(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (DruidIonTank(NewVehicle) != None)
	    DruidIonTank(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (DruidTC(NewVehicle) != None)
	    DruidTC(NewVehicle).SetPlayerSpawner(Instigator.Controller);

	SetStartHealth(NewVehicle);
	
	// now adjust the mass
	NewVehicle.MomentumMult *= 0.25;

	// now allow player to get xp bonus
	ApplyStatsToConstruction(NewVehicle,Instigator);

	return true;
}

function BotConsider()
{
	return;		// bots do not summon vehicles. Will just fill up passages etc
}

defaultproperties
{
	ItemName=""
	IconMaterial=Texture'DCText.Icons.SummonVehicleIcon'
}
