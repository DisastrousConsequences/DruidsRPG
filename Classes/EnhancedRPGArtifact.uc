class EnhancedRPGArtifact extends RPGArtifact
		abstract;

var float AdrenalineUsage;				// set to 0.5 means only uses half adrenaline
var config float TimeBetweenUses;		// the time required between uses of this artifact
var float LastUsedTime;					// time this artifact was last used
var float RecoveryTime;					// time this artifact can be used again. Clientside only.

replication
{
	reliable if (Role == ROLE_Authority)
		SetClientRecoveryTime;
}

function SetRecoveryTime(float RecoveryPeriod)
{
	LastUsedTime = Level.TimeSeconds;
	SetClientRecoveryTime(RecoveryPeriod);
}

simulated function SetClientRecoveryTime(int RecoveryPeriod)
{
	// set the recoverytime on the client side for the hud display
	if(Level.NetMode != NM_DedicatedServer)
	{
		RecoveryTime = Level.TimeSeconds + RecoveryPeriod;
	}
}

simulated function int GetRecoveryTime()
{
	if (RecoveryTime > 0 && RecoveryTime > Level.TimeSeconds)
		return max(int(RecoveryTime - Level.TimeSeconds),1);
	else
		return 0;
}

function EnhanceArtifact(float Adusage)
{
	AdrenalineUsage = AdUsage;
}

simulated function Tick(float deltaTime)
{
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
}

defaultproperties
{
     AdrenalineUsage=1.0
     TimeBetweenUses=0.0
}
