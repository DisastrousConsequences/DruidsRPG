class DruidArmorRegenInv extends Inventory;

var int RegenAmount;

function PostBeginPlay()
{
	SetTimer(1.0, true);

	Super.PostBeginPlay();
}

function Timer()
{
	local Vehicle v;

	if (Instigator == None || Instigator.Health <= 0)
	{
		Destroy();
		return;
	}

	if (Instigator.DrivenVehicle == None)
		return;		// only works if driving a vehicle
		
	v = Instigator.DrivenVehicle;

	if (ONSWeaponPawn(v) != None && ONSWeaponPawn(v).VehicleBase != None && !ONSWeaponPawn(v).bHasOwnHealth)
		 v = ONSWeaponPawn(v).VehicleBase;

	v.GiveHealth(RegenAmount, v.HealthMax);

}

defaultproperties
{
}
