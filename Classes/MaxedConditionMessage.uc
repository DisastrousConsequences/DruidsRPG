//This message is sent to players who have some damage-causing condition (e.g. poison)
class MaxedConditionMessage extends LocalMessage;

var localized string MaxedMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if(RelatedPRI_1 == None)
		return "";
	return (default.MaxedMessage @ RelatedPRI_1.PlayerName);
}

defaultproperties
{
	  MaxedMessage="Your weapon has been maxed by"
	  bIsUnique=True
	  bIsConsoleMessage=False
	  bFadeMessage=True
	  Lifetime=2
	  DrawColor=(G=0,R=0)
	  PosY=0.750000
}
