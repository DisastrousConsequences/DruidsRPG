/*TODO to close out alpha:
Ensure 3x/2x DamageScaling is working correctly (not yet tested)
Check level 2 combo functioning
Check level 3
Add sanity check to cost to ensure players buying level 3 have a class

KNOWN MAJOR BUGS:
3x damage not being properly deactivated? Something with self-inflicted wounds killing almost instantly after a LB
Occasionally, on a map change, the LB point values pick up something bizarre and stay there until game exit and restart

TODO:
Add a PreventDeath to activate Limit Break on death once earned
Deactivate ALL artifacts upon break*/

class LimitBreakInv extends Inventory
		config(UT2004RPG);

var RPGStatsInv StatsInv;
var string PlayerClass;
var string ClassCombo;

var float LimitPoints;

var config int LimitPointsForLimitBreak;
var config float LimitBreakHealthPercentMax;

var config int LimitStage1Seconds;
var config int LimitStage2Seconds;

var config int LimitStage2HealthBonus;
var config int LimitStage2ComboLength;

var config float LimitPointsXPFactor; //% of points to shave off for higher XP to next level
var config float LimitPointsLevelFactor; //same, but for higher levels
var config float LimitPointsHealthFactor; //same, but for higher health

var bool bLimitBreak;

var int AbilityLevel;

var int OldLightBrightness;
var int OldLightHue;
var int OldLightSaturation;
var int OldLightRadius;

var float OldDamageScaling;

var Combo myCombo;

function PostBeginPlay()
{
	local RPGPlayerDataObject DataObj;
	local int x;
	DataObj	= RPGPlayerDataObject(FindObject("Package." $ Instigator.PlayerReplicationInfo.PlayerName, class'RPGPlayerDataObject')); //Mysterial is crazy
	StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));

	for (x = 0; x < DataObj.Abilities.length; x++)
	{
		if (DataObj.Abilities[x] == class'ClassWeaponsMaster')
		{
			PlayerClass = "ClassWeaponsMaster";
			ClassCombo = "BotsCombos.BotComboBerserk";
		}
		if (DataObj.Abilities[x] == class'ClassAdrenalineMaster')
		{
			PlayerClass = "ClassAdrenalineMaster";
			ClassCombo = "XGame.ComboSpeed";
		}
		if (DataObj.Abilities[x] == class'ClassMonsterMaster')
		{
			PlayerClass = "ClassMonsterMaster";
			ClassCombo = "BotsCombos.BotComboDefensive";
		}
		if (DataObj.Abilities[x] == class'ClassEngineer')
		{
			PlayerClass = "ClassEngineer";
			ClassCombo = "BotsCombos.BotComboDefensive";
		}
	}

	Super.PostBeginPlay();
}

function AddBreakPoints(float Points)
{
	local int XPForLevel;
	local int PlayerLevel;
	local float CurrentHealthFactor;

	//no points while in limit break or while invul
	if (bLimitBreak || Instigator.Controller.bGodMode == true)
	{
		return;
	}

	XPForLevel = StatsInv.Data.NeededExp;
	PlayerLevel = StatsInv.Data.Level;
	CurrentHealthFactor = 1 - (Instigator.Health / Instigator.HealthMax);
	if (CurrentHealthFactor < 0)
	{
		CurrentHealthFactor = 0;
	}

	if (LimitPointsXPFactor != 0)
	{
		Points *= LimitPointsXPFactor * XPForLevel;
	}
	if (LimitPointsLevelFactor != 0)
	{
		Points *= LimitPointsLevelFactor * PlayerLevel;
	}
	if (LimitPointsHealthFactor != 0)
	{
		Points *= LimitPointsHealthFactor * CurrentHealthFactor;
	}

	if (LimitPoints + Points < LimitPointsForLimitBreak)
	{
		LimitPoints += Points;
	}
	else
	{
		LimitPoints = LimitPointsForLimitBreak;
	}
}

function Tick(float deltaTime)
{
	if (LimitPoints == LimitPointsForLimitBreak && (Instigator.Health / Instigator.HealthMax) < LimitBreakHealthPercentMax)
	{
		GotoState('PowerUp');
	}
}

state PowerUp
{
	Begin:
		bLimitBreak = true;

		//deactivate all active artifacts

		SetGoldLight();

		Instigator.Controller.bGodMode = true;

		OldDamageScaling = Instigator.DamageScaling;
		Instigator.DamageScaling *= 1.5;
		Instigator.EnableUDamage(LimitStage1Seconds);
		if (AbilityLevel > 1)
		{
			Instigator.EnableUDamage(LimitStage1Seconds + LimitStage2Seconds);
		}

		sleep(LimitStage1Seconds);
		if (AbilityLevel == 1)
		{
			GoToState('PowerDown');
			//Stop;
		}
		GoToState('LimitBreak');
}

state LimitBreak
{
	Begin:
		Instigator.Health += LimitStage2HealthBonus;

		Instigator.DamageScaling = OldDamageScaling;

		Instigator.Controller.bGodMode = false;

		xPawn(Instigator).DoComboName(ClassCombo);
		myCombo = xPawn(Instigator).CurrentCombo;
		myCombo.AdrenalineCost = 0;
		//length should be 30 sec default?
		myCombo.Duration = LimitStage2ComboLength;

		sleep(LimitStage2Seconds);
		if (AbilityLevel == 2)
		{
			GoToState('PowerDown');
			//Stop;
		}
		GoToState('ClassLimit');
}

state ClassLimit
{
	Begin:
		if (PlayerClass == "ClassWeaponsMaster")
		{
			//max ammo
			spawn(class'GhostUltimaCharger', Instigator.Controller).ChargeTime = 0.1;
		}
		//class specific stuff - single actions, no timer
		//	A: max adrenaline + ultima
		//	W: max ammo + ultima
		//	M: full heal to medic max + healing blast
		//	E: max shield + shield healing blast
		GoToState('PowerDown');
}

state PowerDown
{
	Begin:
		Instigator.Controller.bGodMode = false;
		Instigator.DamageScaling = OldDamageScaling;
		Instigator.DisableUDamage();

		LimitPoints = 0;
		RemoveGoldLight();

		bLimitBreak = false;

		GoToState('Idle');
}

auto state Idle
{
	Begin:
		//idle!
}

function SetGoldLight()
{
	OldLightBrightness = Instigator.LightBrightness;
	OldLightHue = Instigator.LightHue;
	OldLightSaturation = Instigator.LightSaturation;
	OldLightRadius = Instigator.LightRadius;

	Instigator.LightBrightness = 255;
	Instigator.LightHue = 30;
	Instigator.LightSaturation = 0;
	Instigator.LightRadius = Instigator.CollisionRadius;
}

function RemoveGoldLight()
{
	Instigator.LightBrightness = OldLightBrightness;
	Instigator.LightHue = OldLightHue;
	Instigator.LightSaturation = OldLightSaturation;
	Instigator.LightRadius = OldLightRadius;
}

defaultproperties
{
	LimitPointsForLimitBreak = 1000; ///1000 for now
	LimitBreakHealthPercentMax = .25; //25% for now

	LimitStage1Seconds = 5;
	LimitStage2Seconds = 15;

	LimitStage2HealthBonus = 100;
	LimitStage2ComboLength = 15;

	//0 to disable
	LimitPointsXPFactor = .00007; //.00007 = 70% off for 10k xp to level
	LimitPointsLevelFactor = 0.00; //.01 = 1% off for each level
	LimitPointsHealthFactor = 0.40; //.4 = when the player has full health or higher, shave off 40%; always decrease to near 0 as player approaches 0 health 
}