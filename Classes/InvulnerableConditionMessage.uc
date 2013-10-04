//This message is sent to players who have some condition (e.g. invulnerability)
class InvulnerableConditionMessage extends LocalMessage;

var localized string InvulnerableMessage;
var localized string MadeInvulnerableMessage;
var localized string UnInvulnerableMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if (Switch == 0)
	{
		if(RelatedPRI_1 == None)
			return Default.InvulnerableMessage;
		else
			return (RelatedPRI_1.PlayerName @ default.MadeInvulnerableMessage);
	}
	else
		return Default.UnInvulnerableMessage;
}

defaultproperties
{
     InvulnerableMessage="You are now safe from most damage!"
     MadeInvulnerableMessage="has made you safe from most damage!"
     UnInvulnerableMessage="Your damage safety has worn off!"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=2
     DrawColor=(B=0,G=0)
     PosY=0.750000
}
