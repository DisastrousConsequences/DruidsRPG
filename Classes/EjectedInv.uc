class EjectedInv extends Inventory;

/* commented out until tested
function PostBeginPlay()
{
	SetTimer(5.0, true);
	Instigator.ReducedDamageType = class'DamTypeONSVehicleExplosion';
	Super.PostBeginPlay();
}

function Timer()
{
	Instigator.ReducedDamageType = None;
}
*/


defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     bOnlyRelevantToOwner=true
     bAlwaysRelevant=false
     bReplicateInstigator=false
}