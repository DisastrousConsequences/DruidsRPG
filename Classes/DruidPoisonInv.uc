class DruidPoisonInv extends PoisonInv
	config(UT2004RPG);

var RPGRules RPGRules;

var config float BasePercentage;
var config float Curve;
var config float AdrenLost;

static function AddHealableDamage(int Damage, Pawn Injured)
{
	Local HealableDamageInv Inv;

	if(Injured == None || Injured.Controller == None || Injured.Health <= 0 || Damage < 1)
		return; // Not EXP Healable

	if(Injured.isA('Monster') && !Injured.Controller.isA('FriendlyMonsterController'))
		return; 	// No tracking for not friendly monsters.

	Inv = HealableDamageInv(Injured.FindInventoryType(class'HealableDamageInv'));
	if(Inv == None)
	{
		Inv = Injured.spawn(class'HealableDamageInv');
		Inv.giveTo(Injured);
	}

	if(Inv == None)
	    return;

	Inv.Damage += Damage;

	if(Inv.Damage > Injured.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus)
		Inv.Damage = Injured.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus;
}

simulated function Timer()
{
	local int PoisonDamage;

	if (Role == ROLE_Authority)
	{
		if (Owner == None)
		{
			Destroy();
			return;
		}

		if (PawnOwner == None)
		    return;     // cant do anything

		if (Instigator == None && InstigatorController != None)
			Instigator = InstigatorController.Pawn;

		PoisonDamage = 
			int
			(
				float
				(
					PawnOwner.Health
				) * 
				(
					Curve **
					(
						float
						(
							Modifier-1
						)
					)
					*BasePercentage
				)
			);

		if(PoisonDamage > 0)
		{
			if(PawnOwner.Controller != None && PawnOwner.Controller.bGodMode == False
				&& InvulnerabilityInv(PawnOwner.FindInventoryType(class'InvulnerabilityInv')) == None)
			{
				if (PawnOwner.Controller.Adrenaline > 0)
					PawnOwner.Controller.Adrenaline -= (Modifier*AdrenLost);
				if (PawnOwner.Controller.Adrenaline < 0)
					PawnOwner.Controller.Adrenaline = 0;
					
		    	if (PawnOwner.Health <= PoisonDamage)
		        	PoisonDamage = PawnOwner.Health -1;
				PawnOwner.Health -= PoisonDamage;
				
				if(Instigator != None && Instigator != PawnOwner.Instigator) //exp only for harming others.
				{
				    if (RPGRules != None)
						RPGRules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), PawnOwner, PoisonDamage);
					// and add the damage as healable
					class'DruidPoisonInv'.static.AddHealableDamage(PoisonDamage, PawnOwner);
				}
			}
		}
	}

	if (Level.NetMode != NM_DedicatedServer && PawnOwner != None)
	{
		PawnOwner.Spawn(class'GoopSmoke');
		if (PawnOwner.IsLocallyControlled() && PlayerController(PawnOwner.Controller) != None)
			PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'RPGDamageConditionMessage', 0);
	}
	//dont call super. Bad things will happen.
}

defaultproperties
{
	Curve=1.300000
	BasePercentage=0.05;
    	bOnlyRelevantToOwner=False
	AdrenLost=2.0
}