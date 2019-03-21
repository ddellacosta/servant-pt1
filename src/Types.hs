{-# LANGUAGE DeriveGeneric, DerivingVia #-}

module Types where

import Control.Monad.Reader
import Database.PostgreSQL.Simple (Connection)
import Dhall
import GHC.Conc
import TextShow
import TextShow.Generic

type App = ReaderT Env IO

data DatabaseConfig = DB {
    host :: Text
  , db :: Text
  , user :: Text
  , password :: Text
  , dir :: Text
  } deriving (Show, Generic)
    deriving TextShow via FromGeneric DatabaseConfig

instance Interpret DatabaseConfig

data Config = Config {
  dbConfig  :: DatabaseConfig
  } deriving (Show, Generic)
    deriving TextShow via FromGeneric Config

instance Interpret Config

data Env = Env {
    config :: Config
  , dbHandle :: !(TVar Connection)
  } -- deriving (Show, Generic)
    -- deriving TextShow via FromGeneric Env

data Position = Position
  { xCoord :: Int
  , yCoord :: Int
  } deriving (Generic)

data ClientInfo = ClientInfo
  { clientInfoId :: Int
  , clientName :: Text
  , clientEmail :: Text
  , clientAge :: Int
  , clientInterestedIn :: [Text]
  } deriving (Generic)

data Email = Email
  { from :: Text
  , to :: Text
  , subject :: Text
  , body :: Text
  } deriving (Generic)
