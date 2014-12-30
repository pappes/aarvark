// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.test;

import 'package:unittest/unittest.dart';
import 'package:pappes_web_utility/pappes_web_utility.dart';

main() {
  group('pappes_web_utility MyJS tests', () {

    test('test encode', () {
      expect(MyJS.base64Encode('Hello World'), 'SGVsbG8gV29ybGQ=');
    });
    test('test decode', () {
      expect(MyJS.base64Decode('SGVsbG8gV29ybGQ='), 'Hello World');
    });
  });
}
