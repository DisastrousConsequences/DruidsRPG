class FriendlyMonsterInv extends Inventory;

var PlayerReplicationInfo MasterPRI;

var float Skill;

var MonsterPointsInv MonsterPointsInv;

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	setTimer(2.0, false);
	super.giveTo(Other);
}

function destroyed()
{
	MonsterPointsInv = None; //free the reference;
	super.destroyed();
}

function Timer()
{
	//lazy initialization of the skill just in case someone else mucks with it.
	if(Instigator != None && Instigator.Controller != None && MonsterController(Instigator.Controller) != None)
		MonsterController(Instigator.Controller).initializeSkill(Skill);
}

DefaultProperties
{
	RemoteRole=ROLE_DumbProxy
	bOnlyRelevantToOwner=True
}