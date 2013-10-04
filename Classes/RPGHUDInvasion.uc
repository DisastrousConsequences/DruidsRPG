class RPGHUDInvasion extends HUDInvasion
	config(user);

var PlayerController PC;

#EXEC OBJ LOAD FILE=InterfaceContent.utx
#EXEC OBJ LOAD FILE=AS_FX_TX.utx

simulated function UpdatePrecacheMaterials()
{
	Super.UpdatePrecacheMaterials();
}

simulated function ShowTeamScorePassA(Canvas C)
{
	Super.ShowTeamScorePassA(C);
}

simulated function ShowTeamScorePassC(Canvas C)
{
	local Pawn P;
	local float Dist, MaxDist, RadarWidth, PulseBrightness,Angle,DotSize,OffsetY,OffsetScale;
	local rotator Dir;
	local vector Start;
	local FriendlyMonsterEffect effect;
	local bool bPet;
	local bool bMyPet;

	local int DeltaHealth;

	if(PC == None) //Initialize PC
		PC = Level.GetLocalPlayerController();

	LastDrawRadar = Level.TimeSeconds;
	RadarWidth = 0.5 * RadarScale * C.ClipX;
	DotSize = 24*C.ClipX*HUDScale/1600;
	if ( PawnOwner == None )
		Start = PlayerOwner.Location;
	else
		Start = PawnOwner.Location;
	
	MaxDist = 3000 * RadarPulse;
	C.Style = ERenderStyle.STY_Translucent;
	OffsetY = RadarPosY + RadarWidth/C.ClipY;
	MinEnemyDist = 3000;

	ForEach DynamicActors(class'Pawn',P)
		if ( P.Health > 0 )
		{
			Dist = VSize(Start - P.Location);
			if ( Dist < 3000 )
			{
				if ( Dist < MaxDist )
					PulseBrightness = 255 - 255*Abs(Dist*0.00033 - RadarPulse);
				else
					PulseBrightness = 255 - 255*Abs(Dist*0.00033 - RadarPulse - 1);

				if ( Monster(P) != None )
				{
					bPet = false;
					bMyPet = false;
					// first is it a pet?
					ForEach DynamicActors(class'FriendlyMonsterEffect',Effect)
					{
				        if (Effect.Base != None)
				        {
				            if (Monster(Effect.Base) == Monster(P))
				            {
				                bPet = true;
								if (PC != None && PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo == Effect.MasterPRI)
							    	bMyPet = true;
							}
				        }
				    }
					if (bPet)
					{
						if (bMyPet)
						{
							//make my monsters look green
							C.DrawColor.R = 0;
							C.DrawColor.G = FMin(PulseBrightness*2, 255);
							C.DrawColor.B = 0;
						}
						else
						{
							//Make friendly monsters an off blue
							C.DrawColor.R = 0;
							C.DrawColor.G = FMin(PulseBrightness*2, 255);
							C.DrawColor.B = FMin(PulseBrightness*2, 255);
						}
					}
					else
					{
						MinEnemyDist = FMin(MinEnemyDist, Dist);
						if(PawnOwner == None)
						{
							//Dont know what color to give it <shrug>
							C.DrawColor.R = PulseBrightness;
							C.DrawColor.G = PulseBrightness;
							C.DrawColor.B = 0;
						}
						else
						{
							DeltaHealth = Max(Min(PawnOwner.Health - P.Health, 255), -255);

							//Green for less dangerous, Red for more dangerous.
							C.DrawColor.R = ((-1 * DeltaHealth) / 2 + 128) * (PulseBrightness / 255.0);
							C.DrawColor.G = (DeltaHealth / 2 + 128) * (PulseBrightness / 255.0);
							C.DrawColor.B = 0;
						}
	 				}
				}
				else if ( Vehicle(P) != None && Vehicle(P).Driver == None)
				{
					//make empty vehicles grey.
					C.DrawColor.R = PulseBrightness/2;
					C.DrawColor.G = PulseBrightness/2;
					C.DrawColor.B = PulseBrightness/2;
				}
				else if ( DruidBlock(P) != None || DruidExplosive(P) != None )
				{
					//make blocks grey.
					C.DrawColor.R = PulseBrightness/2;
					C.DrawColor.G = PulseBrightness/2;
					C.DrawColor.B = PulseBrightness/2;
				}
				else
				{
					//make players blue
					C.DrawColor.R = 0;
					C.DrawColor.G = 0;
					C.DrawColor.B = PulseBrightness;
				}
				Dir = rotator(P.Location - Start);
				OffsetScale = RadarScale*Dist*0.000167;
				if ( PawnOwner == None )
					Angle = ((Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
				else
					Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
				C.SetPos(RadarPosX * C.ClipX + OffsetScale * C.ClipX * sin(Angle) - 0.5*DotSize,
						OffsetY * C.ClipY - OffsetScale * C.ClipX * cos(Angle) - 0.5*DotSize);
				C.DrawTile(Material'InterfaceContent.Hud.SkinA',DotSize,DotSize,838,238,144,144);
			}
		}
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
}

defaultproperties
{
	RadarScale=0.2
	RadarPosX=0.9
	RadarPosY=0.25
	
	YouveLostTheMatch="The Invasion Continues"
}