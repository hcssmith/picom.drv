{
  description = "A very basic flake";

  inputs = {
    application-builders.url = "github:hcssmith/application-builders";
    flake-lib.url = "github:hcssmith/flake-lib";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    flake-lib,
    application-builders,
  }: let
    picom = pkgs:
      pkgs.picom.overrideAttrs (
        oa: {
          src = pkgs.fetchFromGitHub {
            owner = "yshui";
            repo = "picom";
            rev = "ae73f45ad9e313091cdf720d0f4cdf5b4eb94c1a";
            hash = "sha256-srP/za0MRsO8vAR6DENa52PO9PANyJ5g3MJF4e/66U8=";
          };
          buildInputs =
            [
              pkgs.pcre.dev
            ]
            ++ oa.buildInputs;
        }
      );

    picom-config = pkgs: pkgs.writeText "picom.conf" (builtins.readFile ./picom.conf);
  in
    flake-lib.lib.mkApp {
      inherit self;
      name = "picom";
      drv = p:
        p.runCommand (picom p).meta.mainProgram {
          buildInputs = [
            p.makeWrapper
          ];
        }
        ''
          mkdir -p $out/bin
          makeWrapper ${picom p}/bin/picom $out/bin/picom \
          --add-flags "--config ${picom-config p}"
        '';
    };
}
