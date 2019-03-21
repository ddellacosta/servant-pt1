{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Server where

import Control.Monad.Reader
import Data.Aeson.Types
import Database
import GHC.Conc
import Servant
import Types

instance ToJSON ClientInfo

type API = "clients" :> Get '[JSON] [ClientInfo]
--         :<|> "client" :> Get '[JSON] ClientInfo

server :: ServerT API App
server = do
  env    <- ask
  dbConn <- liftIO $ (readTVarIO $ dbHandle env)
  cs     <- liftIO $ clients dbConn
  return cs

api :: Proxy API
api = Proxy

nt :: Env -> App a -> Handler a
nt env app = runReaderT app env

app :: Env -> Application
app env = serve api $ hoistServer api (nt env) server
