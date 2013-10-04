class VehicleStuntsInv extends Inventory;

var bool bAllowAirControl;
var bool bAllowChargingJump;
var bool bSpecialHUD;
var float MaxJumpForce;
var float MaxJumpSpin;
var float JumpChargeTime;
var bool bHasHandbrake;

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     bOnlyRelevantToOwner=true
     bAlwaysRelevant=false
     bReplicateInstigator=false
}