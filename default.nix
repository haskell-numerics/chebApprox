{ mkDerivation, accelerate, accelerate-fft, accelerate-llvm-native
, base, Chart, Chart-cairo, Chart-diagrams, clock, diagrams-cairo
, diagrams-lib, formatting, hedgehog, HUnit, lens-accelerate
, stdenv, tasty, tasty-hedgehog, vector
}:
mkDerivation {
  pname = "chebApprox";
  version = "0.1.0.0";
  src = ./.;
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
}
