{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Oczor.Converter.CodeGenAst (module Oczor.Converter.CodeGenAst) where

import Data.Functor.Foldable.TH
import Data.Functor.Foldable
import ClassyPrelude
import Oczor.Utl

type Name = String

data Lits =
  LitNull |
  LitBool Bool |
  LitChar Char |
  LitDouble Double |
  LitInt Int |
  LitString String
  deriving (Eq, Ord, Show)

data Ast =
  None |
  Lit Lits |
  UniqObject String |
  Ident Name |
  NotEqual Ast Ast |
  Operator String [Ast] |
  Equal Ast Ast |
  Var Name Ast |
  Set Ast Ast |
  Throw String |
  Scope [Ast] Ast |
  StmtList [Ast] |
  BoolAnds [Ast] |
  Array [Ast] |
  Return Ast |
  HasField Ast Name |
  Label Name Ast |
  Field Ast Name |
  ConditionOperator Ast Ast Ast |
  Code String |
  Call Ast [Ast] |
  Parens Ast |
  If Ast [Ast] [Ast] |
  Object [(Name, Ast)] |
  Function [String] [Ast]
  deriving (Show, Eq, Ord)

makeBaseFunctor ''Ast

scopeToFunc (ScopeF x y) = if onull x then y else CallF (Parens (Function [] (x ++ [ReturnF (embed y)] <&> embed))) []
  
-- pattern Scope x <- Function _ x

getVarName (Var x _) = Just x
getVarName _ = Nothing

isFunction Function{} = True
isFunction _ = False

astToList (StmtList x) = x
astToList x = [x]

litString x = Lit $ LitString x

setField obj label expr = Set (Field obj label) expr

emptyObject = Object []

containsIdents :: [String] -> Ast -> [String]
containsIdents list = cata $ \case
  IdentF x | oelem x list -> [x]
  x -> ffold x
