class ClassMonsterMaster extends RPGClass
	abstract;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	class'ClassWeaponsMaster'.static.AddLowLevelRegen(Other, 2);
}

defaultproperties
{
	AbilityName="Class: Monster/Medic Master"
	Description="This class is the prerequisite for all monster and healing related abilities.|You can not be more than one class at any time."
	BotChance=5
}