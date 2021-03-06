{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies      #-}

module Modules.Defaults where

import           Data.ByteString        (ByteString,pack)
import qualified Data.ByteString        as BS
import           Data.Typeable

import           Test.Framework         (Test,testGroup)

import           Raaz.Test              ()
import           Raaz.Test.Cipher
import           Raaz.Test.Gadget       (testGadget)
import           Raaz.Primitives
import           Raaz.Primitives.Cipher


import           Raaz.Cipher.AES.Type

import           Modules.Block.Ref      ()


testKey128 :: ByteString
testKey128 =  pack [0x2b,0x7e,0x15,0x16
                   ,0x28,0xae,0xd2,0xa6
                   ,0xab,0xf7,0x15,0x88
                   ,0x09,0xcf,0x4f,0x3c
                   ,0x00,0x01,0x02,0x03
                   ,0x04,0x05,0x06,0x07
                   ,0x08,0x09,0x0A,0x0B
                   ,0x0C,0x0D,0x0E,0x0F]

testKey192 :: ByteString
testKey192 =  pack [0x8e,0x73,0xb0,0xf7
                   ,0xda,0x0e,0x64,0x52
                   ,0xc8,0x10,0xf3,0x2b
                   ,0x80,0x90,0x79,0xe5
                   ,0x62,0xf8,0xea,0xd2
                   ,0x52,0x2c,0x6b,0x7b
                   ,0x00,0x01,0x02,0x03
                   ,0x04,0x05,0x06,0x07
                   ,0x08,0x09,0x0A,0x0B
                   ,0x0C,0x0D,0x0E,0x0F]


testKey256 :: ByteString
testKey256 =  pack [0x60,0x3d,0xeb,0x10
                   ,0x15,0xca,0x71,0xbe
                   ,0x2b,0x73,0xae,0xf0
                   ,0x85,0x7d,0x77,0x81
                   ,0x1f,0x35,0x2c,0x07
                   ,0x3b,0x61,0x08,0xd7
                   ,0x2d,0x98,0x10,0xa3
                   ,0x09,0x14,0xdf,0xf4
                   ,0x00,0x01,0x02,0x03
                   ,0x04,0x05,0x06,0x07
                   ,0x08,0x09,0x0A,0x0B
                   ,0x0C,0x0D,0x0E,0x0F]


cportableVsReference :: ( CipherGadget g1
                        , CipherGadget g2
                        , (PrimitiveOf (g1 Encryption) ~ PrimitiveOf (g2 Encryption))
                        , (PrimitiveOf (g1 Decryption) ~ PrimitiveOf (g2 Decryption))
                        , Initializable (PrimitiveOf (g1 Encryption))
                        , Initializable (PrimitiveOf (g1 Decryption))
                        , Eq (PrimitiveOf (g1 Encryption))
                        , Eq (PrimitiveOf (g1 Decryption)))
                      => (g1 Encryption) -> (g2 Encryption) -> ByteString -> [Test]
cportableVsReference ge1 ge2 iv' =
  [ testGadget ge1 ge2 (getIV iv) "CPortable vs Reference Encryption"
  , testGadget (gadD ge1) (gadD ge2) (getIV iv) "CPortable vs Reference Decryption"]
  where
    getPrim :: (Gadget (g Encryption)) => g Encryption -> PrimitiveOf (g Encryption)
    getPrim _ = undefined
    iv = BS.take (fromIntegral $ ivSize $ getPrim ge1) iv'
    gadD :: g Encryption -> g Decryption
    gadD _ = undefined

testsDefault m s128 s192 s256 =
      [ testGroup ("AES128 " ++ mode ++ " Reference") $ (testStandardCiphers (pr128 m) s128 "")
      , testGroup ("AES192 " ++ mode ++ " Reference") $ (testStandardCiphers (pr192 m) s192 "")
      , testGroup ("AES256 " ++ mode ++ " Reference") $ (testStandardCiphers (pr256 m) s256 "")
      , testGroup ("AES128 " ++ mode ++ " CPortable") $ (testStandardCiphers (pc128 m) s128 "")
      , testGroup ("AES192 " ++ mode ++ " CPortable") $ (testStandardCiphers (pc192 m) s192 "")
      , testGroup ("AES256 " ++ mode ++ " CPortable") $ (testStandardCiphers (pc256 m) s256 "")
      , testGroup ("AES128 " ++ mode ++ " CPortable vs Reference") $ cportableVsReference (pr128 m) (pc128 m) testKey128
      , testGroup ("AES192 " ++ mode ++ " CPortable vs Reference") $ cportableVsReference (pr192 m) (pc192 m) testKey192
      , testGroup ("AES256 " ++ mode ++ " CPortable vs Reference") $ cportableVsReference (pr256 m) (pc256 m) testKey256
      ]
      where
        pr128 :: m -> Ref128 m Encryption
        pr128 _ = undefined
        pr192 :: m -> Ref192 m Encryption
        pr192 _ = undefined
        pr256 :: m -> Ref256 m Encryption
        pr256 _ = undefined
        pc128 :: m -> CPortable128 m Encryption
        pc128 _ = undefined
        pc192 :: m -> CPortable192 m Encryption
        pc192 _ = undefined
        pc256 :: m -> CPortable256 m Encryption
        pc256 _ = undefined
        mode = show $ typeOf m
