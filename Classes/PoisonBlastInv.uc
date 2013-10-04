class PoisonBlastInv extends PoisonInv;

var RPGRules RPGRules;
var float DrainAmount;
var config float AdrenLost;

simulated function Timer()
{
	local int HealthDrained;

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

		HealthDrained = int((PawnOwner.Health * DrainAmount)/100);
		if(HealthDrained > 1)
		{
			if(PawnOwner.Controller != None && PawnOwner.Controller.bGodMode == False
				&& InvulnerabilityInv(PawnOwner.FindInventoryType(class'InvulnerabilityInv')) == None)
		    {
			    // going to do the damage
				if (PawnOwner.Controller.Adrenaline > 0)
					PawnOwner.Controller.Adrenaline -= (Modifier*AdrenLost);
				if (PawnOwner.Controller.Adrenaline < 0)
					PawnOwner.Controller.Adrenaline = 0;
					
				PawnOwner.Health -= HealthDrained;
				
				if(Instigator != None && Instigator != PawnOwner.Instigator) //exp only for harming others.
				{
				    if (RPGRules != None)
						RPGRules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), PawnOwner, HealthDrained);
					class'DruidPoisonInv'.static.AddHealableDamage(HealthDrained, PawnOwner);
				}
			}
		}
	}

	if (Level.NetMode != NM_DedicatedServer && PawnOwner != None)
	{
		//PawnOwner.Spawn(class'GoopSmoke');
		if (PawnOwner.IsLocallyControlled() && PlayerController(PawnOwner.Controller) != None)
			PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'PoisonBlastConditionMessage', 0);
	}
	//dont call super. Bad things will happen.
}

defaultproperties
{
     DrainAmount=10.000000
     AdrenLost=2.0
}
