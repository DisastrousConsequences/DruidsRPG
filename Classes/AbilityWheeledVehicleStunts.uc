class AbilityWheeledVehicleStunts extends CostRPGAbility
	abstract
	config(UT2004RPG);

var config float MaxForce;
var config float ForceLevelMultiplier;
var config float MaxSpin;
var config float SpinLevelMultiplier;
var config float JumpChargeTime;
var config float ChargeLevelMultiplier; //really a divisor, since it will be fractional

/* Modify the owning player's current vehicle. Called by MutUT2004RPG.DriverEnteredVehicle() serverside
 * and RPGStatsInv.ClientEnteredVehicle() clientside.
 */
static simulated function ModifyVehicle(Vehicle V, int AbilityLevel)
{
	local ONSWheeledCraft wheels;
	local VehicleStuntsInv inv;
	
	if(V.Level.NetMode == NM_Client)
		return; //none of this on the client

	wheels = ONSWheeledCraft(V);
	if (wheels == None)
		return;
	
	inv = VehicleStuntsInv(wheels.FindInventoryType(class'VehicleStuntsInv'));
	if(Inv != None)
	{
		//woah
		UnModifyVehicle(V, AbilityLevel);
	}
	
	inv = wheels.spawn(class'VehicleStuntsInv', wheels,,, rot(0,0,0));
	if(inv == None)
		return; //shouldn't happen, but this is a checkertrap in case it does.
	inv.giveTo(wheels);
	
	inv.bAllowAirControl = wheels.bAllowAirControl;
	inv.bAllowChargingJump = wheels.bAllowChargingJump;
	inv.bSpecialHUD = wheels.bSpecialHUD;
	inv.MaxJumpForce = wheels.MaxJumpForce;
	inv.MaxJumpSpin = wheels.MaxJumpSpin;
	inv.JumpChargeTime = wheels.JumpChargeTime;
	inv.bHasHandbrake = wheels.bHasHandbrake;

	wheels.bAllowAirControl = true;
	wheels.bAllowChargingJump = true;
	wheels.bSpecialHUD = true;
	wheels.MaxJumpForce = default.MaxForce * ((float(AbilityLevel - 1) * default.ForceLevelMultiplier) + 1.000000);
	wheels.MaxJumpSpin = default.MaxSpin * ((float(AbilityLevel - 1) * default.SpinLevelMultiplier) + 1.000000);
	wheels.JumpChargeTime = default.JumpChargeTime * ((float(AbilityLevel - 1) * default.SpinLevelMultiplier) + 1.000000);
	wheels.bHasHandbrake = false;
}

/* Remove any modifications to this vehicle, because the player is no longer driving it.
 */
static simulated function UnModifyVehicle(Vehicle V, int AbilityLevel)
{
	local ONSWheeledCraft wheels;
	local VehicleStuntsInv inv;

	if(V.Level.NetMode == NM_Client)
		return; //none of this on the client

	wheels = ONSWheeledCraft(V);
	if (wheels == None)
		return;

	inv = VehicleStuntsInv(wheels.FindInventoryType(class'VehicleStuntsInv'));
	if(inv == None)
		return; //nothing to unmodify.
		
	wheels.bAllowAirControl = inv.bAllowAirControl;
	wheels.bAllowChargingJump = inv.bAllowChargingJump;
	wheels.bSpecialHUD = inv.bSpecialHUD;
	wheels.MaxJumpForce = inv.MaxJumpForce;
	wheels.MaxJumpSpin = inv.MaxJumpSpin;
	wheels.JumpChargeTime = inv.JumpChargeTime;
	wheels.bHasHandbrake = inv.bHasHandbrake;

	wheels.deleteInventory(inv);
	inv.destroy();
}

defaultproperties
{
	MaxForce=200000.000000
	ForceLevelMultiplier=1.500000
	MaxSpin=80.000000
	SpinLevelMultiplier=1.250000
	JumpChargeTime=1.000000
	ChargeLevelMultiplier=0.800000
	AbilityName="Stunt Vehicles"
	Description="With this skill, you can make wheeled vehicles jump.|Hold down the crouch key to charge up and then release to jump.|This ability also grants control of wheeled vehicles in mid-air.|Additional levels provide more spin, momentum, and less charge time.|Cost (per level): 5,10,15"
	StartingCost=5
	CostAddPerLevel=5
	MaxLevel=3
}