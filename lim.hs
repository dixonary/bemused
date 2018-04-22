this = kt ++ phi
    where kt = take 2 "hentai"
                ++ "llo worl"
          phi = fst corl
          corl = splitAt 1 "deny"

wait = please "no" ++ why 
    where please = \x->"hi"
          why = take 6
                " y'all love limericks" 
-- now run this in ghci
