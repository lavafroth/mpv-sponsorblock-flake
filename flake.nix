{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mpv-sponsorblock = {
      url = "github:TheCactusVert/mpv-sponsorblock";
      flake = false;
    };
  };

  outputs =
    {
      self,
      flake-utils,
      naersk,
      nixpkgs,
      mpv-sponsorblock,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        naersk' = pkgs.callPackage naersk { };

      in
      {
        # For `nix build` & `nix run`:
        defaultPackage = naersk'.buildPackage {
          src = mpv-sponsorblock;
          copyLibs = true;
          copyBins = false;
          release = true;
          LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
          buildInputs = with pkgs; [
            clang
            pkg-config
          ];
          BINDGEN_EXTRA_CLANG_ARGS = (
            builtins.map (a: ''-I"${a}/include"'') [
              pkgs.mpv
            ]
          );

        };
      }
    );
}
