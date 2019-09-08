module Main where

import Affjax as AX
import Affjax.ResponseFormat (string)
import Data.Const
import Data.Either (Either(..), either)
import Data.List.Types (NonEmptyList)
import Data.Maybe (Maybe(..), fromJust, maybe)
import Data.Symbol (SProxy(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Console (log)
import Foreign (ForeignError)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.VDom.Driver (runUI)
import Prelude
import Simple.JSON as JSON

data Action
  = Initialize
  | Finalize

type State =
  { loading :: Boolean
  , username :: String
  , musicians :: Maybe (Array MusicianInfo)
  }

type MusicianInfo =
  { musicianInfoId :: Int
  , musicianName :: String
  , musicianDOB :: String -- Day
  , musicianDOD :: String -- Day
  , musicianCharacteristics :: Array String
  }

initialState :: State
initialState =
  { loading: true
  , username: "Dave"
  , musicians: Nothing
  }

showMusician :: forall w i. MusicianInfo -> HH.HTML w i
showMusician m = HH.ul_
                 [ HH.li [] [ (HH.text m.musicianName) ]
                 , HH.li [] [ (HH.text m.musicianDOB) ]
                 , HH.li [] [ (HH.text m.musicianDOD) ]
                 , HH.li [] [ (HH.text $ show m.musicianCharacteristics) ]
                 ]

showMusicians :: forall w i. Maybe (Array MusicianInfo) -> Array (HH.HTML w i)
showMusicians (Just ms) = showMusician <$> ms
showMusicians Nothing = [ HH.span [] [ HH.text "" ] ]

component :: forall f. H.Component HH.HTML f Unit Void Aff
component =
  H.mkComponent
    { initialState: const initialState 
    , render
    , eval: H.mkEval (H.defaultEval
        { handleAction = handleAction
        , initialize = Just Initialize
        , finalize = Just Finalize
        })
    }
  where

  render :: State -> H.ComponentHTML Action () Aff
  render state =
    HH.div_ (showMusicians state.musicians)
      
  handleAction :: forall o. Action -> H.HalogenM State Action () o Aff Unit
  handleAction Initialize = do
    H.liftEffect $ log "Initialize"
    musiciansResponse <- H.liftAff $ AX.get string "http://localhost:8081/musicians"
    let musicians = handleResponse $ JSON.readJSON $ either (const "") identity musiciansResponse.body -- BAD
    H.liftEffect $ log ("Musicians: " <> show musicians)
    _ <- H.modify (_ { loading = false
                     , username = "it's alive"
                     , musicians = musicians })
    pure unit

  handleAction Finalize = do
    H.liftEffect $ log "Finalize"
    pure unit

handleResponse :: Either (NonEmptyList ForeignError) (Array MusicianInfo) -> Maybe (Array MusicianInfo)
handleResponse r = do
  case r of
    Left err -> Nothing
    Right something -> Just something

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI component unit body
