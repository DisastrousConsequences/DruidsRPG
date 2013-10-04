class ClassGeneral extends RPGClass
	config(UT2004RPG)
	abstract;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	class'ClassAdrenalineMaster'.static.ModifyPawn(Other, AbilityLevel); //gives them a bit of regen and drip
}

defaultproperties
{
	AbilityName="Class: General"
	Description="This class has basic use of most abilities, but exceeds at none of them. An all-rounder.|You can not be more than one class at any time."
	BotChance=7
}
