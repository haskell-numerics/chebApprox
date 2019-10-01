let
  foo = self: super: {
    haskell = super.haskell // { packageOverrides =
      hself: hsuper: {
        accelerate = super.haskell.lib.dontCheck (
          hself.callCabal2nix "accelerate" (builtins.fetchGit {
            url = "git@github.com:AccelerateHS/accelerate.git";
            rev = "a7b685352330ebf7d8794aed64663a9ee92dcdab";
          }) {}
        );
        # accelerate = super.haskell.lib.dontCheck (hself.callPackage /home/sundials/accelerate { });
        accelerate-fft = super.haskell.lib.dontCheck (hself.callPackage /home/sundials/accelerate-fft { });
        accelerate-llvm = super.haskell.lib.dontCheck (hself.callPackage /home/sundials/accelerate-llvm/accelerate-llvm { });
        accelerate-llvm-native = super.haskell.lib.dontCheck (hself.callPackage /home/sundials/accelerate-llvm/accelerate-llvm-native { });
        accelerate-llvm-ptx = super.haskell.lib.dontCheck (hself.callPackage /home/sundials/accelerate-llvm/accelerate-llvm-ptx { });
        lens-accelerate = super.haskell.lib.dontCheck (hself.callPackage /home/sundials/lens-accelerate { });
      };
    };
  };
in

let
  pkgs  = import <nixpkgs> {
    config.allowUnfree = true;
    config.allowBroken = false;
    overlays = [ foo ];
  };
in

pkgs.haskellPackages.callPackage ./default.nix {
  accelerate             = pkgs.haskellPackages.accelerate;
  accelerate-llvm-native = pkgs.haskellPackages.accelerate-llvm-native;
  accelerate-fft         = pkgs.haskellPackages.accelerate-fft;
  lens-accelerate        = pkgs.haskellPackages.lens-accelerate;
}
