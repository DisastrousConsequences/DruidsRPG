class ClientHudInv extends Inventory;

//in the future, this will also contain some struct with a list of monsters to display in different colors.
//when that happens, change the remote role!

// Also using this item to transfer xp from the server to the client
var MutRPGHUD HUDMut;
var String OwnerName;

// client side copy
struct CurrentXPValues
{
	var String PlayerName;
	var int PlayerClass;       // 0 none, 1 WM, 2 AM, 3 MM, 4 Eng, 5 General
	var int XPGained;
	var string Subclass;
	var int GotHardCore;
};
var Array<CurrentXPValues> CurrentXPs;
var bool XPsUpdated;
var bool HardCoreUpdated;

var float SumDelta;

replication
{
	reliable if (Role == ROLE_Authority)
		ClientReceiveXP;
}

simulated function PostNetBeginPlay()
{
	if(Level.NetMode != NM_DedicatedServer)
		enable('Tick');
	super.PostNetBeginPlay();
	SumDelta = 13;
}

simulated function Tick(float deltaTime)
{
	local Mutator m;

	SumDelta += deltaTime;
	if (SumDelta < 15)
		return;

	// time to try again
	while (SumDelta >= 15)
		SumDelta -= 15;

	//only replicate xp for invasion at the moment
	if ( Level.Game == None )
		return;

	if ( !Level.Game.IsA('Invasion'))
	{
		disable('Tick');
		return;
	}
    
	if (HUDMut == None)
	{
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutRPGHUD(m) != None)
			{
				HUDMut = MutRPGHUD(m);
				break;
			}
	}

	CopyArray();
}

function CopyArray()
{
	local int x;
	local PlayerController pc;

	if (HUDMut == None)
		return;
		
	// lets see if it is time to move out of players inventory
	if (Pawn(Owner) != None )
	{
		pc = PlayerController(Pawn(Owner).Controller);
		if (pc != None)
		{
			Pawn(Owner).DeleteInventory(self);
			//this forces the ClientHudInv to stay relevant to the player 
			SetOwner(pc); 
		}
	}

	// now copy it over
	for (x = 0; x < HUDMut.InitialXPs.Length; x++)
	{
		if(HUDMut.InitialXPs[x].PlayerName != "")
		{
			//Log(" *** ClientHudInv Sending scores. Index:" $ x @ "player:" $ HUDMut.InitialXPs[x].PlayerName @ "xpgained:" $ HUDMut.InitialXPs[x].XPGained @ "Time:" $ Level.TimeSeconds @ "InitialXP:" $ HUDMut.InitialXPs[x].InitialXP @ "AdditionalXP:" $ HUDMut.InitialXPs[x].AdditionalXP @ "Level:" $ HUDMut.InitialXPs[x].Level @ "NeededXP:" $ HUDMut.InitialXPs[x].NeededXP);
			ClientReceiveXP(x, HUDMut.InitialXPs[x].PlayerName, HUDMut.InitialXPs[x].XPGained, HUDMut.InitialXPs[x].PlayerClass, HUDMut.InitialXPs[x].SubClass, HUDMut.InitialXPs[x].GotHardCore);
		}
		else
			ClientReceiveXP(x, "", 0, 0, "", 0);
	}
}

simulated function ClientReceiveXP(int index, string PlayerName, int XPGained, int PlayerClass, string SubClass, int GotHardCore)
{
	if(Level.NetMode != NM_DedicatedServer)
	{
		if (index >= 0)
		{
			if (CurrentXPs.Length <= index)
				CurrentXPs.Length = index+1;
			CurrentXPs[index].PlayerName = PlayerName;
			CurrentXPs[index].XPGained = XPGained;
			CurrentXPs[index].PlayerClass = PlayerClass;
			CurrentXPs[index].SubClass = SubClass;
			CurrentXPs[index].GotHardCore = GotHardCore;
			XPsUpdated = true;			// for scoreboard
			HardCoreUpdated = true;		// for awareness abilities
			//Log(" *** ClientHudInv got scores. Index:" $ index @ "player:" $ PlayerName @ "xpgained:" $ XPGained @ "Time:" $ Level.TimeSeconds);
		}
	}
}

DefaultProperties
{
	 bOnlyRelevantToOwner=True
	 bAlwaysRelevant=False
	 RemoteRole=ROLE_DumbProxy	// try DumbProxy or SimulatedProxy    instead of ROLE_AutonomousProxy
}