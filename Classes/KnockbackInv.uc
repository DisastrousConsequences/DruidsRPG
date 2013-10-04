class KnockbackInv extends Inventory;

var Pawn PawnOwner;
var int Modifier;

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	PawnOwner = Other;

	if(PawnOwner == None)
	{
		destroy();
		return;
	}

	SetTimer(1/Modifier, true);
	Super.GiveTo(Other);
}

function Destroyed()
{
	if(PawnOwner == None)
		return;

	if(PawnOwner.Physics != PHYS_Walking && PawnOwner.Physics != PHYS_Falling) //still going?
		PawnOwner.setPhysics(PHYS_Falling);
	super.destroyed();
}

function Timer()
{
	local DruidGhostInv dgInv;
	local GhostInv gInv;

	//if ghost is running destroying this is a really bad thing. let the timer tick till they're done.
	dgInv = DruidGhostInv(PawnOwner.FindInventoryType(class'DruidGhostInv'));
	if(dgInv != None && !dgInv.bDisabled)
		return;

	gInv = GhostInv(PawnOwner.FindInventoryType(class'GhostInv'));
	if(gInv != None && !gInv.bDisabled)
		return;

	if(PawnOwner.Physics != PHYS_Hovering && PawnOwner.Physics != PHYS_Falling)
		Destroy();
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
}