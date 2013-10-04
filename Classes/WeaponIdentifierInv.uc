class WeaponIdentifierInv extends Inventory;

var RPGWeapon Weapon;

replication
{
	reliable if (Role == ROLE_Authority)
		Weapon;
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	if(Weapon != None)
	{
		Weapon.Identify();
		Destroy();
	}
	else
	{
		setTimer(0.5, true);
	}
}

simulated function timer()
{
	if(Weapon != None)
	{
		Weapon.Identify();
		Destroy();
	}
}

defaultproperties
{
	Lifespan=5.00000
	bOnlyRelevantToOwner=True
	RemoteRole=ROLE_SimulatedProxy
}