{-# LANGUAGE TemplateHaskell #-}

module Server where

import Control.Monad.Reader
import Database
import Katip
import Servant
import Types
import Network.Wai.Middleware.Cors

type API = "musicians" :> Get '[JSON] [MusicianInfo]
--         :<|> "musician" :> Get '[JSON] MusicianInfo

server :: (MonadIO a) => ServerT API (App a)
server = do
  cs <- runDb musicians
  _  <- $(logTM) InfoS "Hello world"
  return cs

api :: Proxy API
api = Proxy

nt :: Env -> App Handler a -> Handler a
nt env app = runReaderT (unApp app) env

app :: Env -> Application
app env = simpleCors $ serve api $ hoistServer api (nt env) server