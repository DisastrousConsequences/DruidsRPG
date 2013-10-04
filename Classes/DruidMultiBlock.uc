class DruidMultiBlock extends Pawn;

var int NumBlocks;

struct BlockConfig
{
	var Class<Pawn> BlockType;
	var int XOffset;
	var int YOffset;
	var int ZOffset;
	var int Angle;		// 0 straight line facing player, 1 right angle to 0, 2 around player, 3 around spawn point
};
var Array<BlockConfig> Blocks;

defaultproperties
{
	NumBlocks=0
}
