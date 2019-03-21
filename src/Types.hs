{-# LANGUAGE DeriveGeneric, DerivingVia #-}

module Types where

import Control.Monad.Reader
import Database.PostgreSQL.Simple (Connection)
import Dhall
import GHC.Conc
import Servant
import TextShow
import TextShow.Generic


-- Configuration

data DatabaseConfig = DBConfig {
    host :: Text
  , db :: Text
  , user :: Text
  , password :: Text
  , dir :: Text
  } deriving (Show, Generic)
    deriving TextShow via FromGeneric DatabaseConfig

instance Interpret DatabaseConfig

data WWWConfig = WWWConfig {
    port :: Natural
  } deriving (Show, Generic)
    deriving TextShow via FromGeneric WWWConfig

instance Interpret WWWConfig

data Config = Config {
    dbConfig  :: DatabaseConfig
  , wwwConfig :: WWWConfig
  } deriving (Show, Generic)
    deriving TextShow via FromGeneric Config

instance Interpret Config


-- App and App State

data Env = Env {
    config :: Config
  , dbHandle :: !(TVar Connection)
  } -- deriving (Show, Generic)
    -- deriving TextShow via FromGeneric Env

type App = ReaderT Env Handler



-- Business Model

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
