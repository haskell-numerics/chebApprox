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
    import qualified Data.Vector as V


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
    
    vec :: V.Vector (Double)       --  need V.Vector in order to specify the type (normal vector and not acc)
    vec = V.fromList [1, 2, 4]      -- V.length = 3
     

    aux :: (Double -> Double) -> Double -> (Double, Double) -> [(Double, Double)] -> [(Double, Double)]
    aux f h (xl, xr) acc =
        if (xl P.> xr) then acc
        else 
            if ((f xl) * (f (xl + h)) P.< 0)
                then aux f h ((xl +h), xr) ((xl, (xl+h)):acc)
                else aux f h ((xl +h), xr) acc

        -- Bisection
    absFloat :: Float -> Float
    absFloat x = if (x P.< 0.0) then (-1.0*x) else x
                
    close :: Float -> Bool
    close x = (absFloat x) P.< 0.0001 
                
    -- Function definition: expect a function f x that goes from fl -> float, 
    -- will output another float
    bisection :: (Float -> Float)-> Float -> Float -> Float
    bisection f xl xr = 
     let mid = (xl + xr)/2.0 in
     let f_mid = f mid in
      if close f_mid then mid
      	else
      		if f_mid P.< 0.0 then bisection f mid xr
      			else bisection f xl mid
        