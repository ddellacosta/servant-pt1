{-# LANGUAGE TemplateHaskell
           , DuplicateRecordFields
           , FunctionalDependencies
           , MultiParamTypeClasses
           , TypeSynonymInstances
           , FlexibleInstances
#-}

module Types where

import Control.Concurrent.STM (TVar)
import Control.Lens
import Control.Lens.TH ()
import Control.Monad.Reader
import Data.Aeson.Types
import Data.Text
import Data.Time
import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple (Connection)
import Database.PostgreSQL.Simple.Types
import Dhall (Generic, Interpret, Natural)
import Katip as K
import Servant ()
import TextShow
import TextShow.Generic

-- import Numeric.Natural

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
} deriving newtype (Functor, Applicative, Monad, MonadIO, MonadReader Env) -- all required by Katip

instance (MonadIO m) => K.Katip (App m) where
  getLogEnv = view logEnv
  localLogEnv f (App m) = App (local (over logEnv f) m)

instance (MonadIO m) => KatipContext (App m) where
  getKatipContext = view logContext
  localKatipContext f (App m) = App (local (over logContext f) m)
  getKatipNamespace = view logNamespace
  localKatipNamespace f (App m) = App (local (over logNamespace f) m)


-- Business Model

data MusicianInfo = MusicianInfo {
    musicianInfoId :: Int
  , musicianName :: Text
  , musicianDOB :: Day
  , musicianDOD :: Day
  , musicianCharacteristics :: [Text]
  } deriving (Generic)

instance FromRow MusicianInfo where
  fromRow = MusicianInfo <$> field <*> field <*> field <*> field <*> (fromPGArray <$> field)

instance ToJSON MusicianInfo
