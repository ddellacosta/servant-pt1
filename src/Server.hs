{-# LANGUAGE TemplateHaskell #-}

module Server where

import Control.Concurrent.STM (readTVarIO)
import Control.Lens
import Control.Monad.Reader
import Data.Aeson.Types
import Database
import Katip
import Servant
import Types

instance ToJSON ClientInfo

type API = "clients" :> Get '[JSON] [ClientInfo]
--         :<|> "client" :> Get '[JSON] ClientInfo

server :: (MonadIO a) => ServerT API (App a)
server = do
  cs <- runDb clients
  _  <- $(logTM) InfoS "Hello world"
  return cs

api :: Proxy API
api = Proxy

nt :: Env -> App Handler a -> Handler a
nt env app = runReaderT (unApp app) env

app :: Env -> Application
app env = serve api $ hoistServer api (nt env) server
