{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/21443a102b1a2f037d02e1d22e3e0ffdda2dbff9";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.gomod2nix-repo.url = "github:nix-community/gomod2nix?rev=f95720e89af6165c8c0aa77f180461fe786f3c21";
  inputs.npmlock2nix-repo = {
    url = "github:nix-community/npmlock2nix?rev=9197bbf397d76059a76310523d45df10d2e4ca81";
    flake = false;
  };
  outputs = { self, nixpkgs, flake-utils, npmlock2nix-repo, gomod2nix-repo }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import "${nixpkgs}" {
            config.allowUnfree = true;
            inherit system;
          };
        in
        {
          "main_pkg" =
            (pkgs.haskell.packages.ghc94.callCabal2nix
              "garn-pkg"

              (
                let
                  lib = pkgs.lib;
                  lastSafe = list:
                    if lib.lists.length list == 0
                    then null
                    else lib.lists.last list;
                in
                builtins.path
                  {
                    path = ./.;
                    name = "source";
                    filter = path: type:
                      let
                        fileName = lastSafe (lib.strings.splitString "/" path);
                      in
                      fileName != "flake.nix" &&
                      fileName != "garn.ts";
                  }
              )

              { })
            // {
              meta.mainProgram = "is-cached";
            }
          ;
        }
      );
      checks = forAllSystems (system:
        let
          pkgs = import "${nixpkgs}" {
            config.allowUnfree = true;
            inherit system;
          };
        in
        { }
      );
      devShells = forAllSystems (system:
        let
          pkgs = import "${nixpkgs}" {
            config.allowUnfree = true;
            inherit system;
          };
        in
        {
          "main" =
            (
              (
                let
                  expr =
                    (pkgs.haskell.packages.ghc94.callCabal2nix
                      "garn-pkg"

                      (
                        let
                          lib = pkgs.lib;
                          lastSafe = list:
                            if lib.lists.length list == 0
                            then null
                            else lib.lists.last list;
                        in
                        builtins.path
                          {
                            path = ./.;
                            name = "source";
                            filter = path: type:
                              let
                                fileName = lastSafe (lib.strings.splitString "/" path);
                              in
                              fileName != "flake.nix" &&
                              fileName != "garn.ts";
                          }
                      )

                      { })
                    // {
                      meta.mainProgram = "is-cached";
                    }
                  ;
                in
                (if expr ? env
                then expr.env
                else pkgs.mkShell { inputsFrom = [ expr ]; }
                )
              ).overrideAttrs (finalAttrs: previousAttrs: {
                nativeBuildInputs =
                  previousAttrs.nativeBuildInputs
                  ++
                  [ pkgs.haskell.packages.ghc94.cabal-install ];
              })
            ).overrideAttrs (finalAttrs: previousAttrs: {
              nativeBuildInputs =
                previousAttrs.nativeBuildInputs
                ++
                [
                  (pkgs.haskell-language-server.override {
                    dynamic = true;
                    supportedGhcVersions = [ "945" ];
                  })
                ];
            })
          ;
        }
      );
      apps = forAllSystems (system:
        let
          pkgs = import "${nixpkgs}" { inherit system; };
        in
        {
          "dev" = {
            "type" = "app";
            "program" = "${
      let
        dev = 
        (
        (
    let expr = 
    (pkgs.haskell.packages.ghc94.callCabal2nix
      "garn-pkg"
      
  (let
    lib = pkgs.lib;
    lastSafe = list :
      if lib.lists.length list == 0
        then null
        else lib.lists.last list;
  in
  builtins.path
    {
      path = ./.;
      name = "source";
      filter = path: type:
        let
          fileName = lastSafe (lib.strings.splitString "/" path);
        in
         fileName != "flake.nix" &&
         fileName != "garn.ts";
    })

      { })
      // {
        meta.mainProgram = "is-cached";
      }
  ;
    in
      (if expr ? env
        then expr.env
        else pkgs.mkShell { inputsFrom = [ expr ]; }
      )
    ).overrideAttrs (finalAttrs: previousAttrs: {
          nativeBuildInputs =
            previousAttrs.nativeBuildInputs
            ++
            [pkgs.haskell.packages.ghc94.cabal-install];
        })
      ).overrideAttrs (finalAttrs: previousAttrs: {
          nativeBuildInputs =
            previousAttrs.nativeBuildInputs
            ++
            [(pkgs.haskell-language-server.override {
        dynamic = true;
        supportedGhcVersions = [ "945" ];
      })];
        })
      ;
        shell = "runhaskell Main.hs";
        buildPath = pkgs.runCommand "build-inputs-path" {
          inherit (dev) buildInputs nativeBuildInputs;
        } "echo $PATH > $out";
      in
      pkgs.writeScript "shell-env"  ''
        #!${pkgs.bash}/bin/bash
        export PATH=$(cat ${buildPath}):$PATH
        ${dev.shellHook}
        ${shell} "$@"
      ''
    }";
          };
          "main" = {
            "type" = "app";
            "program" = "${
      let
        dev = pkgs.mkShell {};
        shell = "${
    (pkgs.haskell.packages.ghc94.callCabal2nix
      "garn-pkg"
      
  (let
    lib = pkgs.lib;
    lastSafe = list :
      if lib.lists.length list == 0
        then null
        else lib.lists.last list;
  in
  builtins.path
    {
      path = ./.;
      name = "source";
      filter = path: type:
        let
          fileName = lastSafe (lib.strings.splitString "/" path);
        in
         fileName != "flake.nix" &&
         fileName != "garn.ts";
    })

      { })
      // {
        meta.mainProgram = "is-cached";
      }
  }/bin/is-cached";
        buildPath = pkgs.runCommand "build-inputs-path" {
          inherit (dev) buildInputs nativeBuildInputs;
        } "echo $PATH > $out";
      in
      pkgs.writeScript "shell-env"  ''
        #!${pkgs.bash}/bin/bash
        export PATH=$(cat ${buildPath}):$PATH
        ${dev.shellHook}
        ${shell} "$@"
      ''
    }";
          };
        }
      );
    };
}
