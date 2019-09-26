{ nixpkgs ? import <nixpkgs> { config.allowUnfree = true; config.allowBroken = true; }, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, accelerate, accelerate-fft
      , accelerate-llvm-native, base, Chart, Chart-cairo, Chart-diagrams
      , clock, diagrams-cairo, diagrams-lib, formatting, hedgehog, HUnit
      , lens-accelerate, stdenv, tasty, tasty-hedgehog, vector
      }:
      mkDerivation {
        pname = "chebApprox";
        version = "0.1.0.0";
        src = nixpkgs.fetchgit {
	  url = https://github.com/DeifiliaTo/chebApprox;
	  rev = "30f1b1d4ab33dfbcba061cdc3d6e224a0d1e7146";
          sha256 = "01w9yxx6djhgdhagdswkshdda6mkypvy0ajfrwyr0swrbkx6rrw5";
	  };
        isLibrary = true;
        isExecutable = true;
        libraryHaskellDepends = [
          accelerate accelerate-llvm-native base clock formatting hedgehog
          tasty tasty-hedgehog vector
        ];
        executableHaskellDepends = [
          accelerate accelerate-fft accelerate-llvm-native base Chart
          Chart-cairo Chart-diagrams diagrams-cairo diagrams-lib HUnit
          lens-accelerate
        ];
        homepage = "https://github.com/DeifiliaTo/chebApprox";
        description = "Function approximation";
        license = stdenv.lib.licenses.bsd3;
      };

  my-accelerate = pkgs.haskellPackages.accelerate.overrideAttrs (oldAttrs: rec {
    src = nixpkgs.fetchgit {
      url = https://github.com/tmcdonell/accelerate;
      rev = "a7b685352330ebf7d8794aed64663a9ee92dcdab";
      sha256 = "01w9yxx6djhgdhagdswkshdda6mkypvy0ajfrwyr0swrbkx6rrw5";
      };
    version = "1.3.0.0";
    doCheck = false;
  });

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  myHaskellPackages = haskellPackages.override {
    overrides = self: super: with pkgs.haskell.lib; {
      accelerate-llvm-native = dontCheck super.accelerate-llvm-native;
      accelerate-llvm-ptx    = dontCheck super.accelerate-llvm-ptx;
      accelerate-fft         = dontCheck super.accelerate-fft;
      accelerate             = my-accelerate;
    };
  };

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (myHaskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
