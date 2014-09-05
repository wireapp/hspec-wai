{-# LANGUAGE OverloadedStrings #-}
module Test.Hspec.Wai.RequestSpec (main, spec) where

import Test.Hspec
import Test.Hspec.Wai

import Data.ByteString (ByteString)
import qualified Data.ByteString.Lazy as BL

import Network.HTTP.Types
import Network.Wai

main :: IO ()
main = hspec spec

expectMethod :: Method -> Application
expectMethod method req respond = do
  requestMethod req `shouldBe` method
  respond $ responseLBS status200 [] ""

expectRequest :: Method -> ByteString -> ByteString -> [Header] -> Application
expectRequest method path body headers req respond = do
  requestMethod req `shouldBe` method
  rawPathInfo req `shouldBe` path
  requestHeaders req `shouldBe` headers
  rawBody <- requestBody req
  rawBody `shouldBe` body
  respond $ responseLBS status200 [] ""

spec :: Spec
spec = do
  describe "get" $ with (return $ expectMethod methodGet) $
    it "sends a get request" $
      get "/" `shouldRespondWith` 200
  describe "post" $ with (return $ expectMethod methodPost) $
    it "sends a post request" $
      post "/" "" `shouldRespondWith` 200
  describe "put" $ with (return $ expectMethod methodPut) $
    it "sends a put request" $
      put "/" "" `shouldRespondWith` 200
  describe "delete" $ with (return $ expectMethod methodDelete) $
    it "sends a delete request" $
      delete "/" `shouldRespondWith` 200
  describe "request" $ with (return $ expectRequest methodGet "/foo" body accept) $
    it "sends method, path, headers, and body" $
      request methodGet "/foo" accept (BL.fromChunks [body]) `shouldRespondWith` 200

  where
    accept = [(hAccept, "application/json")]
    body = "{\"foo\": 1}"
