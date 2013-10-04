//This message is sent to players who have some damage-causing condition (e.g. poison)
class HealedConditionMessage extends LocalMessage;

var localized string HealedMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if(RelatedPRI_1 == None)
		return "";
	return (RelatedPRI_1.PlayerName @ default.HealedMessage);
}

defaultproperties
{
	  HealedMessage="has healed you"
	  bIsUnique=True
	  bIsConsoleMessage=False
	  bFadeMessage=True
	  Lifetime=1
	  DrawColor=(G=0,R=0)
	  PosY=0.750000
}
