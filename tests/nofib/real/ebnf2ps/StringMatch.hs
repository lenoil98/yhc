--                            -*- Mode: Haskell -*- 
-- Copyright 1994 by Peter Thiemann
-- StringMatch.hs --- translate regular expression into a string match function
-- Author          : Peter Thiemann
-- Created On      : Thu Dec 23 11:16:26 1993
-- Last Modified By: Peter Thiemann
-- Last Modified On: Thu Dec 23 12:32:39 1993
-- Update Count    : 18
-- Status          : Unknown, Use with caution!
-- 
-- $Locker:  $
-- $Log: StringMatch.hs,v $
-- Revision 1.1  2005/09/12 12:51:55  shackell
-- addded ebnf2ps
--
-- Revision 1.1.1.1  2004/11/11 11:55:51  shackell
-- no message
--
-- Revision 1.1  2004/08/05 11:11:58  malcolm
-- Add a regression testsuite for the nhc98 compiler.  It isn't very good,
-- but it is better than nothing.  I've been using it for about four years
-- on nightly builds, so it's about time it entered the repository!  It
-- includes a slightly altered version of the nofib suite.
-- Instructions are in the README.
--
-- Revision 1.1  1996/01/08 20:02:33  partain
-- Initial revision
--
-- Revision 1.1  1994/03/15  15:34:53  thiemann
-- Initial revision
--
-- 

module StringMatch {-(stringMatch)-} where

import Parsers

infixr 8 +.+ , +.. , ..+
infixl 7 <<< , <<*
infixr 6 |||

(+.+) = thn
(..+) = xthn
(+..) = thnx
(|||) = alt
(<<<) = using
(<<*) = using2
lit   :: Eq a => a -> Parser a a
lit   = literal
star  = rpt
anyC  = satisfy (const True)
butC cs = satisfy (not.(`elem` cs))
noC   "" = [("","")]
noC   _  = []
unitL = \x -> [x]

--
-- grammar for regular expressions:
--
{-
  Atom		= character | "\\" character | "." | "\\(" Regexp "\\) .
  ExtAtom	= Atom ["*" | "+" | "?"] .
  Factor	= ExtAtom + .
  Regexp	= Factor / "\\|" ["$"].
-}

type ParseRegexp = Parser Char String

rrAtom :: Parser Char ParseRegexp
rrAtom =
     lit '\\' ..+ lit '(' ..+ rrRegexp +.. lit '\\' +.. lit ')'
 ||| 
   ( lit '\\' ..+ butC "|()"	<<< lit
 ||| lit '.'			<<< const anyC
 ||| butC "\\.$"		<<< lit
 ||| lit '$' `followedBy` anyC	<<< lit
   ) <<< (<<< unitL)

rrExtAtom :: Parser Char ParseRegexp
rrExtAtom =
     rrAtom +.+ opt (lit '*' <<< const star
		|||  lit '+' <<< const plus
		|||  lit '?' <<< const opt)
	<<< helper
     where
       helper (ea, []) = ea
       helper (ea, [f]) = f ea <<< concat

rrFactor :: Parser Char ParseRegexp
rrFactor =
     plus rrExtAtom	<<< foldr (\ p1 p2 -> p1 +.+ p2 <<* (++)) (succeed "")

rrRegexp =
     rrFactor +.+ star (lit '\\' ..+ lit '|' ..+ rrFactor) +.+ opt (lit '$')
	<<< helper
     where
       helper (ef, (efs, [])) = foldl (|||) ef efs +.. star anyC
       helper (ef, (efs, _ )) = foldl (|||) ef efs +.. noC

regexp0 :: Parser Char (Parser Char String)
regexp0 =
     lit '^' ..+ rrRegexp
 ||| rrRegexp
	 <<< (\p -> let p' = p ||| anyC ..+ p' in p')

stringMatch :: String -> String -> Bool
stringMatch re subject = wellformed && not (null (filter (null . snd) (match subject)))
    where matches      = regexp0 re
	  wellformed   = not (null matches) && null rest
	  (match,rest) = head matches 
