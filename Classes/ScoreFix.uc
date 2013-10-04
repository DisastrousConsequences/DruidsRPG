class ScoreFix extends Mutator
      config(ScoreFix);

struct ScoreConfig
{
	var String GameType;
	var int EXPForWin;
	var bool IronMan;
	var float MonsterScoreMultiplier;
	var float LevelDiffExpGainDiv;
	var float WeaponModifierChance;
};

var RPGRules rules;
var config Array<ScoreConfig> ScoreConfigs;
var int gameType;

function PreBeginPlay()
{
	setup();
	if(rules != None)
		Log("Warning: Looks like ScoreFix was loaded before RPG. Magic Weapon Settings might not take effect.");
	
	class'MutUT2004RPG'.default.LevelDiffExpGainDiv = ScoreConfigs[gameType].LevelDiffExpGainDiv;
	class'MutUT2004RPG'.default.EXPForWin=ScoreConfigs[gameType].EXPForWin;
	class'MutUT2004RPG'.default.bIronmanMode=ScoreConfigs[gameType].IronMan;
	class'MutUT2004RPG'.default.WeaponModifierChance=ScoreConfigs[gameType].WeaponModifierChance;
	if(ScoreConfigs[gameType].WeaponModifierChance == 0)
	    class'MutUT2004RPG'.default.bMagicalStartingWeapons = False;
	else
	    class'MutUT2004RPG'.default.bMagicalStartingWeapons = True;

	class'MutUT2004RPG'.static.StaticSaveConfig();
}

function PostBeginPlay()
{
	setup();
}

function bool CheckReplacement (Actor Other, out byte bSuperRelevant)
{
    local Monster m;
	local int score;

	setup();

	if(Other != None && Other.isA('Monster'))
	{
		m = Monster(Other);
		score = int(float(m.getPropertyText("ScoringValue")) *  ScoreConfigs[gameType].MonsterScoreMultiplier);
		if(score == 0 && ScoreConfigs[gameType].MonsterScoreMultiplier > 0)
			score = 1;
		m.ScoringValue = score;
	}
	return(super.CheckReplacement(Other, bSuperRelevant));
}

function setup()
{
	local int x;
	local GameRules G;

	if(rules != None)
		return; //already initialized

	for(x = 0; x < ScoreConfigs.Length; x++)
	{
		if(string(Level.Game.class) == ScoreConfigs[x].GameType)
			break;
	}
	if(x == ScoreConfigs.Length)
	{
		x = 0; //When in doubt, use the default
		Log("Game type" @ Level.Game.class @ "was not in the list of score fix game types Using the default of" @ ScoreConfigs[0].GameType @ "instead.");
	}
	gameType = x;

	Log("ScoreFix for Game type" @ ScoreConfigs[gameType].GameType @ "selected.");

	if ( Level.Game.GameRulesModifiers == None )
		return; //we'll try again later.
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if(G.isA('RPGRules'))
				break;
			if(G.NextGameRules == None)
				return; //we'll try again later
		}
	}
	rules = RPGRules(G);

	rules.LevelDiffExpGainDiv = ScoreConfigs[gameType].LevelDiffExpGainDiv;
	rules.RPGMut.LevelDiffExpGainDiv = ScoreConfigs[gameType].LevelDiffExpGainDiv;
	rules.RPGMut.default.LevelDiffExpGainDiv = ScoreConfigs[gameType].LevelDiffExpGainDiv;

	rules.RPGMut.EXPForWin=ScoreConfigs[gameType].EXPForWin;
	rules.RPGMut.default.EXPForWin=ScoreConfigs[gameType].EXPForWin;
	rules.RPGMut.bIronmanMode=ScoreConfigs[gameType].IronMan;
	rules.RPGMut.default.bIronmanMode=ScoreConfigs[gameType].IronMan;
	rules.RPGMut.WeaponModifierChance=ScoreConfigs[gameType].WeaponModifierChance;
	rules.RPGMut.default.WeaponModifierChance=ScoreConfigs[gameType].WeaponModifierChance;
	if(ScoreConfigs[gameType].WeaponModifierChance == 0)
	{
	    rules.RPGMut.bMagicalStartingWeapons = False;
	    rules.RPGMut.default.bMagicalStartingWeapons = False;
	}
	else
	{
	    rules.RPGMut.bMagicalStartingWeapons = True;
	    rules.RPGMut.default.bMagicalStartingWeapons = True;

	}
}

defaultproperties
{
     ScoreConfigs(0)=(GameType="Default",LevelDiffExpGainDiv=1000.000000)
     ScoreConfigs(1)=(GameType="XGame.xDeathMatch",EXPForWin=20,MonsterScoreMultiplier=0.250000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     ScoreConfigs(2)=(GameType="XGame.xTeamGame",EXPForWin=30,MonsterScoreMultiplier=0.250000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     ScoreConfigs(3)=(GameType="XGame.xCTFGame",EXPForWin=30,MonsterScoreMultiplier=0.050000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     ScoreConfigs(4)=(GameType="XGame.xDoubleDom",EXPForWin=30,MonsterScoreMultiplier=0.050000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     ScoreConfigs(5)=(GameType="XGame.xBombingRun",EXPForWin=30,MonsterScoreMultiplier=0.050000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     ScoreConfigs(6)=(GameType="XGame.xVehicleCTFGame",EXPForWin=30,MonsterScoreMultiplier=0.050000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     ScoreConfigs(7)=(GameType="BonusPack.xMutantGame",EXPForWin=40,MonsterScoreMultiplier=0.050000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     ScoreConfigs(8)=(GameType="BonusPack.xLastManStandingGame",EXPForWin=30,MonsterScoreMultiplier=0.500000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     ScoreConfigs(9)=(GameType="SkaarjPack.Invasion",EXPForWin=80,MonsterScoreMultiplier=1.000000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     ScoreConfigs(10)=(GameType="UT2K4Assault.ASGameInfo",EXPForWin=30,MonsterScoreMultiplier=0.050000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     ScoreConfigs(11)=(GameType="Onslaught.ONSOnslaughtGame",EXPForWin=30,MonsterScoreMultiplier=0.050000,LevelDiffExpGainDiv=100.000000,WeaponModifierChance=0.333333)
     GroupName="ScoreFix"
     FriendlyName="Score Fix"
     Description="Changes scoring and RPG Points for various game types."
}
