import * as garn from "https://garn.io/ts/v0.0.10/mod.ts";
import { nixRaw } from "https://garn.io/ts/v0.0.10/nix.ts";

export const main = garn.haskell
  .mkHaskellProject({
    description: "is-cached",
    executable: "is-cached",
    compiler: "ghc94",
    src: ".",
  })
  .withDevTools([
    garn.mkPackage(nixRaw`
      (pkgs.haskell-language-server.override {
        dynamic = true;
        supportedGhcVersions = [ "945" ];
      })
    `),
  ]);

export const dev: garn.Executable = main.shell`runhaskell Main.hs`;
