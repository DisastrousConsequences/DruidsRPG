//This message is sent to players who have some condition (e.g. increased damage)
class DamageConditionMessage extends LocalMessage;

var localized string DamageMessage;
var localized string MadeDamageMessage;
var localized string NoDamageMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if (Switch == 0)
	{
		if(RelatedPRI_1 == None)
			return Default.DamageMessage;
		else
			return (RelatedPRI_1.PlayerName @ default.MadeDamageMessage);
	}
	else
		return Default.NoDamageMessage;
}

defaultproperties
{
     DamageMessage="You now have increased damage!"
     MadeDamageMessage="has granted you increased damage!"
     NoDamageMessage="Your increased damage has worn off!"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=2
     DrawColor=(B=0,G=0)
     PosY=0.750000
}
