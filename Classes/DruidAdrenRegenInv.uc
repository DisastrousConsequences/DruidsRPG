class DruidAdrenRegenInv extends Inventory
	config(UT2004RPG);

var config int RegenAmount;
var bool bAlwaysGive;
var int WaveNum;
var int WaveBonus;
var config float ReplenishAdrenPercent;

function bool HasActiveArtifact()
{
	return class'ActiveArtifactInv'.static.hasActiveArtifact(Instigator);
}

function Timer()
{
	local Controller C;

	if (Instigator == None || Instigator.Health <= 0)
	{
		Destroy();
		return;
	}

	C = Instigator.Controller;
	if (C == None && Instigator.DrivenVehicle != None)
		 C = Instigator.DrivenVehicle.Controller;

	if (C == None)
		return;

	if ( !Instigator.InCurrentCombo() && (bAlwaysGive || !HasActiveArtifact()))
	{
		C.AwardAdrenaline(RegenAmount);
	}

	// now check to see if in invasion and between waves. In which case get end of wave bonus.
	if (Level.Game.IsA('Invasion') && Invasion(Level.Game).WaveNum != WaveNum)
	{
	    WaveNum = Invasion(Level.Game).WaveNum;
	    C.AwardAdrenaline(WaveBonus * ReplenishAdrenPercent * C.AdrenalineMax);
	}
}

defaultproperties
{
	RemoteRole=ROLE_DumbProxy
	RegenAmount=1
	bAlwaysGive=false
	WaveNum=-1
	ReplenishAdrenPercent=0.1
}