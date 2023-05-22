{
  description = "A very basic flake";

  outputs = {
    self,
    nixpkgs,
  }: let
    lib = nixpkgs.lib;
    genSystems = lib.genAttrs [
      # Add more systems if they are supported
      "aarch64-linux"
      "x86_64-linux"
    ];
    pkgsFor = genSystems (system: nixpkgs.legacyPackages.${system});
  in {
    packages = genSystems (system: let
      pkgs = pkgsFor.${system};
    in {
      default = pkgs.flutter.buildFlutterApplication {
        pname = "flutter-hello";
        version = "1.0";
        src = ./.;
        vendorHash = "";
        meta = {};
      };
    });

    devShells = genSystems (
      system: {
        default = pkgsFor.${system}.mkShell {
          buildInputs = with pkgsFor.${system}; [
            flutter

            clang
            cmake
            gtk3
            gtk-layer-shell
            ninja
            pkg-config
            xz
          ];
        };
      }
    );
  };
}
