// Copyright (c) 2014, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_utility.base;
part 'pappes_utility_ramcache.dart';


/// Substitutes the value [alternate] if the value [test] is null.
/// For exampple:
/// 
///    
dynamic ifNull(test, alternate) {
  return test != null ? test : alternate;
}