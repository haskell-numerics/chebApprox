{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DeriveAnyClass  #-}
{-# LANGUAGE DeriveGeneric   #-}
{-# LANGUAGE PatternSynonyms #-}

module  ChebMath
where
    import Prelude as P
    import Data.Array.Accelerate as A
    import Data.Array.Accelerate.Debug as A
    import Data.Array.Accelerate.Interpreter as I
    import Data.Array.Accelerate.LLVM.Native as CPU
    import Data.Array.Accelerate.Data.Maybe


    computeVal :: Exp Double -> Exp Double -> Exp Int -> Exp Double
    computeVal x coeff rep = 
      coeff * (x A.^ rep)
 
    -- given pol and point, compute
    evalPol :: Acc (Vector Double) -> Exp Double -> Exp Double
    evalPol pol x = 
      let I1 n   = shape pol
          zipped = A.zipWith (computeVal x) pol (enumFromN (lift (Z :. (n+1))) 0)
      in
         the (A.fold (+) (0) zipped) -- (Exp Double)

    derivative :: Acc (Vector Double) -> Acc (Vector Double)
    derivative pol = 
        let I1 n = shape pol
        in
        A.zipWith (*) (A.take (n-1) pol) (enumFromN (lift (Z:.(n-1))) 1)

    integrateCoeff :: Exp Double -> Exp Double -> Exp Double
    integrateCoeff pol coeff = pol/coeff
    
    integrate :: Acc (Vector Double) -> Acc (Vector Double)
    integrate pol =
        let I1 n = shape pol
        in
        A.zipWith (integrateCoeff) pol (enumFromN (lift (Z:.(n))) 1)
    
    area :: Acc (Vector Double) -> Exp Double -> Exp Double -> Exp Double
    area pol lBound rBound =
        let integrated = integrate pol
            rightCalc  = evalPol pol rBound
            leftCalc   = evalPol pol lBound
        in
            rightCalc - leftCalc      
    