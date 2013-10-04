class DruidArtifactSpider extends RPGArtifact;

var Emitter FlightTrail;
var localized string NotInVehicleMessage;
var int retry;

function BotConsider()
{
	return;		// not sure that bots can ever get any decent use out of electromagnet.
}

function Activate()
{
	if (Vehicle(Instigator) == None)
		Super.Activate();
	else if (Instigator != None)
		Instigator.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2)
		return Default.NotInVehicleMessage;

	return Super.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}

state Activated
{
	function BeginState()
	{
		if(Instigator.Physics != PHYS_Walking)
		{
			bActive = false;
			GotoState('');
		}
		else if (Instigator.Base == None)
		{
			bActive = false;
			GotoState('');
		}
		else if (Instigator.Base.IsA('BlockingVolume') && !Instigator.Base.bBlockZeroExtentTraces)
		{
			bActive = false;
			GotoState('');
		}
		else
		{
			if (PlayerController(Instigator.Controller) != None)
				Instigator.Controller.GotoState('PlayerSpidering');
			else
				Instigator.SetPhysics(PHYS_Spider);
			bActive = true;
			FlightTrail = Instigator.spawn(class'FlightEffect', Instigator);
			retry = 0;
			SetTimer(0.15, true);
		}
	}

	function Timer()
	{
		if (Instigator.Physics != PHYS_Spider)
		{
			retry++;
			if(retry > 2)
			{
				bActive = false;
				GotoState('');
			}
		}
		else if (Instigator.Base != None )
		{
			if (Instigator.Base.IsA('BlockingVolume') && !Instigator.Base.bBlockZeroExtentTraces)
			{
				retry++;
				if(retry > 2)
				{
					bActive = false;
					GotoState('');
				}
			}
		}
		else
			retry = 0;
	}

	function EndState()
	{
		SetTimer(0, true);
		retry = 0;
		if (Instigator != None && Instigator.Controller != None && Instigator.DrivenVehicle == None)
		{
			Instigator.SetPhysics(PHYS_Falling);
			if (PlayerController(Instigator.Controller) != None)
				Instigator.Controller.GotoState(Instigator.LandMovementState);
		}
		bActive = false;
		if (FlightTrail != None)
			FlightTrail.Kill();
	}
}

defaultproperties
{
     NotInVehicleMessage="Sorry, vehicles can't use an Electro-Magnet around."
     CostPerSec=2
     PickupClass=Class'DruidSpiderPickup'
     IconMaterial=Texture'XGameShaders.BRShaders.BRBall'
     ItemName="Electro-Magnet"
}
