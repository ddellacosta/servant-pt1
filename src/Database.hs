{-# LANGUAGE QuasiQuotes #-}

module Database where

import Control.Concurrent.STM (readTVarIO)
import Control.Lens (view)
import Control.Monad.IO.Class (MonadIO(liftIO))
import Control.Monad.Reader (MonadReader(ask), ReaderT, runReaderT)
import qualified Data.ByteString.Char8 as BS8
import Data.Text
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple.Migration
import Database.PostgreSQL.Simple.SqlQQ
import Database.PostgreSQL.Simple.Types
import Types

connectApp :: MonadIO m => DatabaseConfig -> m Connection
connectApp (DBConfig host db user password dir) =
  liftIO $ connectPostgreSQL $ BS8.pack $ unpack url
  where url = "host=" <> host <> " dbname=" <> db <> " user=" <> user <> " password=" <> password

migrate :: MonadIO m => FilePath -> Connection -> m (MigrationResult String)
migrate dir conn = do
  liftIO $ withTransaction conn $ runMigrations True conn
    [ MigrationInitialization
    , (MigrationDirectory dir)
    ]
 
validate :: MonadIO m => FilePath -> Connection -> m (MigrationResult String)
validate dir conn = do
  liftIO $ withTransaction conn $ runMigration $ MigrationContext
   (MigrationValidation (MigrationDirectory dir)) True conn

instance FromRow ClientInfo where
  fromRow = ClientInfo <$> field <*> field <*> field <*> field <*> (fromPGArray <$> field)

clients :: (MonadIO m, MonadReader Connection m) => m [ClientInfo]
clients = do
  conn <- ask
  clients <- liftIO $ query_ conn clientsQueryString
  pure clients

runDb :: (MonadIO m, MonadReader Env m) => ReaderT Connection m a -> m a
runDb dbAction = do
  tv <- view dbHandle
  dbConn <- liftIO $ readTVarIO tv
  runReaderT dbAction dbConn

clientsQueryString :: Query
clientsQueryString = [sql| select ci.client_info_id
                                , ci.client_name
                                , ci.client_email
                                , ci.client_age
                                , array_agg(cis.client_interest) as client_interested_in
                             from client_info ci
                                , client_info_interests cii
                                , client_interests cis
                            where ci.client_info_id = cii.client_info_id
                              and cii.client_interests_id = cis.client_interests_id
                         group by ci.client_info_id
                                , ci.client_name
                                , ci.client_email
                                , ci.client_age                                         |]
