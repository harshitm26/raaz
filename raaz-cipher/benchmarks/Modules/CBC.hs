module Modules.CBC (benchmarks, benchmarksTiny) where

import Criterion.Main
import Raaz.Benchmark.Gadget
import Raaz.Primitives.Cipher

import Raaz.Cipher.AES.CBC

import Modules.Defaults

benchmarks :: [Benchmark]
benchmarks = benchmarksDefault (undefined :: CBC)

benchmarksTiny :: [Benchmark]
benchmarksTiny = benchmarksTinyDefault (undefined :: CBC)
