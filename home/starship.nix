{ lib, ... }:
{
  programs.starship = {
    enable = true;
    # Kept as TOML so it stays editable with the starship schema and docs
    settings = lib.importTOML ./starship.toml;
  };
}
