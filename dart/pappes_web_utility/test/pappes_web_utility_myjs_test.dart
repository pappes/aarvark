// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.MyJS.test;

import 'package:unittest/unittest.dart';
import 'package:pappes_web_utility/pappes_web_utility.dart';

void main() => defineTests();

void defineTests() {
  group('pappes_web_utility MyJS tests', () {

    test('test runAnyJavaScript console.log', () {
      expect(MyJS.runAnyJavaScript('console.log(" unit testing runAnyJavaScript console.log " + (1+2));'), isNull);
    });
    test('test runAnyJavaScript math', () {
      expect(MyJS.runAnyJavaScript('1+2'), 3);
    });
    test('test runAnyJavaScript string concatenation', () {
      expect(MyJS.runAnyJavaScript('"1"+"2"'), '12');
    });
    print( 'Created timer #${MyJS.runAnyJavaScript('setTimeout(function(){ alert("Unit testing MyJS: timer created 3 seconds ago!!!!   MyJS.removeAllTimers should have stopped this message from appearing."); }, 3000);')}');
    test('test removeAllTimers', () {
      expect(MyJS.removeAllTimers(), isNull);
    });
    test('test encode', () {
      expect(base64Encode('Hello World'), 'SGVsbG8gV29ybGQ=');
    });
    test('test decode', () {
      expect(base64Decode('SGVsbG8gV29ybGQ='), 'Hello World');
    });
  });
}
