// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.MyJS.test;

import 'package:unittest/unittest.dart';
import 'package:pappes_web_utility/pappes_web_utility.dart';

void main() => defineTests();

void defineTests() {
  group('pappes_web_utility MyJS tests', () {

    test('test encode', () {
      expect(base64Encode('Hello World'), 'SGVsbG8gV29ybGQ=');
    });
    test('test decode', () {
      expect(base64Decode('SGVsbG8gV29ybGQ='), 'Hello World');
    });
  });
}
