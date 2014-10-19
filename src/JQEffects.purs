module JQEffects where

import Control.Monad.Eff
import qualified Control.Monad.JQuery as JQ
-- import Control.Monad.JQuery (JQuery)

foreign import jqEffect 
  "function jqEffect(meth) { \
  \  return function(ob) { \
  \    return function () { \
  \      return ob[meth](); \
  \    }; \
  \  }; \
  \}" :: forall eff. String -> JQ.JQuery -> Eff (dom :: JQ.DOM | eff) JQ.JQuery
  
fadeOut = jqEffect "fadeout"
showJQ = jqEffect "show"
focus = jqEffect "focus"
