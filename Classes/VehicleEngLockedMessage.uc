//This message is sent to players who try to enter an engineer locked vehicle
class VehicleEngLockedMessage extends LocalMessage;

var localized string LockedMessage, LockedByMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if(RelatedPRI_1 == None)
		return default.LockedMessage;
	return (default.LockedByMessage @ RelatedPRI_1.PlayerName);
}

defaultproperties
{
	  LockedByMessage="This vehicle has been locked by"
	  LockedMessage="This vehicle has been locked."
	  bIsUnique=True
	  bIsConsoleMessage=False
	  bFadeMessage=True
	  Lifetime=1
	  DrawColor=(G=0,B=0)
	  PosY=0.750000
}
