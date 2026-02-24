{
  description = "Auto Volume Toggler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      mac-volume = pkgs.stdenv.mkDerivation {
        pname = "mac-volume";
        version = "1.0.0";

        src = pkgs.fetchurl {
          url = "https://github.com/akrabat/mac-volume/releases/download/1.0.0/mac-volume";
          sha256 = "sha256-uWBM+rXBomp9+2r7zE8IXQwv30MMPgdg6PsKEokIkm8=";
          executable = true;
        };

        dontUnpack = true;

        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/mac-volume
          chmod +x $out/bin/mac-volume
        '';

        meta = with pkgs.lib; {
          description = "Control the volume of an output audio device on macOS";
          homepage = "https://github.com/akrabat/mac-volume";
          license = licenses.mit;
          platforms = [ "aarch64-darwin" "x86_64-darwin" ];
        };
      };

      auto-volume-toggler = { targetVolume ? 50, deviceName ? "MacBook Pro Speakers" }:
        pkgs.writeShellApplication {
          name = "auto-volume-toggler";
          runtimeInputs = [ mac-volume ];
          text = ''
            TARGET_VOLUME=${toString targetVolume}
            DEVICE_NAME="${deviceName}"
            ${builtins.readFile ./auto-volume-toggler.sh}
          '';
        };

    in
    {
      packages.${system} = {
        inherit mac-volume auto-volume-toggler;
        default = auto-volume-toggler {};
      };

      apps.${system}.default = {
        type = "app";
        program = "${auto-volume-toggler {}}/bin/auto-volume-toggler";
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ mac-volume (auto-volume-toggler {}) ];
        shellHook = ''
          echo "Auto Volume Toggler"
          echo "==================="
          echo ""
          echo "Usage:"
          echo "  nix run                              Run the auto-volume-toggler"
          echo "  nix run .#mac-volume -- list-devices List available audio devices"
          echo "  nix run .#mac-volume -- \"<device>\" get      Get volume for device"
          echo "  nix run .#mac-volume -- \"<device>\" set <0-100>  Set volume for device"
          echo ""
          echo "Build:"
          echo "  nix build                            Build the package"
          echo "  ./result/bin/auto-volume-toggler     Run the built binary"
          echo ""
        '';
      };
    };
}
