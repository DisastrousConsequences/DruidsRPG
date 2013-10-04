class MutDruidRPG extends Mutator
	config(UT2004RPG);

var RPGRules rules;
var config class<RPGDamageGameRules> DamageRules;

struct ArtifactKeyConfig
{
	Var String Alias;
	var Class<RPGArtifact> ArtifactClass;
};
var config Array<ArtifactKeyConfig> ArtifactKeyConfigs;

function PostBeginPlay()
{
	Enable('Tick');
}

function ModifyPlayer(Pawn Other)
{	// for the keys and subclasses
	Local GiveItemsInv GIInv;

	super.ModifyPlayer(Other);

	if (Other == None || Other.Controller == None || !Other.Controller.IsA('PlayerController'))
		return;

	//add the default items to their inventory..
	GIInv = class'GiveItemsInv'.static.GetGiveItemsInv(Other.Controller);
	if(GIInv != None)
		return;
		
	// ok, no GiveItemsInv. Let's create one
	GIInv = Spawn(class'GiveItemsInv', Other);
	
	GIInv.KeysMut = self;
	
	// first put on controller inventory. Put at start of Inv to make sure RPGStatsInv doesn't delete it
	GIInv.Inventory = Other.Controller.Inventory;
	Other.Controller.Inventory = GIInv;

	GIInv.SetOwner(Other.Controller);
	
	// then initialise keys and subclass info
	GIInv.InitializeKeyArray();
	GIInv.InitializeSubClasses(Other);

}

function Tick(float deltaTime)
{
	local GameRules G;
	local RPGDamageGameRules DG;

	if(rules != None)
	{
		Disable('Tick');
		return; //already initialized
	}

	// Need to add DruidRPGGameRules after RPGRules, and DruidRPGDamageGameRules before RPGRules.
	if ( Level.Game.GameRulesModifiers == None )
		warn("Warning: There is no UT2004RPG Loaded. DruidsRPG cannot function.");
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if(G.isA('RPGRules'))
				rules = RPGRules(G);
			if(G.NextGameRules == None)
			{
				if(rules == None)
				{
					warn("Warning: There is no UT2004RPG Loaded. DruidsRPG cannot function.");
					return;
				}
			}
		}
		// ok, so we have a RPGRules in the list. lets add RPGDamageGameRules before it, if required
		Log("DamageRules:" $ DamageRules);
		if (DamageRules != None)
		{
			DG = spawn(DamageRules);
			if (Level.Game.GameRulesModifiers != None && Level.Game.GameRulesModifiers.IsA('RPGRules'))
			{
				// RPGRules is at the start. So add before it
				DG.NextGameRules = Level.Game.GameRulesModifiers;
				Level.Game.GameRulesModifiers = DG;
			}
			else
			{
				for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
				{
					if (G.NextGameRules != None && G.NextGameRules.IsA('RPGRules'))
					{
						DG.NextGameRules = G.NextGameRules;
						G.NextGameRules = DG;
					}
				}
			}
			DG.UT2004RPGRules = RPGRules(DG.NextGameRules);
		}
		
		// now add DruidRPGGameRules to the end of the chain
		Level.Game.GameRulesModifiers.AddGameRules(spawn(class'DruidRPGGameRules'));
		Disable('Tick');
		return;
	}
}

defaultproperties
{
	GroupName="DruidsRPG"
	FriendlyName="Druid's RPG Game Rules"
	Description="Game rules specific to DruidsRPG."
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	
	DamageRules=Class'RPGDamageGameRules'
	
	ArtifactKeyConfigs(0)=(Alias="SelectTriple",ArtifactClass=Class'DruidArtifactTripleDamage')
	ArtifactKeyConfigs(1)=(Alias="SelectGlobe",ArtifactClass=Class'ArtifactInvulnerability')
	ArtifactKeyConfigs(2)=(Alias="SelectMWM",ArtifactClass=Class'DruidArtifactMakeMagicWeapon')
	ArtifactKeyConfigs(3)=(Alias="SelectDouble",ArtifactClass=Class'DruidDoubleModifier')
	ArtifactKeyConfigs(4)=(Alias="SelectMax",ArtifactClass=Class'DruidMaxModifier')
	ArtifactKeyConfigs(5)=(Alias="SelectPlusOne",ArtifactClass=Class'DruidPlusOneModifier')
	ArtifactKeyConfigs(6)=(Alias="SelectBolt",ArtifactClass=Class'ArtifactLightningBolt')
	ArtifactKeyConfigs(7)=(Alias="SelectRepulsion",ArtifactClass=Class'ArtifactRepulsion')
	ArtifactKeyConfigs(8)=(Alias="SelectFreezeBomb",ArtifactClass=Class'ArtifactFreezeBomb')
	ArtifactKeyConfigs(9)=(Alias="SelectPoisonBlast",ArtifactClass=Class'ArtifactPoisonBlast')
	ArtifactKeyConfigs(10)=(Alias="SelectMegaBlast",ArtifactClass=Class'ArtifactMegaBlast')
	ArtifactKeyConfigs(11)=(Alias="SelectHealingBlast",ArtifactClass=Class'ArtifactHealingBlast')
	ArtifactKeyConfigs(12)=(Alias="SelectMedic",ArtifactClass=Class'ArtifactMakeSuperHealer')
	ArtifactKeyConfigs(13)=(Alias="SelectFlight",ArtifactClass=Class'ArtifactFlight')
	ArtifactKeyConfigs(14)=(Alias="SelectMagnet",ArtifactClass=Class'DruidArtifactSpider')
	ArtifactKeyConfigs(15)=(Alias="SelectTeleport",ArtifactClass=Class'ArtifactTeleport')
	ArtifactKeyConfigs(16)=(Alias="SelectBeam",ArtifactClass=Class'ArtifactLightningBeam')
	ArtifactKeyConfigs(17)=(Alias="SelectRod",ArtifactClass=Class'DruidArtifactLightningRod')
	ArtifactKeyConfigs(18)=(Alias="SelectSphereInv",ArtifactClass=Class'ArtifactSphereInvulnerability')
	ArtifactKeyConfigs(19)=(Alias="SelectSphereHeal",ArtifactClass=Class'ArtifactSphereHealing')
	ArtifactKeyConfigs(20)=(Alias="SelectSphereDamage",ArtifactClass=Class'ArtifactSphereDamage')
	ArtifactKeyConfigs(21)=(Alias="SelectRemoteDamage",ArtifactClass=Class'ArtifactRemoteDamage')
	ArtifactKeyConfigs(22)=(Alias="SelectRemoteInv",ArtifactClass=Class'ArtifactRemoteInvulnerability')
	ArtifactKeyConfigs(23)=(Alias="SelectRemoteMax",ArtifactClass=Class'ArtifactRemoteMax')
	ArtifactKeyConfigs(24)=(Alias="SelectShieldBlast",ArtifactClass=Class'ArtifactShieldBlast')
	ArtifactKeyConfigs(25)=(Alias="SelectChain",ArtifactClass=Class'ArtifactChainLightning')
	ArtifactKeyConfigs(26)=(Alias="SelectFireBall",ArtifactClass=Class'ArtifactFireBall')
	ArtifactKeyConfigs(27)=(Alias="SelectRemoteBooster",ArtifactClass=Class'ArtifactRemoteBooster')
}
