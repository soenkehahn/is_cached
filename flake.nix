{
  inputs = {
    garnix-lib.url = "github:garnix-io/garnix-lib";
    haskell-module.url = "github:garnix-io/haskell-module";
  };
  outputs = inputs: inputs.garnix-lib.lib.mkModules {
    modules = [
      inputs.haskell-module.garnixModules.default
    ];
    config = { pkgs, ... }: {
      haskell.default = {
        src = ./.;
      };
    };
  };
}
