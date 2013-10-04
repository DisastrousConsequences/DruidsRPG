class DruidBuildingSummon extends Summonifact
	config(UT2004RPG);

function bool SpawnIt(TranslocatorBeacon Beacon, Pawn P, EngineerPointsInv epi)
{
	Local Vehicle NewBuilding;
	Local DruidBlock NewBlock;
	local Vector SpawnLoc, BlockLoc;
	local int i;
	local vector Normalvect, XVect, YVect, ZVect, OffsetVect;
	local int PointsLeft, PointsEach;
	local rotator SpawnRotation;
	local DruidExplosive NewExpl;

	if (ClassIsChildOf(SummonItem,class'DruidBlock'))
	{	// its a block
		SpawnLoc = Beacon.Location;	
		SpawnLoc.z += 1;		// lift block just off ground
		if (!CheckSpace(SpawnLoc,50,90))
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
			bActive = false;
			GotoState('');
			return false;
		}
		SpawnRotation.Yaw = rotator(SpawnLoc - Instigator.Location).Yaw;
		NewBlock = epi.SummonBlock(SummonItem, Points, P, SpawnLoc, SpawnRotation);
		if (NewBlock == None)
			return false;

		SetStartHealth(NewBlock);

		if ( Role == Role_Authority )
		{
			// now apply stats to block
			ApplyStatsToConstruction(NewBlock,Instigator);
		}

	}
	else if (ClassIsChildOf(SummonItem,class'DruidMultiBlock'))
	{
		// lots of blocks
		SpawnLoc = Beacon.Location;	
		SpawnLoc.z += 1;		// lift block just off ground
		// do not check for space - each block gets checked separately

		if (!epi.CheckMultiBlock(Points, class<DruidMultiBlock>(SummonItem).default.NumBlocks, P))
		{	// message already generated
			bActive = false;
			GotoState('');
			return false;
		}
		// ok, can do
		if (class<DruidMultiBlock>(SummonItem).default.NumBlocks > 0)
			PointsEach = Points/class<DruidMultiBlock>(SummonItem).default.NumBlocks;
		else
			PointsEach=0;
		PointsLeft = Points - (PointsEach * class<DruidMultiBlock>(SummonItem).default.NumBlocks);
		NormalVect = Normal(SpawnLoc-Instigator.Location);
		NormalVect.Z = 0;
		YVect = NormalVect;
		ZVect = vect(0,0,1);	// always vertical
		XVect = Normal(YVect cross ZVect);	// vector at 90 degrees to the other two

		for (i=0;i < class<DruidMultiBlock>(SummonItem).default.NumBlocks; i++)
		{
			OffsetVect = (XVect*class<DruidMultiBlock>(SummonItem).default.Blocks[i].XOffset)+(YVect*class<DruidMultiBlock>(SummonItem).default.Blocks[i].YOffset)+(ZVect*class<DruidMultiBlock>(SummonItem).default.Blocks[i].ZOffset);
			BlockLoc = SpawnLoc+OffsetVect;

			// check what angle to spawn it at
			switch( class<DruidMultiBlock>(SummonItem).default.Blocks[i].Angle)
			{
			case 1:		// right angle to vector player to trans
				SpawnRotation.Yaw = rotator(XVect).Yaw;
				break;
			case 2:		// facing player
				SpawnRotation.Yaw = rotator(SpawnLoc - Instigator.Location).Yaw;
				break;
			case 3:		// facing trans point
				SpawnRotation.Yaw = rotator(BlockLoc - SpawnLoc).Yaw;
				break;
			default:	// do it straight facing the player from the trans point
				SpawnRotation.Yaw = rotator(SpawnLoc - Instigator.Location).Yaw;
				break;
			}

			NewBlock = epi.SummonBlock(class<DruidMultiBlock>(SummonItem).default.Blocks[i].BlockType, PointsEach+PointsLeft, P, 
				BlockLoc,SpawnRotation);	
			PointsLeft = 0;
			if (NewBlock != None)
			{
				SetStartHealth(NewBlock);

				if ( Role == Role_Authority )
					ApplyStatsToConstruction(NewBlock,Instigator);	// now apply stats to block
			}
			NewBlock = None;
		}
	}
	else if (ClassIsChildOf(SummonItem,class'DruidExplosive'))
	{	// its an explosive.
		SpawnLoc = Beacon.Location;	
		SpawnLoc.z += 1;		// lift decoration just off ground
		if (!CheckSpace(SpawnLoc,30,30))		// no idea how big really
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
			bActive = false;
			GotoState('');
			return false;
		}
		SpawnRotation.Yaw = rotator(SpawnLoc - Instigator.Location).Yaw;
		NewExpl = epi.SummonExplosive(SummonItem, Points, P, SpawnLoc, SpawnRotation);
		if (NewExpl == None)
			return false;

		// dont change starting health or add any stats. But we do need to set the owner
		NewExpl.SetPawnOwner(Instigator);
	}
	else
	{	// its a proper building people can inhabit
		SpawnLoc = epi.GetSpawnHeight(Beacon.Location);
		if (SpawnLoc == vect(0,0,0))
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
			bActive = false;
			GotoState('');
			return false;
		}
		SpawnLoc.z += 1;		// lift building just off ground
		if (!CheckSpace(SpawnLoc,300,300))
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
			bActive = false;
			GotoState('');
			return false;
		}
		NewBuilding = epi.SummonBuilding(SummonItem, Points, P, SpawnLoc);
		if (NewBuilding == None)
			return false;

		SetStartHealth(NewBuilding);

		// now allow player to get xp bonus
		if ( Role == Role_Authority )
		{
			ApplyStatsToConstruction(NewBuilding,Instigator);
		}
	
	}
	return true;
}

function BotConsider()
{
	return;		// bots do not summon blocks or walls
}

defaultproperties
{
	ItemName=""
	IconMaterial=Texture'DCText.Icons.SummonBlockIcon'
}
