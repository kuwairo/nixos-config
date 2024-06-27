{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs =
    { self, nixpkgs }:
    {
      nixosConfigurations.fjell = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/fjell ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
