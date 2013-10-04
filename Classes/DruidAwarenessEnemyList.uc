//This holds and maintains the list of the local player's enemy pawns for use in AwarenessInteraction
//A seperate actor is used to prevent invalid pointer problems since Actor references
//in non-Actors don't get set to None automatically when the Actor is destroyed
// We just made a few changes to Mysterial's ... but they were in the biggest function
class DruidAwarenessEnemyList extends Actor;

var PlayerController PlayerOwner;

var array<Pawn> Enemies;
var array<Pawn> TeamPawns;
var array<int> HardCorePawns;

var ClientHudInv myClient;
var int iClientCheckCount;
// client side copy
struct CopyHCValue
{
	Var String PlayerName;
	var int GotHardCore;
};
var Array<CopyHCValue> CopyHCs;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerOwner = Level.GetLocalPlayerController();
	if (PlayerOwner != None)
		SetTimer(2, true);
	else
		Warn("DruidAwarenessEnemyList spawned with no local PlayerController!");
}

simulated function Timer()
{
	local Pawn P, PlayerDriver;
	local FriendlyMonsterEffect FME;
	local int x, j;
	Local ClientHudInv TempCInv;
	local bool GoodMonster;

	 // find the ClientHudInv if we havent already got
	 if (myClient == None )
	 {
	 	iClientCheckCount++;
	 	if (iClientCheckCount > 6)		//just to stop check putting too much load on if problems
	 	{
	 		iClientCheckCount = 0;
			ForEach DynamicActors(class'ClientHudInv',TempCInv)
			{
				if (TempCInv.HardCoreUpdated)		// only on my ClientHudInv
				{
					myClient = TempCInv;
				}
			}
		}
	 }
	 if (myClient != None && myClient.HardCoreUpdated)
	 {
		// only gets updated once every 15 secs, so do not want to copy every loop
		CopyHCs.length = myClient.CurrentXPs.length;
		for (j=0; j<myClient.CurrentXPs.length; j++)
		{
			CopyHCs[j].PlayerName = myClient.CurrentXPs[j].PlayerName;
			CopyHCs[j].GotHardCore = myClient.CurrentXPs[j].GotHardCore;
		}
		myClient.HardCoreUpdated = false;
	 }

	// ok, now let's check the players around
	Enemies.length = 0;
	TeamPawns.length = 0;
	HardCorePawns.length = 0;

	if (PlayerOwner.Pawn == None || PlayerOwner.Pawn.Health <= 0)
		return;

	if (Vehicle(PlayerOwner.Pawn) != None)
		PlayerDriver = Vehicle(PlayerOwner.Pawn).Driver;
	else
		PlayerDriver = PlayerOwner.Pawn;		// safety

	foreach DynamicActors(class'Pawn', P)
	{
		// team mates go on TeamPawns. Opposite team go on Enemies
		if (P != PlayerOwner.Pawn && P != PlayerDriver && Vehicle(P) == None && DruidBlock(P) == None && DruidExplosive(P) == None && DruidEnergyWall(P) == None && RedeemerWarhead(P) == None)
		{
			// we have a valid pawn. Now is it good or bad?
			if (P.Isa('Monster'))
			{
				// unfortunately monsters do not have a team property. So we have to work out what side it is on
				GoodMonster = False;		// Assume bad monster.

				foreach DynamicActors(class'FriendlyMonsterEffect', FME)
				{
					if (P != FME.Base)		// Skip it, not the one we're looking for.
						continue;
					else if (FME.MasterPRI == PlayerOwner.PlayerReplicationInfo)		
					{	// The one we're looking for, and it's ours.
						GoodMonster = True;
						break;
					}
					else if(FME.MasterPRI.Team != None && FME.MasterPRI.Team == PlayerOwner.PlayerReplicationInfo.Team)
					{	// The one we're looking for, not ours, but on our team.
						GoodMonster = True;
						break;
					}
					else
					{	// Gotta be a bad guy.
						break;
					}
				}
				// If we haven't found it related to an FME, or the FME says it's not friendly ...
				if (GoodMonster)
				{	// with us
					TeamPawns[TeamPawns.length] = P;
					HardCorePawns[HardCorePawns.length] = 0;		// default off for monsters
				}
				else	// against us
					Enemies[Enemies.length] = P;
			}
			else
			{
				if (P.GetTeamNum() == PlayerOwner.GetTeamNum() && PlayerOwner.GetTeamNum() != 255 )
			   	{
			   		// same team
					TeamPawns[TeamPawns.length] = P;
					// ok, now let's sort out the HardCore
					HardCorePawns[HardCorePawns.length] = 0;		// default off
					if (xPawn(P) != None && xPawn(P).PlayerReplicationInfo != None)
					{
						for (x=0; x<CopyHCs.length; x++)
						{
							if (CopyHCs[x].Playername == xPawn(P).PlayerReplicationInfo.Playername)
							{
								HardCorePawns[HardCorePawns.length-1] = CopyHCs[x].GotHardCore;	
							}
						}
					}
				}
				else
				{
					// other team
					Enemies[Enemies.length] = P;
				}
			}
		}
	}
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
     bGameRelevant=True
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
