{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nixvim.url = "github:nix-community/nixvim";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    disko,
    home-manager,
    nix-flatpak,
    ...
  }: let
    system = "x86_64-linux";

    baseModules = [
      disko.nixosModules.disko
      ./nix/configuration.nix
      home-manager.nixosModules.default
      ({pkgs, ...}: {
        environment.systemPackages = [pkgs.alejandra];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [
            nix-flatpak.homeManagerModules.nix-flatpak
            inputs.nixvim.homeModules.nixvim
          ];
          users.kp = ./nix/home.nix;
        };
      })
    ];

    # Each host is a directory whose default.nix pulls in the host-specific
    # modules it needs, composed on top of the shared base. `inputs` is threaded
    # through specialArgs so a host module can reference any flake input; inputs
    # a host never imports a module for stay unused on that host.
    mkSystem = hostDir:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = baseModules ++ [hostDir];
      };
  in {
    nixosConfigurations = {
      laptop = mkSystem ./nix/hosts/laptop;
      desktop = mkSystem ./nix/hosts/desktop;
    };
  };
}
