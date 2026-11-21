{
  description = "nix-darwin + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      username = "mauwii";
      hostname = "MacBook-Pro-von-Matthias"; # = `scutil --get LocalHostName`
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self username; };
        modules = [
          ./darwin/configuration.nix

          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # Rename existing files (e.g. ~/.zshrc) instead of aborting activation
              backupFileExtension = "before-home-manager";
              users.${username} = import ./home;
            };
          }
        ];
      };
    };
}
