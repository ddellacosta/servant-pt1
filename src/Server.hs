{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Server where

import Control.Monad.Except
import Data.Aeson.Types
import Database
import GHC.Conc
import Network.Wai.Handler.Warp
import Servant
import Types

instance ToJSON ClientInfo

type API = "clients" :> Get '[JSON] [ClientInfo]
--         :<|> "client" :> Get '[JSON] ClientInfo

server :: Env -> Server API
server env = liftIO $ (readTVarIO $ dbHandle env) >>= clients

api :: Proxy API
api = Proxy

app :: Env -> Application
app env = serve api (server env)
