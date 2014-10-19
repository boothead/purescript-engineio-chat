module Main where

import Control.Monad.Eff
import Data.Either
import Data.Foreign
import Data.Foreign.Class
import Data.Function
import Data.String (trim)
import Debug.Trace
import Control.SocketIO
import qualified Control.Monad.JQuery as JQ
import Control.Monad.Identity
import Control.Monad.Trans
import Control.Monad.State.Trans
import Control.Monad.State.Class

import JQEffects

type UserName = String
type Message = String
type NConnected = Number

-- Messages
data AddUser = AddUser UserName
data NewMessage = NewMessage Message
data Said = Said { userName :: UserName, message :: Message }
type UserJoined = {
    username :: UserName
  , numUsers :: Number
  }

-- State
type Chat = { currentUser :: UserName, nChatting :: NConnected } 

newtype ChatState = ChatState Chat
unChat (ChatState cs) = cs

type EJQ a = forall eff. Eff (dom :: JQ.DOM | eff) a

loginPage = JQ.select ".login.page"
chatPage = JQ.select ".chat.page"
inputMessage = JQ.select ".inputMessage"

addParticipantsMessage msg = 
  let strMsg = case msg.numUsers of
                 1 -> "there's 1 participant"
                 n -> "there are " ++ (show n) ++ " participants"
  in trace strMsg

clean :: String -> EJQ String  
clean txt = JQ.create "<div />" >>= JQ.appendText txt >>= JQ.getText
  
type Interaction eff = StateT ChatState (Eff eff)


setUserName :: forall eff. Interaction (trace :: Trace, dom :: JQ.DOM | eff) Unit
setUserName = do
  name <- lift $ readString <$> (JQ.select ".usernameInput" >>= JQ.getValue)
  case trim <$> name of
     Left err -> return unit -- lift $ print err 
     Right nm -> modify $ \(ChatState s) -> ChatState { currentUser: nm, nChatting: s.nChatting }
  
-- loginUIAction = do
--    loginPage >>= fadeOut
--    chatPage >>= showJQ
--    -- loginPage >>= JQ.off "click"
--    inputMessage >>= focus
  
-- printOn :: forall eff. Socket -> Channel -> Eff (socket :: SocketIO, trace :: Trace |  eff) Unit
printOn s c = onMsg s c (trace <<< f)
  where f msg = case msg of
                  Left err -> "error: " ++ (show err)
                  Right msg -> "recieved: " ++  msg
--         print m = trace $ f m

connectAndOn :: forall eff. Eff (socket :: SocketIO, trace :: Trace | eff) Unit
connectAndOn = do
  s <- connect "http://localhost:8000"
  printOn s "error"
  printOn s "typing"
  emit s "typing"
  printOn s "connection"

main = connectAndOn
-- main :: Unit
-- main = do
--   s <- connect
--   printOn s "test"
