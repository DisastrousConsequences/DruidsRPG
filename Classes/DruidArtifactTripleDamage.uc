class DruidArtifactTripleDamage extends ArtifactTripleDamage
	config(UT2004RPG);

var config Array< class<RPGWeapon> > Invalid;

function BotConsider()
{
	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
	{
		Activate();
		return;
	}
		
	if (Instigator.Controller.Adrenaline < 30)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None && Instigator.Weapon != None && Instigator.Weapon.AIRating > 0.5
		  && Instigator.Controller.Enemy.Health > 70 && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.7 )
		Activate();
}

function Activate()
{
	if (class'DruidDoubleModifier'.static.HasDoubleModifierRunning(Instigator))
		return; // cant run doublemagicmodifier with triple

	if (class'DruidDoubleModifier'.static.HasRodRunning(Instigator))
		return; // cant run rod with triple

	if (!bActive && Instigator.HasUDamage())
		return;

	Super.Activate();
}

state Activated
{
	function Tick(float deltatime)
	{
		local int i;

		if (bActive)
		{
			if (Instigator != None && Instigator.Controller != None)	// not ghosting
			{
				Instigator.Controller.Adrenaline -= deltaTime * CostPerSec;
				if (Instigator.Controller.Adrenaline <= 0.0)
				{
					Instigator.Controller.Adrenaline = 0.0;
					UsedUp();
				}
			}
		}

		if(Instigator == None || RPGWeapon(Instigator.Weapon) == None )
		{
			return;
		}
		for(i = 0; i < Invalid.length; i++)
		{
			if(Instigator.Weapon.class == Invalid[i])
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 2906, None, None, Class);
				GotoState('');
				bActive=false;
				return;
			}
		}
	}
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2906)
		return "Unable to use Triple Damage on this magic weapon type.";
	else 
		return(super.getLocalString(switch, RelatedPRI_1, RelatedPRI_2));
}

defaultproperties
{
	Invalid[0]=class'RW_Rage'
	CostPerSec=10
	PickupClass=Class'DruidArtifactTripleDamagePickup'
}
