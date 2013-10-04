//This message is sent to players who have some adrenaline given to them
class HealAdrenalineConditionMessage extends LocalMessage;

var localized string HealAdrenalineMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if(RelatedPRI_1 == None)
		return "";
	return (RelatedPRI_1.PlayerName @ default.HealAdrenalineMessage);
}

defaultproperties
{
	  HealAdrenalineMessage="has given you extra adrenaline"
	  bIsUnique=True
	  bIsConsoleMessage=False
	  bFadeMessage=True
	  Lifetime=2
	  DrawColor=(B=0)
	  PosY=0.750000
}
