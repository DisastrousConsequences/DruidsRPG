class AbilityVehicleEject extends RPGDeathAbility
	abstract
	config(UT2004RPG);

var config int BigSeconds;

static function bool PrePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	Local Pawn Driver;
	Local Vehicle Vehicle;
	Local EjectedInv ejected;
	Local bool DestroyVehicle;
	Local bool SavedPlayer;
	
	destroyVehicle = false;

	Vehicle = Vehicle(Killed);
	if(Vehicle == None)
	{
		//Ok, so if they actually died in a vehicle, we're going to kick them out with one health and save them -- Dru
		if (Killed.DrivenVehicle != None)
		{
			Driver = Killed;
			Vehicle = Killed.DrivenVehicle;
			//now blow up the vehicle in a moment, since it's taking the fall for the player
			DestroyVehicle = true;
			//this is the only case where we actually save the player from death.
			SavedPlayer = true;
			
			//continue execution as normal.
		}		
		else
			return false;
	}
	else	
		Driver = Vehicle.Driver;

	if(Driver == None)
		return false; //no driver <shrug>

	if ( Killed.IsA('ASVehicle_SpaceFighter')
	     || (Killed.DrivenVehicle != None && Killed.DrivenVehicle.IsA('ASVehicle_SpaceFighter')) )
		return false;	// no point ejecting in space

	//here we go.
	ejected =  EjectedInv(Driver.FindInventoryType(class'EjectedInv'));
	if(ejected != None)
		return false; //still active ejection

	if(Driver.Health <= 0)
		Driver.Health = 1; //The player was about to die, so they need some health

	if(Vehicle.EjectMomentum <= 0) //make sure the vehicle has some eject momentum.
		Vehicle.EjectMomentum = class'ONSHoverBike'.default.EjectMomentum;

	Vehicle.EjectDriver(); //they're out! Yeehaw!!
	
	ejected = Driver.spawn(class'EjectedInv', Driver,,, rot(0,0,0));
	ejected.lifespan = default.BigSeconds/AbilityLevel;
	ejected.GiveTo(Driver);
					
	if(SavedPlayer)
		return true;
	else
		return false; //I know this sounds strange, but we aren't preventing the death of the vehicle. We just ejected the driver instead.
}

defaultproperties
{
	BigSeconds=120
	AbilityName="Vehicle Ejector Button"
	Description="You will be automatically ejected from a destroyed vehicle. Depending upon your level of this skill, it will activate once every 120, 60, 40, or 30 seconds.|Cost (per level): 5,10,15,20"
	MaxLevel=4
	StartingCost=5
	CostAddPerLevel=5
}