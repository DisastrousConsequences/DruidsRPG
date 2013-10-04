class Summonifact extends RPGArtifact
	abstract
	config(UT2004RPG);

var() Sound BrokenSound;
var class<Pawn> SummonItem;
var string FriendlyName;
var int Points;
var int StartHealth;
var int NormalHealth;
var int RecoveryPeriod;

replication
{
	reliable if (Role == ROLE_Authority)
		Points, FriendlyName, RecoveryPeriod, NormalHealth;
}

static function bool ArtifactIsAllowed(GameInfo Game)
{
	return true;
}

function setup(String configName, class<Pawn> configItem, int configPoints, int configInitialHealth, int configNormalHealth, int configRecoveryPeriod)
{
	SummonItem = configItem;
	FriendlyName = configName;
	Points = configPoints;
	StartHealth = configInitialHealth;
	NormalHealth = configNormalHealth;
	RecoveryPeriod = configRecoveryPeriod;
}

function BotConsider()
{
	if (bActive)
		return;

	if ( Instigator.Health + Instigator.ShieldStrength > 130 && Instigator.Controller.Enemy != None		// ensures monsters go here
	     && NoArtifactsActive())
		Activate();
	return;		
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	disable('Tick'); //this artifact doesn't need ticks. It gets activated externally
}

// overridable functions for the different things that can be summoned
function bool SpawnIt(TranslocatorBeacon Beacon,Pawn P,EngineerPointsInv epi)
{
	return false;
}

function bool CanAirSummon()
{
	return false;
}

function bool isAvailable(LevelInfo level)
{
	return true;
}

function Activate()
{		
	local EngineerPointsInv Inv;
	local TranslocatorBeacon tb,TempBeacon;
	Local TransLauncher tr;

	if (Instigator == None)
		return;
	Inv = class'AbilityLoadedEngineer'.static.GetEngInv(Instigator);
	if(Inv == None)
	{
		bActive = false;
		GotoState('');
		return; //get em next pass I guess?
	}

	if (Instigator.Weapon == None || (TransLauncher(Instigator.Weapon) == None && !(instr(caps(Instigator.Weapon.ItemName), "TRANSLOCATOR") > -1 )))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
		bActive = false;
		GotoState('');
		return; //get em next pass I guess?
	}
	if (TransLauncher(Instigator.Weapon) != None)
	{
		tr = TransLauncher(Instigator.Weapon);
		tb = tr.TransBeacon;
	}
	else
	{
		// prob UT2003 translocator. Cant get at the transbeacon through the weapon. Lets do a global search
		foreach DynamicActors( class 'TranslocatorBeacon', TempBeacon )
		{
			if (TempBeacon.InstigatorController == Instigator.Controller && TempBeacon.InstigatorController != None)
			{
				tb = TempBeacon;
			} 
		}
	}
	if (tb == None)		// no beacon out, so can't spawn
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
		bActive = false;
		GotoState('');
		return; //get em next pass I guess?
	}
	if (Inv.GetRecoveryTime() >0)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 5000, None, None, Class);
		bActive = false;
		GotoState('');
		return; //get em next pass I guess?
	}

	// let try to summon it. If it works, bring back the beacon.
	if (SpawnIt(tb, Instigator, Inv))
	{
		// successfully summoned something
		if (tr != None)
		{
			tr.TransBeacon.Destroy();	
			tr.TransBeacon = None;
		}
		else
		{
			// prob UT2003 trans, but cant reset directly. Lets just destroy the object
			tb.Destroy();
		}
		Inv.SetRecoveryTime(RecoveryPeriod);
	}

}

function bool CheckSpace(vector SpawnLocation, int HorizontalSpaceReqd, int VerticalSpaceReqd)
{
	// check to see that we have the required space around the trans in at least two adjactent directions, and up
	if (!FastTrace(SpawnLocation, SpawnLocation + (vect(0,0,1)*VerticalSpaceReqd)))
		return false;

	if (!FastTrace(SpawnLocation, SpawnLocation + (vect(0,1,0)*HorizontalSpaceReqd)) 
		&& !FastTrace(SpawnLocation, SpawnLocation - (vect(0,1,0)*HorizontalSpaceReqd) ))
		return false;

	if (!FastTrace(SpawnLocation, SpawnLocation + (vect(1,0,0)*HorizontalSpaceReqd)) 
		&& !FastTrace(SpawnLocation, SpawnLocation - (vect(1,0,0)*HorizontalSpaceReqd) ))
		return false;

	// should be room
	return true;
}

function SetStartHealth(Pawn NewItem)
{
	if (StartHealth > 0 && NewItem != None)
	{
		if ( TeamGame(Level.Game) != None && Bot(Instigator.Controller) == None)
		{
			NewItem.Health = StartHealth;
			NewItem.HealthMax = NormalHealth;
		}
		else
		{	// if not teamgame, then link will not heal, so start at full health. Also bots will not heal, so set bot constructs to full health
			NewItem.Health = NormalHealth;
			NewItem.HealthMax = NormalHealth;
		}
	}
	NewItem.SuperHealthMax = NewItem.HealthMax;	// set to non-199 so can pickup later
}

function ApplyStatsToConstruction(Pawn NewItem,Pawn Other)
{
	Local RPGStatsInv StatsInv;
	local vehicle V;
	Local Inventory Inv;
	Local int x;
	local Controller C;

	if (NewItem == None)
		return;

	V = Vehicle(NewItem);
	if (V != None)
	{
		// lets set the eject to be false. If you have the correct skill later, it can reset
		V.bEjectDriver = False;
	}

	if (NewItem.SuperHealthMax == 199)
		NewItem.SuperHealthMax = 200;	// to show it is a summoned item

	for (Inv = Other.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		StatsInv = RPGStatsInv(Inv);
		if (StatsInv != None)
			break;
	}
	if (StatsInv == None) //fallback, should never happen
		StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None)
	{
		for (x = 0; x < StatsInv.Data.Abilities.length; x++)
		{
			if(ClassIsChildOf(StatsInv.Data.Abilities[x], class'EngineerAbility'))
				class<EngineerAbility>(StatsInv.Data.Abilities[x]).static.ModifyConstruction(NewItem, StatsInv.Data.AbilityLevels[x]);
		}

		if (V != None )
			C = V.Controller;
		//else if (DruidEnergyWall(NewItem) != None)
		//	C = DruidEnergyWall(NewItem).Controller;
		if (C != None)
		{
			if (C.Inventory == None)
				C.Inventory = StatsInv;
			else
			{
				for (Inv = C.Inventory; Inv.Inventory != None; Inv = Inv.Inventory)
					{}
				Inv.Inventory = StatsInv;
			}
		}
	}
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2000)
		return "You need to be using the Translocator for this artifact to operate";
	if (Switch == 3000)
		return "You need to have the Translocator beacon deployed to use this artifact";
	if (Switch == 4000)
		return "There is nothing to spawn the item on";
	if (Switch == 5000)
		return "You cannot spawn another item yet. Please wait.";
	if (Switch == 6000)
		return "There is not enough room around the spawn location.";
	return default.Points@"points are required to use this artifact";
}

exec function TossArtifact()
{
	//do nothing. This artifact cant be thrown
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

defaultproperties
{
	MinActivationTime=0.000001
	CostPerSec=1
	BrokenSound=Sound'PlayerSounds.NewGibs.RobotCrunch3'
	ItemName="Summoning Artifact"
	IconMaterial=Texture'UTRPGTextures.Icons.SummoningCharmIcon'
	RecoveryPeriod=60
}
