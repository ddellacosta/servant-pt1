{-# LANGUAGE DeriveGeneric, DerivingVia #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad.Reader
import Data.Text (unpack)
import Database
import Dhall
import GHC.Conc
import Network.Wai.Handler.Warp
import Prelude hiding (init)
import Server
import Types

importConfig :: IO Config
importConfig = input auto "./config.dhall"
 
doApp :: App ()
doApp = do
  env <- ask
  liftIO $ run 8081 (app env)

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
 runReaderT doApp env
