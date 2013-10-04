class MutRPGHUD extends Mutator;

// server side array for replicating xp etc
struct InitialXPValues
{
	Var String PlayerName;
	var RPGStatsInv StatsInv;
	var int InitialXP;
	var int AdditionalXP;
	var int Level;
	var int NeededXP;
	var int PlayerClass;
	var int XPGained;
	var string SubClass;
	var int GotHardCore;
	var PlayerReplicationInfo PlayerReplicationInfo;
	var int LogXPGained;
	var float StartTime;
	var int LastScore;
};
var Array<InitialXPValues> InitialXPs;

var bool bLoggedEndStats;
var bool bGameDone;


function ModifyPlayer(Pawn Other)
{
	Local ClientHudInv Inv;
	local ClientHudInv TempCInv;
	local String PlayerName;
	
	super.ModifyPlayer(Other);
	
	// now lets set up the xp score replication for players
	if (Other != None && Other.Controller != None && Other.Controller.isA('PlayerController') && Other.PlayerReplicationInfo != None) 
	{
		// lets see if we already have a ClientHudInv
		Inv = ClientHudInv(Other.FindInventoryType(class'ClientHudInv'));
		if (Inv == None)
		{
		    PlayerName = Other.PlayerReplicationInfo.PlayerName;
			if (Inv == None)
			{
				ForEach DynamicActors(class'ClientHudInv',TempCInv)
					if (TempCInv.OwnerName == PlayerName)
					{
						Inv = TempCInv;
					}
			}
			// no so lets allocate
			if (Inv == None)
			{
				Inv = Other.spawn(class'ClientHudInv', Other,,, rot(0,0,0));
				Inv.OwnerName = PlayerName;
			}
			//and give to user
			Inv.giveTo(Other);
		}	
	}
	if (Inv != None && Inv.HUDMut == None)
        Inv.HUDMut = self;	

	if (Other != None && Other.Controller != None && Other.Controller.isA('PlayerController'))
	{
	    if (Other.Level.Game.IsA('Invasion'))
	    {
			PlayerController(Other.Controller).ClientSetHUD(class'RPGHUDInvasion', class'RPGScoreboardInvasion');
		}
		else
		{
			PlayerController(Other.Controller).ClientSetHUD(class'RPGHUDInvasion', class<Scoreboard>(DynamicLoadObject(Level.Game.ScoreBoardType, class'Class')));
		}
	}

}

function PostBeginPlay()
{
	bLoggedEndStats = false;
	bGameDone = false;
	SetTimer(5, true);
	Super.PostBeginPlay();
}

function RPGStatsInv GetStatsInvFor(Controller C, optional bool bMustBeOwner)
{
	local Inventory Inv;

	for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
		if ( Inv.IsA('RPGStatsInv') && ( !bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn
						   || (Vehicle(C.Pawn) != None && Inv.Owner == Vehicle(C.Pawn).Driver) ) )
			return RPGStatsInv(Inv);

	//fallback - shouldn't happen
	if (C.Pawn != None)
	{
		Inv = C.Pawn.FindInventoryType(class'RPGStatsInv');
		if ( Inv != None && ( !bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn
				      || (Vehicle(C.Pawn) != None && Inv.Owner == Vehicle(C.Pawn).Driver) ) )
			return RPGStatsInv(Inv);
	}

	return None;
}

function SetupInitDetails(int x, Controller C)
{
	local int a;

	InitialXPs[x].StatsInv = GetStatsInvFor(C, false);
	if (InitialXPs[x].StatsInv != None && InitialXPs[x].StatsInv.DataObject != None)
	{
	  InitialXPs[x].InitialXP = InitialXPs[x].StatsInv.DataObject.Experience;
	  InitialXPs[x].Level = InitialXPs[x].StatsInv.DataObject.Level;
	  InitialXPs[x].NeededXP = InitialXPs[x].StatsInv.DataObject.NeededExp;
	  InitialXPs[x].AdditionalXP = 0;
	  InitialXPs[x].SubClass = "";
	  // ok now find the class, if any
	  InitialXPs[x].PlayerClass = 0;
	  InitialXPs[x].GotHardCore = 0;
	  InitialXPs[x].PlayerReplicationInfo = C.PlayerReplicationInfo;
	  for (a=0; a< InitialXPs[x].StatsInv.DataObject.Abilities.Length; a++)
	  {
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassWeaponsMaster')
	           InitialXPs[x].PlayerClass = 1;
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassAdrenalineMaster')
	           InitialXPs[x].PlayerClass = 2;
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassMonsterMaster')
	           InitialXPs[x].PlayerClass = 3;
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassEngineer')
	           InitialXPs[x].PlayerClass = 4;
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassGeneral')
	           InitialXPs[x].PlayerClass = 5;
	
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'SubClass')
	    		if (InitialXPs[x].StatsInv.DataObject.AbilityLevels[a] > 0 && InitialXPs[x].StatsInv.DataObject.AbilityLevels[a] < class'SubClass'.default.SubClasses.length)
	    			InitialXPs[x].SubClass = class'SubClass'.default.SubClasses[InitialXPs[x].StatsInv.DataObject.AbilityLevels[a]];
	       // and now check for HardCore
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'AbilityHardCore')
	    		InitialXPs[x].GotHardCore = 1;
	  }
	  // Log("***MutRPGHud Adding player:" $ x @ InitialXPs[x].PlayerName @ "class:" $ InitialXPs[x].PlayerClass @ "InitialXP:" $ InitialXPs[x].InitialXP @ "Level:" $ InitialXPs[x].Level @ "NeededXP:" $ InitialXPs[x].NeededXP);
	}
	else
	{
	  InitialXPs[x].InitialXP = -1;
	  InitialXPs[x].PlayerClass = -1;
	}

}

function CheckDetails(int x, Controller C)
{
	local int a;

	if (InitialXPs[x].StatsInv != None && InitialXPs[x].StatsInv.DataObject != None)
	{
	  InitialXPs[x].GotHardCore = 0;
	  for (a=0; a< InitialXPs[x].StatsInv.DataObject.Abilities.Length; a++)
	  {
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassWeaponsMaster')
	           InitialXPs[x].PlayerClass = 1;
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassAdrenalineMaster')
	           InitialXPs[x].PlayerClass = 2;
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassMonsterMaster')
	           InitialXPs[x].PlayerClass = 3;
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassEngineer')
	           InitialXPs[x].PlayerClass = 4;
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassGeneral')
	           InitialXPs[x].PlayerClass = 5;
	
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'SubClass')
	    		if (InitialXPs[x].StatsInv.DataObject.AbilityLevels[a] > 0 && InitialXPs[x].StatsInv.DataObject.AbilityLevels[a] < class'SubClass'.default.SubClasses.length)
	    			InitialXPs[x].SubClass = class'SubClass'.default.SubClasses[InitialXPs[x].StatsInv.DataObject.AbilityLevels[a]];
	       // and now check for HardCore
	       if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'AbilityHardCore')
	    		InitialXPs[x].GotHardCore = 1;
	  }
	}
	if (InitialXPs[x].PlayerReplicationInfo != None)
	{
	    InitialXPs[x].StartTime = InitialXPs[x].PlayerReplicationInfo.StartTime;
	    InitialXPs[x].LastScore = InitialXPs[x].PlayerReplicationInfo.Score;
	}
}

function Timer()
{
	local int x;
	Local Controller C;
	local string PlayerName;
	local RPGStatsInv StatsInv;
	local int iNumPlayers;

	if (Level.Game.bGameEnded && !bLoggedEndStats)
	{
		if (bGameDone)		// do not take the logs first time in. Give time for bonuses etc to be added. So skip one.
		{
		    if (Level.Game.IsA('Invasion'))
		    {
		        iNumPlayers = 0;
			    for (x=0; x < InitialXPs.Length; x++)
			    {
			        if (InitialXPs[x].XPGained != InitialXPs[x].LogXPGained)    // if already logged then has quit the game, so dont count
						iNumPlayers++;
			    }
		        if (Level.Game.GameReplicationInfo.Winner == TeamGame(Level.Game).Teams[0])
		    		Log(">>>> End game, Invasion Won, number of players:" $ iNumPlayers);
		        else
		    		Log(">>>> End game, Invasion lost, wave:" $ (Invasion(Level.Game).WaveNum+1) @ "number of players:" $ iNumPlayers);
			}
		    else
	    		Log(">>>> End game, type:" $ Level.Game);
	    	
		    for (x=0; x < InitialXPs.Length; x++)
		    {
				LogDetailsForPlayer(x, "End Map");
		    }
			bLoggedEndStats = true;
			return;
		}
		else
			bGameDone = true;
	}

	// create server side copy of data
	C = Level.ControllerList;
	while (C != None)
	{
		// loop round finding all players
		if ( C.Pawn != None && C.Pawn.PlayerReplicationInfo != None && Monster(C.Pawn) == None 			/* not PlayerController(C) != None as want to show scores for bots */ 
			  && DruidSentinelController(C) == None && DruidBaseSentinelController(C) == None && DruidDefenseSentinelController(C) == None && AutoGunController(C) == None
			  && DruidLightningSentinelController(C) == None && DruidEnergyWallController(C) == None)	// not a sentinel
		{
		    StatsInv = GetStatsInvFor(C, false);
		 	if (StatsInv != None && StatsInv.DataObject != None)
		 	    PlayerName = String(StatsInv.DataObject.Name);
			else
		    	PlayerName = C.Pawn.PlayerReplicationInfo.PlayerName;
		    x = 0;
		    while (x < InitialXPs.Length && InitialXPs[x].PlayerName != PlayerName)
		      x++;
		    if (x >= InitialXPs.Length)
		    {
		      //didnt find the player, so add
		       x = InitialXPs.Length;
		       InitialXPs.Length = x+1;
		       InitialXPs[x].PlayerName = PlayerName;
		       SetupInitDetails(x,C);
            }
            else
            {
            	// already got the player, but lets just check the class/subclass in case it has changed
		       CheckDetails(x,C);
            }
            // now calculate xp gained
            if (InitialXPs[x].InitialXP >= 0 && InitialXPs[x].StatsInv != None && InitialXPs[x].StatsInv.DataObject != None)
            {
                // first see if have levelled
                if (InitialXPs[x].InitialXP >= 0 && InitialXPs[x].Level < InitialXPs[x].StatsInv.DataObject.Level)
                {
                    // have levelled
                    InitialXPs[x].AdditionalXP += InitialXPs[x].NeededXP - InitialXPs[x].InitialXP;
                    InitialXPs[x].InitialXP = 0;
                    InitialXPs[x].Level = InitialXPs[x].StatsInv.DataObject.Level;
                    InitialXPs[x].NeededXP = InitialXPs[x].StatsInv.DataObject.NeededExp;
 	  				//Log("***MutRPGHud Player leveled:" $ x @ InitialXPs[x].PlayerName @ "Experience:" $ InitialXPs[x].StatsInv.DataObject.Experience @ "InitialXP:" $ InitialXPs[x].InitialXP @ "AdditionalXP:" $ InitialXPs[x].AdditionalXP @ "Level:" $ InitialXPs[x].Level @ "NeededXP:" $ InitialXPs[x].NeededXP);
               }
  				//Log("***MutRPGHud Player values:" $ x @ InitialXPs[x].PlayerName @ "Experience:" $ InitialXPs[x].StatsInv.DataObject.Experience @ "InitialXP:" $ InitialXPs[x].InitialXP @ "AdditionalXP:" $ InitialXPs[x].AdditionalXP @ "Level:" $ InitialXPs[x].Level @ "NeededXP:" $ InitialXPs[x].NeededXP);
                InitialXPs[x].XPGained = InitialXPs[x].StatsInv.DataObject.Experience + InitialXPs[x].AdditionalXP - InitialXPs[x].InitialXP;
            }
            else
            {
 	  			//Log("***MutRPGHud Player problem with xp:" $ x @ InitialXPs[x].PlayerName @ "InitialXP:" $ InitialXPs[x].InitialXP @ "AdditionalXP:" $ InitialXPs[x].AdditionalXP @ "Level:" $ InitialXPs[x].Level @ "NeededXP:" $ InitialXPs[x].NeededXP);
            	// not got all the information we need. Can we fix this?
            	if (InitialXPs[x].StatsInv == None)
            	{
           			// try to setup again, for next time around loop
		       		SetupInitDetails(x,C);
	          	}
	          	else
	          	{
	          		if (InitialXPs[x].StatsInv.DataObject != None)
						InitialXPs[x].InitialXP = InitialXPs[x].StatsInv.DataObject.Experience;
	          	}
                InitialXPs[x].XPGained = -1;
            }
		}
		C = C.NextController;
	}

}

function LogDetailsForPlayer(int x, string sLogReason)
{
	local string PClass, SClass;
	local int iDuration, iPPH, iScore;
	
    if (x >= InitialXPs.Length || InitialXPs[x].XPGained == InitialXPs[x].LogXPGained)	// not valid or already logged
    	return;

	if (InitialXPs[x].PlayerReplicationInfo == None)
		iScore = InitialXPs[x].LastScore;
	else
	{
		iScore = InitialXPs[x].PlayerReplicationInfo.Score;
		if (InitialXPs[x].PlayerReplicationInfo.bBot)
		{
			return;	// bot
  		}
	}

	// we will log, so note what we logged at
	InitialXPs[x].LogXPGained = InitialXPs[x].XPGained;

    // ok found this person
    PClass = "None";
	if (InitialXPs[x].PlayerClass == 1)
		PClass = "WeaponMaster";
	else if (InitialXPs[x].PlayerClass == 2)
		PClass = "AdrenalineMaster";
	else if (InitialXPs[x].PlayerClass == 3)
		PClass = "MonsterMaster";
	else if (InitialXPs[x].PlayerClass == 4)
		PClass = "Engineer";
	else if (InitialXPs[x].PlayerClass == 5)
		PClass = "General";
		
	// calculate PPH
	if (Level == None || Level.Game == None ||  Level.Game.GameReplicationInfo == None)
		iPPH = 0;
	else
	{
	    if ( InitialXPs[x].PlayerReplicationInfo != None)
			iDuration = Level.Game.GameReplicationInfo.ElapsedTime - InitialXPs[x].PlayerReplicationInfo.StartTime;
  		else
			iDuration = Level.Game.GameReplicationInfo.ElapsedTime - InitialXPs[x].StartTime;
		if (iDuration > 5)
			iPPH = Clamp(3600* iScore/iDuration,-999,99999);
		else
			iPPH = 0;
	} 
	
	if (sLogReason == "End Map" && InitialXPs[x].PlayerReplicationInfo != None && InitialXPs[x].PlayerReplicationInfo.StartTime == 0)
		sLogReason = "Whole Map";		// player has been on for the whole map
		
	if (InitialXPs[x].SubClass == "")
		SClass = "None";
	else
		SClass = InitialXPs[x].SubClass;
    Log(">>>> PlayerScore:" $ sLogReason @ "PlayerName:" $ InitialXPs[x].PlayerName @ "Level:" $ InitialXPs[x].Level  @ "Score:" $ iScore @ "PPH:" $ iPPH @ "XP Gained:" $ InitialXPs[x].XPGained @ "Class:" $ PClass @ "SubClass:" $ SClass @ "Time:" $ iDuration @ "Gametype:" $ Level.Game @ "Map:" $ Level.Title);
}

function NotifyLogout(Controller Exiting)
{
	local String PlayerName;
	local int x;
	local RPGStatsInv StatsInv;

	if (level.game == None || Level.Game.bGameRestarted)
		return;			// should have already logged

	if (Exiting == None || !Exiting.isA('PlayerController') || Exiting.PlayerReplicationInfo == None)
		return;			// cant do any more

	// can't trust name in PlayerReplicationInfo. Lets look in StatsInv - if we have one
 	StatsInv = GetStatsInvFor(Exiting, false);
 	if (StatsInv != None && StatsInv.DataObject != None)
 	{
 	    PlayerName = String(StatsInv.DataObject.Name);
 	}
 	else
 	{
 	    PlayerName = Exiting.PlayerReplicationInfo.PlayerName;
	}
 	    
    x = 0;
    while (x < InitialXPs.Length && InitialXPs[x].PlayerName != PlayerName)
		x++;
		
     if (x >= InitialXPs.Length)
    {
    	return;
	}

	LogDetailsForPlayer(x, "Logout");
}

defaultproperties
{
     GroupName="RPGHUDInvasion"
     FriendlyName="Druid's Invasion RPG HUD"
     Description="Show Friendly Monsters In HUD and show monsters on a danger scale from Green to Red. Also show xp gained on Invasion scoreboard."
}
