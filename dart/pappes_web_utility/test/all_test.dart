// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.test;

import 'package:test/test.dart';
import 'package:logging/logging.dart' as logging;
import 'package:pappes_web_utility/pappes_web_utility.dart';
import 'pappes_web_utility_myjs_test.dart' as MyJS_test;
import 'pappes_web_utility_myhtml_test.dart' as MyHtml_test;
import 'pappes_web_utility_myhtml_test_destructive.dart' as MyHtml_dest_test;
import 'pappes_web_utility_myhtml_test_very_destructive.dart' as MyHtml_very_dest_test;

main() {
  
  final destructiveCapability = {'SAFE':1,'DESTRUCTIVE':2,'VERYDESTRUCTIVE':3}; 
  int? destructiveLevel;
  destructiveLevel = destructiveCapability['SAFE'];
  //destructiveLevel = destructiveCapability['DESTRUCTIVE'];
  //destructiveLevel = destructiveCapability['VERYDESTRUCTIVE'];//uncomment if destructive testing is required
  

  //loggin_handlers.attachXLoggerUi(); // lives in the browser_logging_handlers library
  logging.hierarchicalLoggingEnabled = true;
  log.level = logging.Level.WARNING;
  log.level = logging.Level.FINEST;
  log.onRecord.listen((logging.LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
    MyHtml.logMessageIntoHTMLBodyComment('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  
  MyJS_test.defineTests();
  MyHtml_test.defineTests();
  test('faketest', () => expect(destructiveLevel, destructiveLevel));
  if (destructiveLevel == destructiveCapability['DESTRUCTIVE']) MyHtml_dest_test.defineTests();//stops javascript in chrome as shown by a blank console
  else if (destructiveLevel == destructiveCapability['VERYDESTRUCTIVE']) MyHtml_very_dest_test.defineTests();//stops dart in dartium
}
