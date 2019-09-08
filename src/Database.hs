{-# LANGUAGE QuasiQuotes #-}

module Database where

import Control.Concurrent.STM (readTVarIO)
import Control.Lens (view)
import Control.Monad.IO.Class (MonadIO(liftIO))
import Control.Monad.Reader (MonadReader(ask), ReaderT, runReaderT)
import qualified Data.ByteString.Char8 as BS8
import Data.Text
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.Migration
import Database.PostgreSQL.Simple.SqlQQ
import Types

connectApp :: MonadIO m => DatabaseConfig -> m Connection
connectApp (DBConfig host db user password _) =
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

musicians :: (MonadIO m, MonadReader Connection m) => m [MusicianInfo]
musicians = do
  conn <- ask
  musicians <- liftIO $ query_ conn musiciansQueryString
  pure musicians

runDb :: (MonadIO m, MonadReader Env m) => ReaderT Connection m a -> m a
runDb dbAction = do
  tv <- view dbHandle
  dbConn <- liftIO $ readTVarIO tv
  runReaderT dbAction dbConn

musiciansQueryString :: Query
musiciansQueryString = [sql| select mi.musician_info_id
                                  , mi.musician_name
                                  , mi.musician_dob
                                  , mi.musician_dod
                                  , array_agg(mc.musician_characteristic)
                           from musician_info mi
                           left join (musician_info_characteristic mic
                                      join musician_characteristic mc
                                      using (musician_characteristic_id))
                           using (musician_info_id)
                           group by mi.musician_info_id
                                  , mi.musician_name
                                  , mi.musician_dob
                                  , mi.musician_dod |]
