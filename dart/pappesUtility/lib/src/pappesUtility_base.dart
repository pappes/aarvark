// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// TODO: Put public facing types in this file.

library pappesUtility.base;
part 'pappesUtility_RamCache.dart';


/// Substitutes the value [alternate] if the value [test] is null.
/// For exampple:
/// 
///    
dynamic ifNull(test, alternate) {
  return test != null ? test : alternate;
}