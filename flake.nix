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

    # installs Homebrew itself, the homebrew module of nix-darwin only uses it
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    {
      self,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    let
      username = "mauwii";
    in
    {
      # named by profile, not by host: Apple's default host names collide, so a switch must name it
      darwinConfigurations.private = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self username; };
        modules = [
          ./darwin/configuration.nix
          ./darwin/homebrew.nix
          nix-homebrew.darwinModules.nix-homebrew
          ./profiles/private.nix

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
