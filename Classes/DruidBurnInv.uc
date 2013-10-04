class DruidBurnInv extends Inventory
	config(UT2004RPG);

var RPGRules RPGRules;

var Controller InstigatorController;
var Pawn PawnOwner;
var float BurnFraction;        // fraction taken off per second
var Material BurnOverlay;

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		PawnOwner;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Instigator != None)
		InstigatorController = Instigator.Controller;

	SetTimer(0.5, true);
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	local Pawn OldInstigator;

	if (InstigatorController == None)
		InstigatorController = Other.DelayedDamageInstigatorController;

	//want Instigator to be the one that caused the poison
	OldInstigator = Instigator;
	Super.GiveTo(Other);
	PawnOwner = Other;
	Instigator = OldInstigator;
}

simulated function Timer()
{
	local int BurnDamage;

	if (Role == ROLE_Authority)
	{
		if (Owner == None)
		{
			Destroy();
			return;
		}

		if (PawnOwner == None || PawnOwner.Health <= 0)
		    return;     // cant do anything

		if (Instigator == None && InstigatorController != None)
			Instigator = InstigatorController.Pawn;

		BurnDamage = max(1,PawnOwner.HealthMax * BurnFraction * 0.5);      // since twice a second only do half the damage, minimum 1

		if(BurnDamage > 0)
		{
			if(PawnOwner.Controller != None && PawnOwner.Controller.bGodMode == False
				&& InvulnerabilityInv(PawnOwner.FindInventoryType(class'InvulnerabilityInv')) == None)
			{
		    	if (PawnOwner.Health <= BurnDamage)
		        	BurnDamage = PawnOwner.Health -1;
				PawnOwner.Health -= BurnDamage;
				if(Instigator != None && Instigator != PawnOwner.Instigator) //exp only for harming others.
				{
				    if (RPGRules != None)
						RPGRules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), PawnOwner, BurnDamage);
					// and add the damage as healable
					class'DruidPoisonInv'.static.AddHealableDamage(BurnDamage, PawnOwner);
				}
			}
		}
	}

	PawnOwner.SetOverlayMaterial(BurnOverlay, 1.0, false);
	if (Level.NetMode != NM_DedicatedServer && PawnOwner != None)
	{
		//PawnOwner.Spawn(class'HitFlame',PawnOwner);
		if (PawnOwner.IsLocallyControlled() && PlayerController(PawnOwner.Controller) != None)
			PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'BurnConditionMessage', 0);
	}
	//dont call super. Bad things will happen.
}

defaultproperties
{
	BurnFraction=0.20
	bOnlyRelevantToOwner=False
	BurnOverlay=Texture'EmitterTextures.MultiFrame.fire3'
}