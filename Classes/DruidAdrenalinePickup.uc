// DruidAdrenalinePickup
// version of AdrenalinePickup that can be picked up whilst falling

class DruidAdrenalinePickup extends AdrenalinePickup;

function InitDroppedPickupFor(Inventory Inv)
{
	SetPhysics(PHYS_Falling);
	//GotoState('FallingPickup');
	GotoState('Pickup','Begin');
	Inventory = Inv;
	bAlwaysRelevant = false;
	bOnlyReplicateHidden = false;
	bUpdateSimulatedPosition = true;
	bDropped = true;
	LifeSpan = 16;
	bIgnoreEncroachers = false; // handles case of dropping stuff on lifts etc
	NetUpdateFrequency = 8;
}

defaultproperties
{
}
