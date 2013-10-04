class DruidGhost extends RPGDeathAbility
	abstract;

static function bool GenuinePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local DruidGhostInv Inv;
	local Vehicle V;

	Local NullEntropyInv NInv;
	Local KnockbackInv KInv;
	Local DamageInv DInv;
	Local InvulnerabilityInv IInv;

	//Deviation from Mysterial's code. I dont think I need this.
	//if (Killed.Location.Z < Killed.Region.Zone.KillZ || Killed.PhysicsVolume.IsA('ConvoyPhysicsVolume'))
	//	return false;

	//spacefighters destroy all their inventory on possess, so if we do anything here it will never die
	//because our marker will get destroyed afterward
	if ( Killed.IsA('ASVehicle_SpaceFighter')
	     || (Killed.DrivenVehicle != None && Killed.DrivenVehicle.IsA('ASVehicle_SpaceFighter')) )
		return false;

	//this ability doesn't work with SVehicles or any kind of turret (can't change their physics)

	// Okay um.  This seems to work for monsters, blocks and sentinels!  Fix that!
	if (Killed.IsA('Monster') || DruidBlock(Killed) != None || DruidExplosive(Killed) != None  || DruidEnergyWall(Killed) != None || (ASVehicle(Killed) != None && ASVehicle(Killed).bNonHumanControl))
		return false;

	if (Killed.bStationary || Killed.IsA('SVehicle'))
	{
		//but maybe we can save the driver!
		V = Vehicle(Killed);
		if (V != None && !V.bRemoteControlled && !V.bEjectDriver && V.Driver != None)
			V.Driver.Died(Killer, DamageType, HitLocation);
		return false;
	}

	Inv = DruidGhostInv(Killed.FindInventoryType(class'DruidGhostInv'));
	if (Inv != None)
		return false;

	//ability won't work if pawn is still attached to the vehicle
	if (Killed.DrivenVehicle != None)
	{
		Killed.Health = 1; //so vehicle will properly kick pawn out
		Killed.DrivenVehicle.KDriverLeave(true);
	}

// ULTIMA REMOVED.  Shouldn't be needed in RPGDeathAbility.
	
	KInv = KnockbackInv(Killed.FindInventoryType(class'KnockbackInv'));
	if(KInv != None)
	{
		KInv.PawnOwner = None;
		KInv.Destroy();
	}
	NInv = NullEntropyInv(Killed.FindInventoryType(class'NullEntropyInv'));
	if(NInv != None)
	{
		NInv.PawnOwner = None;
		NInv.Destroy();
	}	
	DInv = DamageInv(Killed.FindInventoryType(class'DamageInv'));
	if(DInv != None)
	{
		DInv.SwitchOffDamage();
		DInv.Destroy();
	}	
	IInv = InvulnerabilityInv(Killed.FindInventoryType(class'InvulnerabilityInv'));
	if(IInv != None)
	{
		IInv.SwitchOffInvulnerability();
		IInv.Destroy();
	}	

	Inv = Killed.spawn(class'DruidGhostInv', Killed,,, rot(0,0,0));
	Inv.OwnerAbilityLevel = AbilityLevel;
	Inv.GiveTo(Killed);
	return true;
}

static function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType, int AbilityLevel)
{
	local DruidGhostInv Inv;

	Inv = DruidGhostInv(Killed.FindInventoryType(class'DruidGhostInv'));
	if (Inv != None)
		return false;

	return true;
}

defaultproperties
{
	AbilityName="Ghost"
	LevelCost[1]=40
	LevelCost[2]=25
	LevelCost[3]=20
	MinHealthBonus=200
	MinDR=50
	Description="The first time each spawn that you take damage that would kill you, instead of dying you will become non-corporeal and move to a new location, where you will continue your life. At level 1 you will move slowly as a ghost and return with a health of 1. At level 2 you will move somewhat more quickly and will return with 100 health. At level 3 you will move fastest and will return with your normal starting health. You need to have at least 200 Health Bonus and 50 Damage Reduction to purchase this ability. |Cost (per level): 40,25,20"
	MaxLevel=3

	ExcludingAbilities[0]=class'AbilityUltima'
	ExcludingAbilities[1]=class'AbilityGhost'
}
