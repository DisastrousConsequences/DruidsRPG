//Confirm the player really, really wants to reset his own stats to the beginning
class DruidRPGResetConfirmPage extends RPGResetConfirmPage;

function bool InternalOnClick(GUIComponent Sender)
{
	local GUIController OldController;

	if (Sender==Controls[1])
	{
		OldController = Controller;
		StatsMenu.StatsInv.ServerResetData(PlayerOwner().PlayerReplicationInfo);
		Controller.ViewportOwner.Console.DelayedConsoleCommand("Reconnect");		// force them to reconnect to re-initialise everything correctly
		Controller.CloseMenu(false);
		OldController.CloseMenu(false);
	}
	else
		Controller.CloseMenu(false);

	return true;
}

