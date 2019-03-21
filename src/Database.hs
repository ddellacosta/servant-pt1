{-# LANGUAGE DeriveGeneric, DeriveAnyClass #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Database where

import qualified Data.ByteString.Char8 as BS8
import Data.Text
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple.Migration
import Database.PostgreSQL.Simple.SqlQQ
import Database.PostgreSQL.Simple.Types
import Types

connectApp :: DatabaseConfig -> IO Connection
connectApp (DBConfig host db user password dir) = connectPostgreSQL $ BS8.pack $ unpack url
  where url = "host=" <> host <> " dbname=" <> db <> " user=" <> user <> " password=" <> password

migrate :: FilePath -> Connection -> IO (MigrationResult String)
migrate dir conn = do
  withTransaction conn $ runMigrations True conn
    [ MigrationInitialization
    , (MigrationDirectory dir)
    ]
 
validate :: FilePath -> Connection -> IO (MigrationResult String)
validate dir conn = do
  withTransaction conn $ runMigration $ MigrationContext
   (MigrationValidation (MigrationDirectory dir)) True conn

instance FromRow ClientInfo where
  fromRow = ClientInfo <$> field <*> field <*> field <*> field <*> (fromPGArray <$> field)

clients :: Connection -> IO [ClientInfo]
clients conn = do
  clients <- query_ conn clientsQueryString
  return clients

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
