class DruidShieldRegenInv extends Inventory;

// variables set by the ability
var int NoDamageDelay, MaxShieldRegen;
var float ShieldRegenRate;

// local variables
var int lastHealth, lastShield, ElapsedNoDamage;
var float ShieldFraction;		// because increments may be fractional, and Shield is integer

function PostBeginPlay()
{
	SetTimer(1.0, true);
	ShieldFraction = 0.0;
	ElapsedNoDamage = 0;

	Super.PostBeginPlay();
}

function Timer()
{
	local int NewHealth, NewShield;
	local int AmountToAdd, RegenPossible;

	if (Instigator == None || Instigator.Health <= 0)
	{
		Destroy();
		return;
	}

	NewHealth = Instigator.Health;
	NewShield = Instigator.GetShieldStrength();
	// ok, let's check to see if it is time to start giving the shield back
	if (lastHealth > NewHealth || lastShield > NewShield)
	{
		// took damage, so reset regen timer. 
		ElapsedNoDamage = 0;
	}
	else
	{
		// no damage, so one more peaceful second
		ElapsedNoDamage++;
	}
	if (MaxShieldRegen == 150 && xPawn(Instigator) != None)	// skill maxed out
		RegenPossible = xPawn(Instigator).ShieldStrengthMax-NewShield;
	else	
		RegenPossible = MaxShieldRegen-NewShield;
	if (RegenPossible > 0 && (ElapsedNoDamage > NoDamageDelay))
	{
		// regen the shield
		ShieldFraction += ShieldRegenRate;
		AmountToAdd = Int(ShieldFraction);
		ShieldFraction -= AmountToAdd;

		if (AmountToAdd >= 1)
		{
			// we have some to add
			if (AmountToAdd < RegenPossible)
			{
				Instigator.AddShieldStrength(AmountToAdd);
			}
			else
			{
				// we will fill it
				Instigator.AddShieldStrength(RegenPossible);
				ShieldFraction = 0.0;
			}
		}
	} 
	else
		ShieldFraction = 0.0;		// reset

	// now set save values for next loop
	lastHealth = NewHealth;
	lastShield = Instigator.GetShieldStrength();

}

defaultproperties
{
}
