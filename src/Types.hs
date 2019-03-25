{-# LANGUAGE DeriveGeneric, DerivingVia, GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Types where

import Control.Lens
import Control.Lens.TH
import Control.Monad.Reader
import Database.PostgreSQL.Simple (Connection)
import Dhall
import GHC.Conc
import Katip as K
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
    _config :: Config
  , _dbHandle :: !(TVar Connection)
  -- Katip config
  , _logNamespace :: K.Namespace
  , _logContext :: K.LogContexts
  , _logEnv :: K.LogEnv
  }

makeClassy ''Env

newtype App m a = App {
  unApp :: ReaderT Env m a
} deriving (Functor, Applicative, Monad, MonadIO, MonadReader Env) -- all necessary for Katip

instance (MonadIO m) => K.Katip (App m) where
  getLogEnv = view logEnv
  localLogEnv f (App m) = App (local (over logEnv f) m)

instance (MonadIO m) => KatipContext (App m) where
  getKatipContext = view logContext
  localKatipContext f (App m) = App (local (over logContext f) m)
  getKatipNamespace = view logNamespace
  localKatipNamespace f (App m) = App (local (over logNamespace f) m)


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
