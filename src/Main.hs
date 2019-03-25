{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Monoid
import Data.Text (unpack)
import Database
import Dhall
import GHC.Conc
import GHC.Natural
import Katip
import Network.Wai.Handler.Warp
import Prelude hiding (init)
import Server
import System.IO
import Types

importConfig :: IO Config
importConfig = input auto "./config.dhall"
 
init :: IO Env
init = do
  fileScribe   <- mkFileScribe "./servant-pt1.log" InfoS V3
  stdoutScribe <- mkHandleScribe ColorIfTerminal stdout DebugS V3
  cfg          <- importConfig
  dbConn       <- connectApp $ dbConfig cfg
  _            <- migrate (unpack $ dir $ dbConfig cfg) dbConn
  dbConnTVar   <- newTVarIO dbConn
  logEnv       <- initLogEnv "MyApp" "dev"
  logEnv'      <- registerScribe "file" fileScribe defaultScribeSettings logEnv
  logEnv''     <- registerScribe "stdout" stdoutScribe defaultScribeSettings logEnv'
  return $ Env cfg dbConnTVar (mempty :: Namespace) (mempty :: LogContexts) logEnv''

main :: IO ()
main = do
  env <- init
  let wwwPort = (naturalToInt $ port $ wwwConfig $ _config env)
  run wwwPort (app env)
