class SubClass extends RPGAbility
	config(UT2004RPG)
	abstract;

// this ability is just a place holder for the different subclasses on the system.
// each level represents a different subclass.
// AbilityConfigs(0)=(AvailableAbility=Class'DruidsRPG221.DruidSomeAbility',AvailableSubClasses="0,3,6,12",MaxLevels="5,15,15,10")


// mapping of level to subclass. level 0 is no subclass. level 1 is SubClasses(1) etc.
var config Array<string> SubClasses;

// structure containing list of subclasses available to each class, and what minimum level it can be bought at
struct SubClassAvailability
{
	var class<RPGClass> AvailableClass;
	var string AvailableSubClass;
	var int MinLevel;			// min level this class can use this subclass
};
var config Array<SubClassAvailability> SubClassConfigs;
// to remove a subclass, remove it from this SubClassConfigs list. Then the L screen will force the user to sell.

// structure containing list of abilities available to each class/subclass. Set MaxLevel to zero for abilities not available.
struct AbilityConfig
{
	var class<RPGAbility> AvailableAbility;
	var Array<int> MaxLevels;			// one maxlevel per subclass, zero means cannot have
};
var config Array<AbilityConfig> AbilityConfigs;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if ( Data != None && Data.OwnerID == "Bot")
		return 0;		// do not let bots buy subclasses. Too complex for them.

	if (CurrentLevel==0)
		return 1;	// can buy. Check for valid class is done elsewhere
	else
		return 0;	// can only buy one level for cost purposes

}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
		return 0;	// stop bots from buying. Could just set BotChance to 0, but we still then have the hassle of calculating the cost.
}

defaultproperties
{
	BotChance=1			// reduce chance of bot buying this

	SubClasses(0)="None"
	SubClasses(1)="AM/WM hybrid"
	SubClasses(2)="AM/MM hybrid"
	SubClasses(3)="AM/Eng hybrid"
	SubClasses(4)="WM/MM hybrid"
	SubClasses(5)="WM/Eng hybrid"
	SubClasses(6)="MM/Eng hybrid"
	SubClasses(7)="Extreme AM"
	SubClasses(8)="Extreme WM"
	SubClasses(9)="Extreme Medic"
	SubClasses(10)="Extreme Monsters"
	SubClasses(11)="Extreme Engineer"
	SubClasses(12)="Berserker"
	SubClasses(13)="Class: Adrenaline Master"
	SubClasses(14)="Class: Weapons Master"
	SubClasses(15)="Class: Monster/Medic Master"
	SubClasses(16)="Class: Engineer"
	SubClasses(17)="Class: General"
	SubClasses(18)="Skilled Weapons"
	SubClasses(19)="Tank"
	SubClasses(20)="Turret Specialist"
	SubClasses(21)="Vehicle Specialist"
	SubClasses(22)="Sentinel Specialist"
	SubClasses(23)="Base Specialist"

	SubClassConfigs(0)=(AvailableClass=Class'ClassAdrenalineMaster',AvailableSubClass="AM/WM hybrid",MinLevel=80)
	SubClassConfigs(1)=(AvailableClass=Class'ClassAdrenalineMaster',AvailableSubClass="AM/MM hybrid",MinLevel=80)
	SubClassConfigs(2)=(AvailableClass=Class'ClassAdrenalineMaster',AvailableSubClass="AM/Eng hybrid",MinLevel=80)
	SubClassConfigs(3)=(AvailableClass=Class'ClassAdrenalineMaster',AvailableSubClass="Extreme AM",MinLevel=130)
	SubClassConfigs(4)=(AvailableClass=Class'ClassWeaponsMaster',AvailableSubClass="AM/WM hybrid",MinLevel=80)
	SubClassConfigs(5)=(AvailableClass=Class'ClassWeaponsMaster',AvailableSubClass="WM/MM hybrid",MinLevel=80)
	SubClassConfigs(6)=(AvailableClass=Class'ClassWeaponsMaster',AvailableSubClass="WM/Eng hybrid",MinLevel=80)
	SubClassConfigs(7)=(AvailableClass=Class'ClassWeaponsMaster',AvailableSubClass="Extreme WM",MinLevel=130)
	SubClassConfigs(8)=(AvailableClass=Class'ClassWeaponsMaster',AvailableSubClass="Berserker",MinLevel=150)
	SubClassConfigs(9)=(AvailableClass=Class'ClassMonsterMaster',AvailableSubClass="AM/MM hybrid",MinLevel=80)
	SubClassConfigs(10)=(AvailableClass=Class'ClassMonsterMaster',AvailableSubClass="WM/MM hybrid",MinLevel=80)
	SubClassConfigs(11)=(AvailableClass=Class'ClassMonsterMaster',AvailableSubClass="MM/Eng hybrid",MinLevel=80)
	SubClassConfigs(12)=(AvailableClass=Class'ClassMonsterMaster',AvailableSubClass="Extreme Medic",MinLevel=130)
	SubClassConfigs(13)=(AvailableClass=Class'ClassMonsterMaster',AvailableSubClass="Extreme Monsters",MinLevel=130)
	SubClassConfigs(14)=(AvailableClass=Class'ClassEngineer',AvailableSubClass="AM/Eng hybrid",MinLevel=80)
	SubClassConfigs(15)=(AvailableClass=Class'ClassEngineer',AvailableSubClass="WM/Eng hybrid",MinLevel=80)
	SubClassConfigs(16)=(AvailableClass=Class'ClassEngineer',AvailableSubClass="MM/Eng hybrid",MinLevel=80)
	SubClassConfigs(17)=(AvailableClass=Class'ClassGeneral',AvailableSubClass="AM/WM hybrid",MinLevel=80)
	SubClassConfigs(18)=(AvailableClass=Class'ClassGeneral',AvailableSubClass="AM/MM hybrid",MinLevel=80)
	SubClassConfigs(19)=(AvailableClass=Class'ClassGeneral',AvailableSubClass="AM/Eng hybrid",MinLevel=80)
	SubClassConfigs(20)=(AvailableClass=Class'ClassGeneral',AvailableSubClass="WM/MM hybrid",MinLevel=80)
	SubClassConfigs(21)=(AvailableClass=Class'ClassGeneral',AvailableSubClass="WM/Eng hybrid",MinLevel=80)
	SubClassConfigs(22)=(AvailableClass=Class'ClassGeneral',AvailableSubClass="MM/Eng hybrid",MinLevel=80)
	SubClassConfigs(23)=(AvailableClass=Class'ClassWeaponsMaster',AvailableSubClass="Skilled Weapons",MinLevel=150)
	SubClassConfigs(24)=(AvailableClass=Class'ClassWeaponsMaster',AvailableSubClass="Tank",MinLevel=150)
	SubClassConfigs(25)=(AvailableClass=Class'ClassEngineer',AvailableSubClass="Turret Specialist",MinLevel=150)
	SubClassConfigs(26)=(AvailableClass=Class'ClassEngineer',AvailableSubClass="Vehicle Specialist",MinLevel=150)
	SubClassConfigs(27)=(AvailableClass=Class'ClassEngineer',AvailableSubClass="Sentinel Specialist",MinLevel=150)
	SubClassConfigs(28)=(AvailableClass=Class'ClassEngineer',AvailableSubClass="Base Specialist",MinLevel=130)
	//SubClassConfigs()=(AvailableClass=Class'ClassEngineer',AvailableSubClass="Extreme Engineer",MinLevel=1300)

	// now the subtypes.
	// 0   None
		// 1-6   AM/WM hybrid, AM/MM hybrid, AM/Eng hybrid, WM/MM hybrid, WM/Eng hybrid, MM/Eng hybrid
			// 7-12   Extreme AM, Extreme WM, Extreme Medic, Extreme Monsters, Extreme Engineer, Berserker"
				// 13-17   None,  Class: Adrenaline Master, Class: Weapons Master, Class: Monster/Medic Master, Class: Engineer,Class: General,
	        //                                                                              N,AW,AM,AE,WM,WE,ME,EA,EW,EM,EP,EE, B, A, W, M, E, G,SW,TK,TS,VS,SS,BS
	AbilityConfigs( 0)=            (AvailableAbility=Class'DruidArtifactLoaded',MaxLevels=(00,03,02,02,00,00,00,05,00,00,00,00,00,04,00,00,00,01,00,00,00,00,00,00))
	AbilityConfigs( 1)=           (AvailableAbility=Class'DruidAdrenalineSurge',MaxLevels=(00,01,01,01,00,00,00,02,00,00,00,00,00,02,00,00,00,00,00,00,00,00,00,00))
	AbilityConfigs( 2)=             (AvailableAbility=Class'DruidEnergyVampire',MaxLevels=(00,05,00,00,00,00,00,02,00,00,00,00,00,05,00,00,00,03,00,00,00,00,00,00))
	AbilityConfigs( 3)=            (AvailableAbility=Class'AbilityEnergyShield',MaxLevels=(00,00,00,02,00,00,00,03,00,00,00,00,00,02,00,00,00,00,00,00,00,00,00,00))
	AbilityConfigs( 4)=                    (AvailableAbility=Class'DruidLoaded',MaxLevels=(00,02,00,00,02,02,00,00,06,00,00,00,05,00,05,00,00,01,02,05,00,00,00,00))
	AbilityConfigs( 5)=                   (AvailableAbility=Class'DruidVampire',MaxLevels=(00,04,00,00,05,05,00,00,15,00,00,00,10,00,10,00,00,02,10,10,00,00,00,00))
	AbilityConfigs( 6)=          (AvailableAbility=Class'AbilityEnhancedDamage',MaxLevels=(00,05,00,00,05,05,00,00,10,00,00,00,00,00,10,00,00,02,00,00,00,00,00,00))
	AbilityConfigs( 7)=         (AvailableAbility=Class'AbilityBerserkerDamage',MaxLevels=(00,00,00,00,00,00,00,00,00,00,00,00,20,00,00,00,00,00,00,00,00,00,00,00))
	AbilityConfigs( 8)=      (AvailableAbility=Class'AbilityWeaponsProficiency',MaxLevels=(00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,10,00,00,00,00,00))
	AbilityConfigs( 9)=         (AvailableAbility=Class'AbilityIncreasedDamage',MaxLevels=(00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,10,00,00,00,00))
	AbilityConfigs(10)=     (AvailableAbility=Class'AbilityIncreasedProtection',MaxLevels=(00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,10,00,00,00,00))
	AbilityConfigs(11)=           (AvailableAbility=Class'AbilityLoadedHealing',MaxLevels=(00,00,02,00,02,00,03,00,00,04,01,00,00,00,00,03,00,02,00,00,00,00,00,00))
	AbilityConfigs(12)=              (AvailableAbility=Class'AbilityExpHealing',MaxLevels=(00,00,04,00,04,00,09,00,00,20,00,00,00,00,00,09,00,00,00,00,00,00,00,00))
	AbilityConfigs(13)=          (AvailableAbility=Class'AbilityMedicAwareness',MaxLevels=(00,00,02,00,02,00,02,00,00,02,01,00,00,00,00,02,00,02,00,00,00,00,00,00))
	AbilityConfigs(14)=          (AvailableAbility=Class'AbilityLoadedMonsters',MaxLevels=(00,00,05,00,05,00,00,00,00,00,20,00,00,00,00,15,00,00,00,00,00,00,00,00))
	AbilityConfigs(15)=      (AvailableAbility=Class'AbilityMonsterHealthBonus',MaxLevels=(00,00,00,00,00,00,00,00,00,00,10,00,00,00,00,10,00,00,00,00,00,00,00,00))
	AbilityConfigs(16)=           (AvailableAbility=Class'AbilityMonsterPoints',MaxLevels=(00,00,06,00,06,00,00,00,00,00,30,00,00,00,00,20,00,00,00,00,00,00,00,00))
	AbilityConfigs(17)=            (AvailableAbility=Class'AbilityMonsterSkill',MaxLevels=(00,00,02,00,02,00,00,00,00,00,07,00,00,00,00,07,00,00,00,00,00,00,00,00))
	AbilityConfigs(18)=           (AvailableAbility=Class'AbilityMonsterDamage',MaxLevels=(00,00,00,00,00,00,00,00,00,00,20,00,00,00,00,00,00,00,00,00,00,00,00,00))
	AbilityConfigs(19)=       (AvailableAbility=Class'AbilityEnhancedReduction',MaxLevels=(00,00,05,00,05,00,10,00,00,10,10,00,00,00,00,10,00,02,00,00,00,00,00,00))
	AbilityConfigs(20)=          (AvailableAbility=Class'AbilityLoadedEngineer',MaxLevels=(00,00,00,08,00,08,00,00,00,00,00,00,00,00,00,00,15,05,00,00,00,00,00,00))
	AbilityConfigs(21)=           (AvailableAbility=Class'AbilityMedicEngineer',MaxLevels=(00,00,00,00,00,00,15,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00))
	AbilityConfigs(22)=         (AvailableAbility=Class'AbilityExtremeEngineer',MaxLevels=(00,00,00,00,00,00,00,00,00,00,00,15,00,00,00,00,00,00,00,00,00,00,00,00))
	AbilityConfigs(23)=        (AvailableAbility=Class'AbilityTurretSpecialist',MaxLevels=(00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,20,00,00,00))
	AbilityConfigs(24)=       (AvailableAbility=Class'AbilityVehicleSpecialist',MaxLevels=(00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,20,00,00))
	AbilityConfigs(25)=      (AvailableAbility=Class'AbilitySentinelSpecialist',MaxLevels=(00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,20,00))
	AbilityConfigs(26)=          (AvailableAbility=Class'AbilityBaseSpecialist',MaxLevels=(00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,20))
	AbilityConfigs(27)=               (AvailableAbility=Class'DruidShieldRegen',MaxLevels=(00,00,00,07,00,07,15,00,00,00,00,00,00,00,00,00,15,05,00,15,00,00,00,15))
	AbilityConfigs(28)=           (AvailableAbility=Class'AbilityShieldHealing',MaxLevels=(00,00,00,01,00,01,03,00,00,00,00,01,00,00,00,00,03,01,00,00,01,01,01,03))
	AbilityConfigs(29)=                (AvailableAbility=Class'DruidArmorRegen',MaxLevels=(00,00,00,02,00,02,00,00,00,00,00,05,00,00,00,00,05,00,00,00,05,05,05,00))
	AbilityConfigs(30)=              (AvailableAbility=Class'DruidArmorVampire',MaxLevels=(00,00,00,05,00,05,00,00,00,00,00,15,00,00,00,00,10,00,00,00,15,15,10,00))
	AbilityConfigs(31)= (AvailableAbility=Class'AbilityConstructionHealthBonus',MaxLevels=(00,00,00,06,00,06,06,00,00,00,00,15,00,00,00,00,10,03,00,00,15,15,15,15))
	AbilityConfigs(32)=       (AvailableAbility=Class'AbilityEngineerAwareness',MaxLevels=(00,00,00,01,00,01,01,00,00,00,00,01,00,00,00,00,01,01,00,00,01,01,01,01))
	AbilityConfigs(33)=              (AvailableAbility=Class'AbilityRapidBuild',MaxLevels=(00,00,00,00,00,00,00,00,00,00,00,10,00,00,00,00,05,00,00,00,10,10,10,10))
	AbilityConfigs(34)=                 (AvailableAbility=Class'DruidAmmoRegen',MaxLevels=(00,04,02,02,02,02,00,01,05,00,00,00,04,04,04,00,00,02,05,03,00,00,00,00))
	AbilityConfigs(35)=                 (AvailableAbility=Class'DruidAwareness',MaxLevels=(00,02,02,02,02,02,00,02,02,00,00,00,02,02,02,00,00,02,02,02,00,00,00,00))
	AbilityConfigs(36)=              (AvailableAbility=Class'DruidNoWeaponDrop',MaxLevels=(00,02,00,00,00,00,00,00,00,00,00,00,00,03,02,00,00,00,02,02,00,00,00,00))
	AbilityConfigs(37)=                     (AvailableAbility=Class'DruidRegen',MaxLevels=(00,03,03,00,05,03,03,00,00,05,02,00,00,00,05,05,00,03,05,05,00,00,00,00))
	AbilityConfigs(38)=           (AvailableAbility=Class'DruidAdrenalineRegen',MaxLevels=(00,00,03,02,01,00,03,04,00,02,02,00,00,03,00,03,00,03,00,00,00,00,00,00))
	AbilityConfigs(39)=            (AvailableAbility=Class'AbilityVehicleEject',MaxLevels=(00,01,01,01,01,01,01,00,00,00,00,04,00,01,01,01,04,01,01,01,04,04,04,04))
	AbilityConfigs(40)=    (AvailableAbility=Class'AbilityWheeledVehicleStunts',MaxLevels=(00,01,01,01,01,01,01,00,00,00,00,03,00,01,01,01,03,01,01,01,03,03,03,03))
	AbilityConfigs(41)=                     (AvailableAbility=Class'DruidGhost',MaxLevels=(03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03))
	AbilityConfigs(42)=                    (AvailableAbility=Class'DruidUltima',MaxLevels=(02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,03,02,02,02,02))
	AbilityConfigs(43)=              (AvailableAbility=Class'DruidCounterShove',MaxLevels=(05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05))
	AbilityConfigs(44)=                 (AvailableAbility=Class'DruidRetaliate',MaxLevels=(10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10))
	AbilityConfigs(45)=                   (AvailableAbility=Class'AbilityJumpZ',MaxLevels=(03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,00,03,03,03,03))
	AbilityConfigs(46)=        (AvailableAbility=Class'AbilityReduceFallDamage',MaxLevels=(04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,00,04,04,04,04))
	AbilityConfigs(47)=                   (AvailableAbility=Class'AbilitySpeed',MaxLevels=(05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,00,05,05,05,05))
	AbilityConfigs(48)=          (AvailableAbility=Class'AbilityShieldStrength',MaxLevels=(04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04))
	AbilityConfigs(49)=        (AvailableAbility=Class'AbilityReduceSelfDamage',MaxLevels=(05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05))
	AbilityConfigs(50)=            (AvailableAbility=Class'AbilitySmartHealing',MaxLevels=(04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04))
	AbilityConfigs(51)=              (AvailableAbility=Class'AbilityAirControl',MaxLevels=(04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,04,00,04,04,04,04))
	AbilityConfigs(52)=        (AvailableAbility=Class'AbilityFastWeaponSwitch',MaxLevels=(02,02,02,02,02,02,02,00,02,02,02,01,02,02,02,02,02,02,02,00,01,01,01,01))
	AbilityConfigs(53)=                (AvailableAbility=Class'AbilityHardCore',MaxLevels=(01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01))
	AbilityConfigs(54)=              (AvailableAbility=Class'DruidVampireSurge',MaxLevels=(00,05,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,00,00,00))
	AbilityConfigs(55)= (AvailableAbility=Class'AbilityDefenseSentinelResupply',MaxLevels=(00,00,00,00,00,05,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,00,00,02))
	AbilityConfigs(56)=  (AvailableAbility=Class'AbilityDefenseSentinelHealing',MaxLevels=(00,00,00,00,00,00,05,00,00,00,00,00,00,00,00,00,00,02,00,00,00,00,00,02))
	AbilityConfigs(57)=  (AvailableAbility=Class'AbilityDefenseSentinelShields',MaxLevels=(00,00,00,00,00,00,05,00,00,00,00,05,00,00,00,00,00,02,00,00,00,00,05,05))
	AbilityConfigs(58)=   (AvailableAbility=Class'AbilityDefenseSentinelEnergy',MaxLevels=(00,00,00,05,00,00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,00,00,02))
	AbilityConfigs(59)=    (AvailableAbility=Class'AbilityDefenseSentinelArmor',MaxLevels=(00,00,00,00,00,00,05,00,00,00,00,05,00,00,00,00,00,02,00,00,00,00,05,05))
	AbilityConfigs(60)=          (AvailableAbility=Class'AbilitySpiderSteroids',MaxLevels=(00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00))

	MaxLevel=SubClasses.length
}