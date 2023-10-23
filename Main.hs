{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE ViewPatterns #-}

import Control.Lens ((.~), (^.))
import Data.Function
import Development.Shake
import Network.Wreq
import System.Exit (ExitCode (ExitFailure), exitWith)
import WithCli

main :: IO ()
main = withCli $ \(attribute :: String) -> do
  Stdout (json :: String) <- cmd "nix show-derivation" attribute
  StdoutTrim outPath <- cmd (Stdin json) "jq -r" ["to_entries[0].value.outputs.out.path"]
  let hash = take 32 . drop (length "/nix/store/") $ outPath
  putStrLn $ "hash: " <> hash
  response <- getWith (defaults & checkResponse .~ (Just (\_ _ -> return ()))) ("https://cache.garnix.io/" <> hash <> ".narinfo")
  case response ^. responseStatus . statusCode of
    200 -> putStrLn "cache hit"
    404 -> do
      putStrLn "cache miss"
      exitWith $ ExitFailure 1
    x -> error $ "unhandled status: " <> show x
