class RPGDeathAbility extends CostRPGAbility
	abstract;

/**
 * Called only if all other mutators don't prevent death. This is intended for saving a player from a vehicle.
 */
static function bool PrePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel);

/**
 * Called only if all PrePreventDeath methods return false. This intended for Ultima.
 * BotFodder: In other words, the player died but we don't care if they are saved later.
 */
static function PotentialDeathPending(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel);

/**
 * Called after PotentialDeathPending. This is the last opportunity to save a player.
 */
static function bool GenuinePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel);


/**
 * You should return true here anytime you will be returning true to 
 * GenuinePreventDeath() or PrePreventDeath(), as otherwise you will 
 * have live pawns running around with no head and other amusing but 
 * gameplay-damaging phenomenon. -- Mysterial
 */
static function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType, int AbilityLevel)
{
	return false;
}

/**
 * Called only if all GenuinePreventDeath methods return false. This intended for NoWeaponDrop.
 * BotFodder: More explicitly, this function should only run if player *will* die.
 */
static function GenuineDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel);