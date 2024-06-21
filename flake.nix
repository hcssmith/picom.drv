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
            owner = "ibhagwan";
            repo = "picom";
            rev = "c4107bb6cc17773fdc6c48bb2e475ef957513c7a";
            hash = "sha256-1hVFBGo4Ieke2T9PqMur1w4D0bz/L3FAvfujY9Zergw=";
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
