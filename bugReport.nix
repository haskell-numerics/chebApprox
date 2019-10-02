let
  foo = self: super: {
    haskell = super.haskell // { packageOverrides =
      hself: hsuper: {
        accelerate = super.haskell.lib.dontCheck (
          hself.callCabal2nix "accelerate" (builtins.fetchGit {
            url = "https://github.com/AccelerateHS/accelerate.git";
            rev = "a7b685352330ebf7d8794aed64663a9ee92dcdab";
          }) {}
        );
        accelerate-llvm = super.haskell.lib.dontCheck (hself.callPackage /home/sundials/accelerate-llvm/accelerate-llvm { });
        # accelerate-llvm = super.haskell.lib.dontCheck (
        #   hself.callCabal2nix "accelerate-llvm" (builtins.fetchGit {
        #     url = "https://github.com/AccelerateHS/accelerate-llvm";
        #     rev = "1680d3fdb34073d2cc25c265968a695525bc1bf2";
        #   }) { subpath = "accelerate-llvm"; }
        # );
        accelerate-llvm-ptx = super.haskell.lib.dontCheck (hself.callPackage /home/sundials/accelerate-llvm/accelerate-llvm-ptx { });
        # accelerate-llvm-ptx = super.haskell.lib.dontCheck (
        #   hself.callCabal2nix "accelerate-llvm-ptx" (builtins.fetchGit {
        #     url = "https://github.com/AccelerateHS/accelerate-llvm";
        #     rev = "1680d3fdb34073d2cc25c265968a695525bc1bf2";
        #   }) { subpath = "accelerate-llvm-ptx"; }
        # );
        accelerate-llvm-native = super.haskell.lib.dontCheck (hself.callPackage /home/sundials/accelerate-llvm/accelerate-llvm-native { });
        # accelerate-llvm-native = super.haskell.lib.dontCheck (
        #   hself.callCabal2nix "accelerate-llvm-native" (builtins.fetchGit {
        #     url = "https://github.com/AccelerateHS/accelerate-llvm";
        #     rev = "1680d3fdb34073d2cc25c265968a695525bc1bf2";
        #   }) { subpath = "accelerate-llvm-native"; }
        # );
        accelerate-fft = super.haskell.lib.dontCheck (
          hself.callCabal2nix "accelerate-fft" (builtins.fetchGit {
            url = "https://github.com/AccelerateHS/accelerate-fft";
            rev = "24de1074001142bf02009ed36479dc9e8e045c61";
          }) {}
        );
        lens-accelerate = super.haskell.lib.dontCheck (
          hself.callCabal2nix "lens-accelerate" (builtins.fetchGit {
            url = "https://github.com/tmcdonell/lens-accelerate";
            rev = "b74eb8098735b1ad6cff3c5655af03d3f29b9f8e";
          }) {}
        );
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
