// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_utility.example;

import 'package:pappes_utility/pappes_utility.dart';

main() {
  Map values = {'a': 1, 'b': 'abc"def'};
  final csv = mapToCSV(values); // will return "1","abc""def"

  RamCache.remember('MyKey', csv);
  print(RamCache.recall('MyKey'));
  RamCache.forget('MyKey');
}
