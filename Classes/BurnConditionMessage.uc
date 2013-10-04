//This message is sent to players who have some damage-causing condition (e.g. burn)
class BurnConditionMessage extends LocalMessage;

var localized string BurnMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	return Default.BurnMessage;
}

defaultproperties
{
     BurnMessage="You are burning"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=2
     DrawColor=(B=0,G=32,R=255)
     PosY=0.750000
}
