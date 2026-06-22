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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    disko,
    alejandra,
    home-manager,
    eilmeldung,
    noctalia,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      modules = [
        disko.nixosModules.disko
        ./nix/configuration.nix
        home-manager.nixosModules.default

        {
          nixpkgs.overlays = [eilmeldung.overlays.default];

          environment.systemPackages = [alejandra.defaultPackage.${system}];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [eilmeldung.homeManager.default noctalia.homeModules.default];
            users.kp = ./nix/home.nix;
          };
        }
      ];
    };
  };
}
