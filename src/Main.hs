{-# LANGUAGE DeriveGeneric, DerivingVia #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text (unpack)
import Database
import Dhall
import GHC.Conc
import GHC.Natural
import Network.Wai.Handler.Warp
import Prelude hiding (init)
import Server
import Types

importConfig :: IO Config
importConfig = input auto "./config.dhall"
 
init :: IO Env
init = do
  cfg        <- importConfig
  dbConn     <- connectApp $ dbConfig cfg
  _          <- migrate (unpack $ dir $ dbConfig cfg) dbConn
  dbConnTVar <- newTVarIO dbConn
  return $ Env cfg dbConnTVar

main :: IO ()
main = do
  env <- init
  let wwwPort = (naturalToInt $ port $ wwwConfig $ config env)
  run wwwPort (app env)
