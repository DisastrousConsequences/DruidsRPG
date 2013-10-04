//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GiveItemsInv extends Inventory;

//client side only
var PlayerController PC;
var Player Player;
var DruidsRPGKeysInteraction DKInteraction;

var MutDruidRPG KeysMut;
var bool Initialized;
var bool InitializedSubClasses;
var bool InitializedAbilities;
var int tickcount;
var bool bRemovedInteraction;

var int AwarenessLevel,MedicAwarenessLevel,EngAwarenessLevel;	// used for showing awareness. replicated.

struct ArtifactKeyConfig
{
	Var String Alias;
	var Class<RPGArtifact> ArtifactClass;
};
var config Array<ArtifactKeyConfig> ArtifactKeyConfigs;

// now the subclass stuff.
// This is all local copies of what is in the SubClass ability config. Copied here for replication to client
// structure containing list of subclasses available to each class, and what minimum level it can be bought at
var Array<string> SubClasses;

struct SubClassConfig
{
	var class<RPGClass> AvailableClass;
	var string AvailableSubClass;
	var int MinLevel;
};
var Array<SubClassConfig> SubClassConfigs;

// structure containing list of abilities available to each class/subclass. Set MaxLevel to zero for abilities not available.
struct AbilityConfig
{
	var int SubClassIndex;		// index into subclasses array
	var class<RPGAbility> AvailableAbility;
	var int MaxLevel;
};
var Array<AbilityConfig> AbilityConfigs;

var RPGStatsInv ClientStatsInv;		// set clientside by RPGMenus

replication
{
	reliable if (Role<ROLE_Authority)
		DropHealthPickup, DropAdrenalinePickup, ServerSellData, ServerSetSubClass, ServerGetAbilities;
	reliable if (Role == ROLE_Authority)
		ClientReceiveKeys, ClientRemainingAbility, ClientRemoveAbilities, ClientReceiveSubClass, ClientReceiveSubClasses, ClientReceiveSubClassAbilities, ClientSetSubClass, ClientSetSubClassSizes, ClientDoReconnect, RemoveInteraction;
	reliable if (Role == ROLE_Authority)
		AwarenessLevel,MedicAwarenessLevel,EngAwarenessLevel;
}


// simple utility to find if the specified controller has a GiveItemsInv
static final function GiveItemsInv GetGiveItemsInv(Controller C)
{
	local Inventory Inv;
	local GiveItemsInv FoundGiveItemsInv;

	// see if the controller is valid
	if (C == None)
		return None;
		
	// now the GiveItemsInv is stored on the Controller inventory. So let us see if it is there
	for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		FoundGiveItemsInv = GiveItemsInv(Inv);
		if (FoundGiveItemsInv != None)
			return FoundGiveItemsInv;
		
			if (Inv.Inventory == Inv)
			{
				Inv.Inventory = None;
				return None;
			}
	}

	return None;
}

function PostBeginPlay()
{
//	if(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
//		setTimer(5, true);
	super.postBeginPlay();
}

simulated function PostNetBeginPlay()
{
	bRemovedInteraction=false;
	if(Level.NetMode != NM_DedicatedServer)
		enable('Tick');		// tick on client
	super.PostNetBeginPlay();

}

simulated function Tick(float deltaTime)
{
	local int x;
	local RPGInteraction rpgi;

	if (Level.NetMode == NM_DedicatedServer || (DKInteraction != None && bRemovedInteraction))
	{
		disable('Tick');
	}
	else
	{
		if (!Initialized)
		{
			tickcount++;
			if (tickcount>5000)
			{
				disable('Tick');
			}
			return;
		}

		PC = Level.GetLocalPlayerController();
		if (PC != None)
		{
			Player = PC.Player;
			if(Player != None)
			{
				//first, find out if they have the interaction already.
				
				for(x = 0; x < Player.LocalInteractions.length; x++)
				{
					if (RPGInteraction(Player.LocalInteractions[x]) != None && DruidsRPGKeysInteraction(Player.LocalInteractions[x]) == None )
					{
						rpgi = RPGInteraction(Player.LocalInteractions[x]);
					} 
					else
					if(DruidsRPGKeysInteraction(Player.LocalInteractions[x]) != None && DKInteraction == None)
					{
						DKInteraction = DruidsRPGKeysInteraction(Player.LocalInteractions[x]);
					}
				}
				if (rpgi != None && Player.InteractionMaster != None )
				{
					Player.InteractionMaster.RemoveInteraction(rpgi);
					bRemovedInteraction = true;
				}
				if(DKInteraction == None) //they dont have one
				{
					AddInteraction();
				}
			}
			if(DKInteraction != None && bRemovedInteraction)
				disable('Tick');
		}
	}
}


//not done through the interaction master, because that requires a string with a package name.
simulated function AddInteraction()
{
	local int x;

	DKInteraction = new class'DruidsRPGKeysInteraction';

	if (DKInteraction != None)
	{
		Player.LocalInteractions.Length = Player.LocalInteractions.Length + 1;
		Player.LocalInteractions[Player.LocalInteractions.Length-1] = DKInteraction;
		DKInteraction.ViewportOwner = Player;

		// Initialize the Interaction

		DKInteraction.Initialize();
		DKInteraction.Master = Player.InteractionMaster;
		DKInteraction.GiveItemsInv = self;

		// now copy the keys over
		DKInteraction.ArtifactKeyConfigs.Length = 0;
		for (x = 0; x < ArtifactKeyConfigs.Length; x++)
		{
			if(ArtifactKeyConfigs[x].Alias != "")
			{
				DKInteraction.ArtifactKeyConfigs.Length = x+1;
				DKInteraction.ArtifactKeyConfigs[x].Alias = ArtifactKeyConfigs[x].Alias;
				DKInteraction.ArtifactKeyConfigs[x].ArtifactClass = ArtifactKeyConfigs[x].ArtifactClass;
			}
		}
	}
	else
		Log("Could not create DruidsRPGKeysInteraction");

} 

function InitializeKeyArray()
{
	// create client side copy of keys
	local int x;

	if(!Initialized)
	{
		if(KeysMut != None)
		{
			for (x = 0; x < KeysMut.ArtifactKeyConfigs.Length; x++)
			{
				if(KeysMut.ArtifactKeyConfigs[x].Alias != "")
				{
					ClientReceiveKeys(x, KeysMut.ArtifactKeyConfigs[x].Alias, KeysMut.ArtifactKeyConfigs[x].ArtifactClass);
				}else
				{
					ClientReceiveKeys(x, "", None);
				}
			}
			ClientReceiveKeys(-1, "", None);
			Initialized = True;
		}
	}
}

simulated function ClientReceiveKeys(int index, string newAliasString, Class<RPGArtifact> newArtifactClass)
{
	if(Level.NetMode != NM_DedicatedServer)
	{
		if (index < 0)
		{
			Initialized = True;
		}
		else
		{
			ArtifactKeyConfigs.Length = index+1;
			ArtifactKeyConfigs[index].Alias = newAliasString;
			ArtifactKeyConfigs[index].ArtifactClass = newArtifactClass;
		}
	}
}

simulated function Destroyed()
{

	//since various gametypes enjoy destroying pawns (and thus their inventory) without giving notification,
	//it's possible for RPGStatsInv to get destroyed while the player owning it is still playing. Since there's
	//no way to prevent the destruction, the only choice is to reset everything and wait for a new one.
	if (Level.NetMode != NM_DedicatedServer)
	{
		if (DKInteraction != None)
		{
			DKInteraction.GiveItemsInv = None;
			DKInteraction.EInv = None;
			DKInteraction.MInv = None;
			DKInteraction.EnemyList = None;
			RemoveInteraction();
		}
	}

	Super.Destroyed();
}


simulated function RemoveInteraction()
{
	if(DKInteraction != None)
	{
			DKInteraction.GiveItemsInv = None;
			DKInteraction.EInv = None;
			DKInteraction.MInv = None;
			DKInteraction.EnemyList = None;
	}
	if(Player != None && Player.InteractionMaster != None && DKInteraction != None)
		Player.InteractionMaster.RemoveInteraction(DKInteraction);
	DKInteraction = None;
}

static function DropHealth(Controller C)
{
	local GiveItemsInv GI;

	if (C == None)
		return;
	if (C.Pawn == None || C.Pawn.Health <= 25 || Vehicle(C.Pawn) != None)
		return;

	// ok, lets try it
	GI = class'GiveItemsInv'.static.GetGiveItemsInv(C);
	if (GI != None)
	{
		GI.DropHealthPickup();
	}
}


function DropHealthPickup()
{
	local vector X, Y, Z;
	local Inventory Inv;
	local int HealthUsed;
	local RPGStatsInv StatsInv;
	local int ab;
	local Controller ControllerOwner;
	local Pawn PawnOwner;
	local Pickup NewPickup; 

	ControllerOwner = Controller(Owner);
	if (ControllerOwner == None || ControllerOwner.Pawn == None)
		return;
	PawnOwner = ControllerOwner.Pawn;

	HealthUsed = class'DruidHealthPack'.default.HealingAmount;

	// ok, now we need to check if this bod has smart healing, to avoid throw and pickup exploit
	for (Inv = ControllerOwner.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		StatsInv = RPGStatsInv(Inv);
		if (StatsInv != None)
			break;
	}
	if (StatsInv == None) //fallback, should never happen
		StatsInv = RPGStatsInv(PawnOwner.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None) //this should always be the case
	{
		for (ab = 0; ab < StatsInv.Data.Abilities.length; ab++)
		{
			if (ClassIsChildOf(StatsInv.Data.Abilities[ab], class'AbilitySmartHealing'))
			{
				HealthUsed += 25 * 0.25 * StatsInv.Data.AbilityLevels[ab];
			}
		}
	}


	if (PawnOwner.Health <= HealthUsed)
		return;

	GetAxes(PawnOwner.Rotation, X, Y, Z);
	NewPickup = PawnOwner.spawn(class'DruidHealthPack',,, PawnOwner.Location + (1.5*PawnOwner.CollisionRadius + 1.5*class'DruidHealthPack'.default.CollisionRadius) * Normal(Vector(ControllerOwner.GetViewRotation())));
	if (NewPickup == None)
	{
		return;
	}
	NewPickup.RemoteRole = ROLE_SimulatedProxy;
	NewPickup.bReplicateMovement = True;
	NewPickup.bTravel=True;
	NewPickup.NetPriority=1.4;
	NewPickup.bClientAnim=true;
	NewPickup.Velocity = Vector(ControllerOwner.GetViewRotation());
	NewPickup.Velocity = NewPickup.Velocity * ((PawnOwner.Velocity Dot NewPickup.Velocity) + 500) + Vect(0,0,200);
	NewPickup.RespawnTime = 0.0;
	NewPickup.InitDroppedPickupFor(None);
	NewPickup.bAlwaysRelevant = True;

	PawnOwner.Health -= HealthUsed;
	if (PawnOwner.Health <= 0)
		PawnOwner.Health = 1;	// dont kill it by throwing health. Shouldn't really need this, but...
	// no exp for dropping health - too exploitable

}

static function DropAdrenaline(Controller C)
{
	local GiveItemsInv GI;

	if (C == None)
		return;
	if (C.Pawn == None || C.Pawn.Health <= 5)
		return;

	// ok, lets try it
	GI = class'GiveItemsInv'.static.GetGiveItemsInv(C);
	if (GI != None)
	{
		GI.DropAdrenalinePickup();
	}
}


function DropAdrenalinePickup()
{
	local vector X, Y, Z;
	local Controller ControllerOwner;
	local Pawn PawnOwner;
	local AdrenalinePickup NewPickup; 
	Local XPawn xP;

	ControllerOwner = Controller(Owner);
	if (ControllerOwner == None || ControllerOwner.Pawn == None)
		return;
	PawnOwner = ControllerOwner.Pawn;

	if (ControllerOwner.Adrenaline < 25)
		return;
	xP = xPawn(PawnOwner);
	if (xP != None && xP.CurrentCombo != None)
		return;		// can't drop while in combo

	GetAxes(PawnOwner.Rotation, X, Y, Z);
	NewPickup = PawnOwner.spawn(class'DruidAdrenalinePickup',,, PawnOwner.Location + (1.5*PawnOwner.CollisionRadius + 1.5*class'DruidAdrenalinePickup'.default.CollisionRadius) * Normal(Vector(ControllerOwner.GetViewRotation())));
	if (NewPickup == None)
	{
		return;
	}
	NewPickup.RemoteRole = ROLE_SimulatedProxy;
	NewPickup.bReplicateMovement = True;
	NewPickup.bTravel=True;
	NewPickup.NetPriority=1.4;
	NewPickup.bClientAnim=true;
	NewPickup.Velocity = Vector(ControllerOwner.GetViewRotation());
	NewPickup.Velocity = NewPickup.Velocity * ((PawnOwner.Velocity Dot NewPickup.Velocity) + 500) + Vect(0,0,200);
	NewPickup.RespawnTime = 0.0;
	NewPickup.InitDroppedPickupFor(None);
	NewPickup.bAlwaysRelevant = True;
	NewPickup.AdrenalineAmount = 25;
	NewPickup.SetDrawScale(class'AdrenalinePickup'.default.DrawScale * 2);	// bigger cos more adrenaline

	ControllerOwner.Adrenaline -= 25;
	if (ControllerOwner.Adrenaline < 0)
		ControllerOwner.Adrenaline = 0;
	// no exp for dropping health - too exploitable

}


//----------------------------------------------------------------------------------------
// OK, now the stuff for handling subclasses

// first intialize the data. Copy from configuration in the SubClass config and replicate to the client
function InitializeSubClasses(Pawn Other)
{
	// create client side copy of subclasses and limits
	// copied from the SubClass ability coinfiguration
	local int x;
	local int sc;
	local bool bGotSC;
	local int numConfigs;

	if(!InitializedSubClasses)
	{
		// first setup the server from the subClass config
		SubClasses.length = class'SubClass'.default.SubClasses.length;
		for (x = 0; x < SubClasses.Length; x++)
		{
			SubClasses[x] = class'SubClass'.default.SubClasses[x];
		}
		SubClassConfigs.length = class'SubClass'.default.SubClassConfigs.length;
		for (x = 0; x < SubClassConfigs.Length; x++)
		{
			// now subclass names are just strings. It is easy to have typos, so lets check this matches a subclass
			bGotSC = false;
			for (sc = 0; sc < SubClasses.Length; sc++)
			{
				if (SubClasses[sc] == class'SubClass'.default.SubClassConfigs[x].AvailableSubClass)
					bGotSC = true;
			}
			if (!bGotSC)
				Warn("Invalid SubClass in configuration. SubClass:" $ class'SubClass'.default.SubClassConfigs[x].AvailableSubClass @ "Class:" $ class'SubClass'.default.SubClassConfigs[x].AvailableClass);
			SubClassConfigs[x].AvailableClass = class'SubClass'.default.SubClassConfigs[x].AvailableClass;
			SubClassConfigs[x].AvailableSubClass = class'SubClass'.default.SubClassConfigs[x].AvailableSubClass;
			SubClassConfigs[x].MinLevel = class'SubClass'.default.SubClassConfigs[x].MinLevel;
		}
		AbilityConfigs.length = 0;
		numConfigs = 0;
		for (x = 0; x < class'SubClass'.default.AbilityConfigs.Length; x++)
		{
			for (sc=0; sc < SubClasses.Length; sc++)
			{
				// go through each subclass, and add ability for level specified
				AbilityConfigs.length = numConfigs+1;
				AbilityConfigs[numConfigs].SubClassIndex = sc;
				AbilityConfigs[numConfigs].AvailableAbility = class'SubClass'.default.AbilityConfigs[x].AvailableAbility;
				if (class'SubClass'.default.AbilityConfigs[x].MaxLevels.length > sc)
					AbilityConfigs[numConfigs].MaxLevel = class'SubClass'.default.AbilityConfigs[x].MaxLevels[sc];
				else
					AbilityConfigs[numConfigs].MaxLevel = 0;	// wasn't an entry for it
				numConfigs++;
			}
		}

		InitializedAbilities = true;		//server side

		// now lets replicate
		for (x = 0; x < SubClasses.Length; x++)
		{
				ClientReceiveSubClass(x, SubClasses[x]);
		}
		for (x = 0; x < SubClassConfigs.Length; x++)
		{
			if(SubClassConfigs[x].AvailableClass != None)
			{
				ClientReceiveSubClasses(x, SubClassConfigs[x].AvailableClass, SubClassConfigs[x].AvailableSubClass, SubClassConfigs[x].Minlevel);
			}else
			{
				ClientReceiveSubClasses(x, None, "", 0);
			}
		}
		// do not replicate abilities for the moment - too slow. Wait for request from client
		//for (x = 0; x < AbilityConfigs.Length; x++)
		//{
		//	ClientReceiveSubClassAbilities(x, AbilityConfigs[x].AvailableSubClass, AbilityConfigs[x].AvailableAbility, AbilityConfigs[x].MaxLevel);
		//}
		ClientSetSubClassSizes(SubClasses.Length,SubClassConfigs.Length,0);		// no abilities yet - too slow
		InitializedSubClasses = True;
	}

	if (Other != none && Other.Controller != None && Other.Controller.isA('PlayerController'))
	{
		if (!ValidateSubClassData(RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'))))
		{
			// Log("+++++++ GI ValidateSubClassData faiied");
			ClientDoReconnect();
		}
	}
	else
		Log("+++++++ GI ValidateSubClassData cannot be called. Other:" $ Other @ "Controller:" $ other.Controller);

}

simulated function ClientDoReconnect()
{
	local Player Ply;
	local PlayerController PlyC;
	
	// force the reconnect through
	if(Level.NetMode == NM_Client)
	{
		if (Player != None)
			Ply = Player;
		else
		{
			PlyC = Level.GetLocalPlayerController();
			if (PlyC != None)
				Ply = PlyC.Player;
		}
		Log("Forcing reconnect of player due to invalid SubClass configuration");
		if (Ply != None && Ply.GUIController != None )
		{
			//Log("++++++++ GI ClientDoReconnect issuing request");
			Ply.GUIController.ViewportOwner.Console.DelayedConsoleCommand("Reconnect");
		}
		else
			Log("++++++++ GI Could not do ClientDoReconnect - Player None or GUIController None. Player:" $ Ply);
	}
}

simulated function ClientReceiveSubClass(int index, string thisSubClass)
{
	if(Level.NetMode == NM_Client)
	{
		if (index >= 0)
		{
			if (index+1 > SubClasses.Length)
				SubClasses.Length = index+1;
			SubClasses[index] = thisSubClass;
		}
	}
}

simulated function ClientReceiveSubClasses(int index, class<RPGClass> AvailableClass, string AvailableSubClass, int MinLevel)
{
	if(Level.NetMode == NM_Client)
	{
		if (index >= 0)
		{
			if (index+1 > SubClassConfigs.Length)
				SubClassConfigs.Length = index+1;
			SubClassConfigs[index].AvailableClass = AvailableClass;
			SubClassConfigs[index].AvailableSubClass = AvailableSubClass;
			SubClassConfigs[index].MinLevel = MinLevel;
		}
	}
}

simulated function ClientReceiveSubClassAbilities(int index, int SubClassIndex, class<RPGAbility> AvailableAbility, int MaxLevel)
{
	if(Level.NetMode == NM_Client)
	{
		//	Log("******** ClientReceiveSubClassAbilities for subclasslevel:" $ SubClassIndex @ "ability" @ AvailableAbility @ "maxlevel:" $ MaxLevel);
		if (index >= 0)
		{
			if (index+1 > AbilityConfigs.Length)
				AbilityConfigs.Length = index+1;
			AbilityConfigs[index].SubClassIndex = SubClassIndex;
			AbilityConfigs[index].AvailableAbility = AvailableAbility;
			AbilityConfigs[index].MaxLevel = MaxLevel;
		}
	}
}

simulated function ClientSetSubClassSizes(int SubClassesLen,int SubClassConfigsLen,int AbilitiesLen)
{
	if(Level.NetMode == NM_Client)
	{
		if (SubClassesLen >= 0 && SubClassesLen < SubClasses.Length)
			SubClasses.Length = SubClassesLen;
			
		if (SubClassConfigsLen >= 0 && SubClassConfigsLen < SubClassConfigs.Length)
			SubClassConfigs.Length = SubClassConfigsLen;
			
		if (AbilitiesLen >= 0 && AbilitiesLen < AbilityConfigs.Length)
			AbilityConfigs.Length = AbilitiesLen;
		InitializedSubClasses = True;
		if (AbilitiesLen > 0)
			InitializedAbilities = True;
		else
			InitializedAbilities = False;
	}
}


simulated function int MaxCanBuy(int SubClassIndex, class<RPGAbility> RequestedAbility)
{
	local int x;
	local int MaxL;
	local int CountForSubClass;

	MaxL = RequestedAbility.default.MaxLevel;		// default to normal max level, unless prohibited
	
	CountForSubClass = 0;
	for (x = 0; x < AbilityConfigs.length; x++)
		if (AbilityConfigs[x].SubClassIndex == SubClassIndex)
		{
			CountForSubClass++;
			if (AbilityConfigs[x].AvailableAbility == RequestedAbility)
				MaxL = AbilityConfigs[x].MaxLevel;
		}
			
	// safety check. If we haven't got any abilities for this subclass, config is corrupt. Refuse access
	if (CountForSubClass == 0)
	{
		//Log("++++++++++ GI MaxCanBuy rejecting request for subclass:" $ CurrentSubClass @ "Ability:" $ RequestedAbility @ " because we have no config for that subclass. Number of abilites:" $ AbilityConfigs.length);
		return 0;
	}
		
	return MaxL;
}

function bool ValidateSubClassData(RPGStatsInv StatsInv)
{
	// validate that the subclass is ok for the given class, and that all abilities are still allowed. if not, sell.
	// return true if ok, false if we had to change something
	local class<RPGClass> curClass;
	local string curSubClass;			// what it is configured as - the class name or the subclass
	local int curSubClasslevel;			// what it is configured as - the class name or the subclass
	local int x,y;
	local bool bGotSubClass;
	local bool bUpdatedAbility;
	local string locPlayerName;

	locPlayerName = "<unknown>";
	if (Owner == None)
	{
		Log("++++++++++ GI ValidateSubClassData problem Owner None");
		return false;		// force reconnect
	}
	else if (Controller(Owner) == None)
	{
		Log("++++++++++ GI ValidateSubClassData problem Controller(Owner) None. Owner:" @ Owner);
		return false;		// force reconnect
	}
	else if (Controller(Owner).Pawn == None)
	{
		Log("++++++++++ GI ValidateSubClassData problem Controller(Owner).Pawn None");
		return false;		// force reconnect
	}
	else if (Controller(Owner).Pawn.PlayerReplicationInfo == None)
	{
		Log("++++++++++ GI ValidateSubClassData problem Controller(Owner).Pawn.PlayerReplicationInfo None");
		return false;		// force reconnect
	}
	else
		locPlayerName = Controller(Owner).Pawn.PlayerReplicationInfo.PlayerName;
		
	if (StatsInv == None || StatsInv.RPGMut == None || StatsInv.DataObject.Abilities.length == 0)
	{
		if (StatsInv == None)
		{
			// serious problem here. Let's force a reconnect
			Log("++++++++++ GI ValidateSubClassData problem player" @ locPlayerName @ "couldnt process. StatsInv:" $ StatsInv);
			return false;
		}

		if (StatsInv.RPGMut == None)
			if (Level.Game != None)
				StatsInv.RPGMut = class'MutUT2004RPG'.static.GetRPGMutator(Level.Game);
		if (StatsInv.RPGMut == None)
		{
			// serious problem here. Let's force a reconnect
			Log("++++++++++ GI ValidateSubClassData problem player" @ locPlayerName @ "couldnt process. StatsInv.RPGMut none");
			return false;
		}

		if (StatsInv.DataObject.Abilities.length == 0)
		{
			// no abilities? seems a bit strange, but is ok
			//Log("++++++++++ GI ValidateSubClassData problem player" @ locPlayerName @ "no abilities?");
			return true;		// not sure true is correct here? But we didnt change anything?
		}
	}
	
	curClass = None;
	curSubClass = "";
	curSubClassLevel = 0;
	// first lets find the class
	for (y = 0; y < StatsInv.DataObject.Abilities.length; y++)
		if (ClassIsChildOf(StatsInv.DataObject.Abilities[y], class'RPGClass'))
		{
			// found the class
			if (curClass == None)
				curClass = class<RPGClass>(StatsInv.DataObject.Abilities[y]);
			else
			{
				// player already has one class. Why a second?
				Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "multiple classes. Got:" $ curClass @ "selling:" $ StatsInv.DataObject.Abilities[y]);
				ServerSellAbility(StatsInv,y);
				return false;
			}
		}
		else
		if (ClassIsChildOf(StatsInv.DataObject.Abilities[y], class'SubClass'))
		{
			//found the subclass
			if (curSubClassLevel > 0)
			{
				// already go a sub class. Cannot have two.
				Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "multiple subclasses");
				ServerSellData(None, StatsInv);
				return false;
			}
			curSubClassLevel = StatsInv.DataObject.AbilityLevels[y];
			if (curSubClassLevel < class'SubClass'.default.SubClasses.length)
				curSubClass = class'SubClass'.default.SubClasses[curSubClassLevel];
			else
			{
				// this subclass no longer exists. Remove  ***************
				Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "subclass out of range");
				ServerSellData(None, StatsInv);
				return false;
			}
		}
	
	// lets check if the subclass is still valid
	if (curSubClass != "" && curClass != None && curSubClass != curClass.default.AbilityName)		// no subclass is always ok
	{
		// look through the list of classes and subclasses and check it is still there
		bGotSubClass = false;
		for (y = 0; y < class'SubClass'.default.SubClassConfigs.length; y++)
		{
			if (class'SubClass'.default.SubClassConfigs[y].AvailableClass == curClass && class'SubClass'.default.SubClassConfigs[y].AvailableSubClass == curSubClass && class'SubClass'.default.SubClassConfigs[y].MinLevel <= StatsInv.DataObject.Level)
			{	// got it, so still valid 
				bGotSubClass = true;
			}
		}
		if (!bGotSubClass)
		{
			// must sell   **************************
			Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "subclass:" $ curSubClass @ "not found for class");
			ServerSellData(None, StatsInv);
			return false;
		}
	}
	
	if (curSubClass == "")
	{
		if (curclass != None) 
			curSubClass = curClass.default.AbilityName;	// got class but no subclass
		else
			curSubClass = "None";		// no class or subclass
		// and let's make sure curSubClassLevel is set
		for (y=0; y < class'SubClass'.default.SubClasses.length; y++)
			if (class'SubClass'.default.SubClasses[y] == curSubClass)
				curSubClassLevel = y;		// they haven't really got the subclass ability, but use this as an index
	}
	// ok, now lets check the abilities. Loop through the abilities the player has and check if the subclass config limits it
	bUpdatedAbility = false;
	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
	{
		if (!ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'SubClass') && !ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'RPGClass'))
		{
			// not the class or subclass. Lets see if it is in the list for this subclass
			for (y = 0; y < class'SubClass'.default.AbilityConfigs.length; y++)
			{
				if (class'SubClass'.default.AbilityConfigs[y].AvailableAbility == StatsInv.DataObject.Abilities[x])
				{	// ok, this ability
					if (class'SubClass'.default.AbilityConfigs[y].MaxLevels.length <= curSubClassLevel || class'SubClass'.default.AbilityConfigs[y].MaxLevels[curSubClassLevel] < StatsInv.DataObject.AbilityLevels[x])
					{
						// have a problem. Lets either sell the ability or reduce to the max
						if (class'SubClass'.default.AbilityConfigs[y].MaxLevels.length > curSubClassLevel && class'SubClass'.default.AbilityConfigs[y].MaxLevels[curSubClassLevel] > 0)
						{
							Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "subclass:" $ curSubClass @ "ability:" $ StatsInv.DataObject.Abilities[x] @ "level:" $ StatsInv.DataObject.AbilityLevels[x] @ "too high, max now:" $ class'SubClass'.default.AbilityConfigs[y].MaxLevels[curSubClassLevel]);
							 StatsInv.DataObject.AbilityLevels[x] = class'SubClass'.default.AbilityConfigs[y].MaxLevels[curSubClassLevel];
						}
						else
						{
							Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "subclass:" $ curSubClass @ "ability:" $ StatsInv.DataObject.Abilities[x] @ "not available for subclass");
							StatsInv.DataObject.Abilities.Remove(x, 1); 
							StatsInv.DataObject.AbilityLevels.Remove(x, 1);
							x--; 
						}
						bUpdatedAbility = true;;
					}
					break;
				}
			}
			// if can't find ability in subclass config, then it must be an ability like AirControl that isn't controlled. So ok
		}
		
		// now as an extra, lets check for awareness abilities and set our flags accordingly
		if (x >= 0)
		{ 
			if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'DruidAwareness'))
				AwarenessLevel = StatsInv.DataObject.AbilityLevels[x];
			else if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'AbilityMedicAwareness'))
				MedicAwarenessLevel = StatsInv.DataObject.AbilityLevels[x];
			else if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'AbilityEngineerAwareness'))
				EngAwarenessLevel = StatsInv.DataObject.AbilityLevels[x];
		}
	}
	
	if (bUpdatedAbility)
	{
		StatsInv.DataObject.saveConfig();
		//now, recalculate their stats
		StatsInv.DataObject.CreateDataStruct(StatsInv.Data, false);
		if (StatsInv.RPGMut != None)
		{
			StatsInv.RPGMut.ValidateData(StatsInv.DataObject);
			StatsInv.DataObject.CreateDataStruct(StatsInv.Data, false);
		}
		// but no reset. For this game they may have the benefit of the extra ability level
		return false;
	}
	

	// all ok
	//Log("GiveItemsInv ValidateSubClassData ok player" @ locPlayerName @  "subclass:" $ curSubClass  );
	return true;
}

function ServerSetSubClass(RPGStatsInv StatsInv, int SubClassLevel)
{
	// player should have bought the SubClass ability. Now set the level correctly
	local int x, spaceindex;
	local MutRPGHUD HUDMut;
	local Mutator m;
	local string tmpstr;

	if (StatsInv == None || StatsInv.RPGMut == None || StatsInv.DataObject.Abilities.length == 0)
		return;
		
	// find the SubClass
	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
		if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'SubClass') )
		{
			StatsInv.DataObject.AbilityLevels[x] = SubClassLevel;
			StatsInv.Data.AbilityLevels[x] = SubClassLevel;
			
			ClientSetSubClass(SubClassLevel);		// now tell the client
			break;
		}
	// ok now let's make sure the scoreboard gets updated
	for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
		if (MutRPGHUD(m) != None)
		{
			HUDMut = MutRPGHUD(m);
			break;
		}
	if (HUDMut != None && Instigator != None && Instigator.PlayerReplicationInfo != None)
		for (x = 0; x < HUDMut.InitialXPs.Length; x++)
		{
			if(HUDMut.InitialXPs[x].PlayerName == Instigator.PlayerReplicationInfo.PlayerName)
			{
				// make sure subclass set correctly
    			tmpstr = class'SubClass'.default.SubClasses[SubClassLevel];
    			// but text is too long, so lets split at a space if we can
    			spaceindex = Instr(tmpstr," ");
    			if (spaceindex > 0)
           			HUDMut.InitialXPs[x].SubClass = Left (tmpstr, spaceindex);
           		else
           			HUDMut.InitialXPs[x].SubClass = tmpstr;
           		break;
			}
		}

}

simulated function ClientSetSubClass(int SubClassLevel)
{
	local int x;

	if (Level.NetMode == NM_Client) //already did this on listen/standalone servers
	{
		if (ClientStatsInv == None)
		{
			return;
		}
		for (x = 0; x < ClientStatsInv.Data.Abilities.length; x++)
			if (ClassIsChildOf(ClientStatsInv.Data.Abilities[x], class'SubClass') )
			{
				ClientStatsInv.Data.AbilityLevels[x] = SubClassLevel;
				x = ClientStatsInv.Data.Abilities.length;
			}
	
		if (ClientStatsInv.StatsMenu != None)
		{
			if (DruidsRPGStatsMenu(ClientStatsInv.StatsMenu) != None)
			{
			    if (DruidsRPGStatsMenu(ClientStatsInv.StatsMenu).GiveItems != None)
			    {
					DruidsRPGStatsMenu(ClientStatsInv.StatsMenu).InitFor(ClientStatsInv);
				}
				else
				{
					DruidsRPGStatsMenu(ClientStatsInv.StatsMenu).InitFor2(ClientStatsInv, self);
				}
			}
		}
		else
		{
			if (Player != None && Player.GUIController != None )
			{
				Player.GUIController.OpenMenu(string(class'DruidsRPGStatsMenu'));
				DruidsRPGStatsMenu(GUIController(Player.GUIController).TopPage()).InitFor2(ClientStatsInv,self);
			}
		}
	}	
}

function ServerGetAbilities(int SubClassIndex)
{
	// player should have bought the SubClass ability. Now set the level correctly
	local int x, NumAbilities;

	NumAbilities = 0;
	for (x = 0; x < AbilityConfigs.Length; x++)
	{
		if (SubClassIndex == AbilityConfigs[x].SubClassIndex && !ClassIsChildOf(AbilityConfigs[x].AvailableAbility, class'BotAbility'))
		{
			ClientReceiveSubClassAbilities(NumAbilities, AbilityConfigs[x].SubClassIndex, AbilityConfigs[x].AvailableAbility, AbilityConfigs[x].MaxLevel);
			NumAbilities++;
		}
	}
	ClientSetSubClassSizes(SubClasses.Length,SubClassConfigs.Length,NumAbilities);		// set number of abilities

}


//Sell this particular ability. Used for removing incorrect classes. Calls SellData to reset the players abilities
function ServerSellAbility(RPGStatsInv StatsInv, int AbilityNo)
{
	local int x;

	if (StatsInv == None || StatsInv.RPGMut == None || Level.Game.bGameRestarted || StatsInv.DataObject.Abilities.length < AbilityNo)
		return;
		
	// go through the abilities and lose the ones which are not classes
	StatsInv.DataObject.Abilities.Remove(AbilityNo, 1); 
	StatsInv.DataObject.AbilityLevels.Remove(AbilityNo, 1);

	// ok, are down now to just classes. Make sure the client data set is exactly the same
	StatsInv.Data.Abilities.length = 0;
	StatsInv.Data.AbilityLevels.length = 0;
	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
	{
		StatsInv.Data.Abilities[x] = StatsInv.DataObject.Abilities[x];
		StatsInv.Data.AbilityLevels[x] = StatsInv.DataObject.AbilityLevels[x];
	}
	
	ServerSellData(None, StatsInv);	// sell all abilities, as some may have been bought based on the wrong class
}

// Now some extra functions for selling player abilities
//Sell the player's abilities, but not classes. Called by the client from the stats menu, after clicking the obscenely small button and confirming it
function ServerSellData(PlayerReplicationInfo PRI, RPGStatsInv StatsInv)
{
	local int x;

	if (StatsInv == None || StatsInv.RPGMut == None || Level.Game.bGameRestarted || StatsInv.DataObject.Abilities.length == 0)
		return;
		
	// go through the abilities and lose the ones which are not classes
	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
		if (!ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'RPGClass') )
		{
			StatsInv.DataObject.Abilities.Remove(x, 1); 
			StatsInv.DataObject.AbilityLevels.Remove(x, 1);
			x--; 
		}

	// ok, are down now to just classes. Make sure the client data set is exactly the same
	StatsInv.Data.Abilities.length = 0;
	StatsInv.Data.AbilityLevels.length = 0;
	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
	{
		StatsInv.Data.Abilities[x] = StatsInv.DataObject.Abilities[x];
		StatsInv.Data.AbilityLevels[x] = StatsInv.DataObject.AbilityLevels[x];
	}
	
	// so calculate points left. Could call RPGMut.ValidateData(), but instead lets force the user to reconnect to get his points to spend. Stops exploits.
	// should set to zero, but possible exploit with levelling, so set negative
	StatsInv.DataObject.PointsAvailable = -30;
	StatsInv.Data.PointsAvailable = -30;

	// and also reset the player. A bit over the top since we are forcing them to reset, but who cares.
	if (Instigator != None && Instigator.Health > 0)
	{
		//StatsInv.OwnerDied();
		// and remove artifacts ?
		Level.Game.SetPlayerDefaults(Instigator);
		OwnerEvent('ChangedWeapon');
		Timer();
	}

	// and tell the client to update itself.
	ClientRemoveAbilities(StatsInv);		// loses all abilities
	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
	{
		ClientRemainingAbility(x, StatsInv.Data.Abilities[x], StatsInv.Data.AbilityLevels[x], StatsInv);	//StatsInv just references an object. The call doesn't pass the object, just the reference.
	}

}

simulated function ClientRemoveAbilities(RPGStatsInv thisStatsInv)
{
	if (Level.NetMode == NM_Client) //already did this on listen/standalone servers
	{
		thisStatsInv.Data.Abilities.length = 0;
		thisStatsInv.Data.AbilityLevels.length = 0;
		thisStatsInv.Data.PointsAvailable = -30;
		// also reset what abilities are in list to buy
		AbilityConfigs.Length = 0;	
		InitializedAbilities = False;
	}	
}

simulated function ClientRemainingAbility(int x, class<RPGAbility> thisAbility, int thisLevel, RPGStatsInv thisStatsInv)
{
	if (Level.NetMode == NM_Client) //already did this on listen/standalone servers
	{
		thisStatsInv.Data.Abilities[x] = thisAbility;
		thisStatsInv.Data.AbilityLevels[x] = thisLevel;
	}	
}

defaultproperties
{
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
