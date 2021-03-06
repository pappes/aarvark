// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_utility.example;

import 'package:pappes_utility/pappes_utility.dart';

main() {
  
  int x=10;
  int y=20;
  x = ifNull(x, y);//use x if it has a value otherwise use y
  
  
  RamCache.remember('MyKey', x);
  print(RamCache.recall('MyKey'));
  RamCache.forget('MyKey');
}
