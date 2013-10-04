class DruidArtifactMonsterSummon extends RPGArtifact
	abstract
	config(UT2004RPG);

var() Sound BrokenSound;

var MutUT2004RPG RPGMut;

static function bool ArtifactIsAllowed(GameInfo Game)
{
	//make sure invasion monsters get loaded
	if (DynamicLoadObject("SkaarjPack.Invasion", class'Class', true) == None)
		return false;

	return true;
}

function BotConsider()
{
	if (bActive)
		return;

	if ( Instigator.Health + Instigator.ShieldStrength < 100 && Instigator.Controller.Enemy != None
	     && Instigator.Controller.Adrenaline > (40+rand(60)) && NoArtifactsActive())
		Activate();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.Game != None)
		RPGMut = class'MutUT2004RPG'.static.GetRPGMutator(Level.Game);
	if (RPGMut != None)
		RPGMut.FillMonsterList();
	disable('Tick'); //this artifact doesn't need ticks. It activates imediately
}

function Activate()
{		
	local MonsterPointsInv Inv;
	Local int AdrenalineCost;
	Local int MonsterPointsUsed;
	Local class<Monster> ChosenMonster;
	Local Monster M;
	Local Float SelectedLifespan;

	Inv = MonsterPointsInv(Instigator.FindInventoryType(class'MonsterPointsInv'));
	if(Inv == None)
	{
		Inv = Instigator.spawn(class'MonsterPointsInv', Instigator,,, rot(0,0,0));
		if(Inv == None)
		{
			bActive = false;
			GotoState('');
			return; //get em next pass I guess?
		}

		Inv.giveTo(Instigator);
	}
	ChosenMonster = ChooseMonster(AdrenalineCost, MonsterPointsUsed, inv);
	if(ChosenMonster == None)
	{
		bActive = false;
		GotoState('');
		return;
	}

	SelectedLifespan = getMonsterLifeSpan();
		
	M = Inv.SummonMonster(ChosenMonster, AdrenalineCost, MonsterPointsUsed);
	if(M != None && SelectedLifespan > 0)
		M.LifeSpan = SelectedLifespan;
	
	if(M != None && ShouldDestroy())
	{
		if( PlayerController(Instigator.Controller) != None )
	        	PlayerController(Instigator.Controller).ClientPlaySound(BrokenSound);
		Destroy();
		Instigator.NextItem();
	}
	GotoState('');
	bActive = false;
}

function Class<Monster> chooseMonster(out int AdrenalineUsed, out int MonsterPointsUsed, MonsterPointsInv Inv);

function bool ShouldDestroy();

function float getMonsterLifeSpan();

defaultproperties
{
	MinActivationTime=0.000001
	CostPerSec=1
	BrokenSound=Sound'PlayerSounds.NewGibs.RobotCrunch3'
	ItemName="Summoning Charm"
	IconMaterial=Texture'UTRPGTextures.Icons.SummoningCharmIcon'
}