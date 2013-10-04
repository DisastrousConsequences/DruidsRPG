//This message is sent to the player informing him of the weapon proficiency
class ProficiencyMessage extends LocalMessage;

var localized string ProfMessage1,ProfMessage2;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if(OptionalObject == None || Weapon(OptionalObject) == None)
		return (default.ProfMessage1 @ default.ProfMessage2 $ Switch $ "%");
	return (Weapon(OptionalObject).Class.default.ItemName @ default.ProfMessage2 $ Switch $ "%");
}

defaultproperties
{
	  ProfMessage1="Your weapon"
	  ProfMessage2="has a proficiency bonus of +"
	  bIsUnique=True
	  bIsConsoleMessage=False
	  bFadeMessage=True
	  Lifetime=2
	  DrawColor=(G=32,R=32,B=128)
	  PosY=0.880000
}
