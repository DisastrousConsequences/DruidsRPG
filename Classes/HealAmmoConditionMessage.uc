//This message is sent to players who have some ammo given to them
class HealAmmoConditionMessage extends LocalMessage;

var localized string HealAmmoMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if(RelatedPRI_1 == None)
		return "";
	return (RelatedPRI_1.PlayerName @ default.HealAmmoMessage);
}

defaultproperties
{
	  HealAmmoMessage="has given you extra ammo"
	  bIsUnique=True
	  bIsConsoleMessage=False
	  bFadeMessage=True
	  Lifetime=2
	  DrawColor=(B=0)
	  PosY=0.750000
}
