# M4 Max, the main Mac
{
  networking.hostName = "atlas";
  networking.computerName = "Atlas";

  # the only CleanMyMac license is on this Mac
  homebrew.casks = [ "cleanmymac" ];
}
