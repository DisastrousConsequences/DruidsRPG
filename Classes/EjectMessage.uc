//This message is sent to players who have been ejected from a vehicle by the owner of the vehicle
class EjectMessage extends LocalMessage;

var localized string EMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if(RelatedPRI_1 == None)
		return "";
	return (default.EMessage @ RelatedPRI_1.PlayerName);
}

defaultproperties
{
	  EMessage="You have been ejected from this vehicle by "
	  bIsUnique=True
	  bIsConsoleMessage=False
	  bFadeMessage=True
	  Lifetime=1
	  DrawColor=(G=0,B=0)
	  PosY=0.750000
}
