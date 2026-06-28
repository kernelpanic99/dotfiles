{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    eilmeldung = {
      url = "github:christo-auer/eilmeldung";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    nixvim = {
      url = "github:nix-community/nixvim";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    disko,
    alejandra,
    home-manager,
    eilmeldung,
    noctalia,
    nix-flatpak,
    ...
  }: let
    system = "x86_64-linux";

    baseModules = [
      disko.nixosModules.disko
      ./nix/configuration.nix
      home-manager.nixosModules.default
      {
        nixpkgs.overlays = [eilmeldung.overlays.default];
        environment.systemPackages = [alejandra.defaultPackage.${system}];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [
            eilmeldung.homeManager.default
            noctalia.homeModules.default
            nix-flatpak.homeManagerModules.nix-flatpak
            inputs.nixvim.homeModules.nixvim
          ];
          users.kp = ./nix/home.nix;
        };
      }
    ];

    mkSystem = hostModule:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = baseModules ++ [hostModule];
      };
  in {
    nixosConfigurations = {
      laptop = mkSystem ./nix/hosts/laptop.nix;
      desktop = mkSystem ./nix/hosts/desktop.nix;
    };
  };
}
