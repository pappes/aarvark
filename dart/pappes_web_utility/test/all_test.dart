// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.test;

import 'pappes_web_utility_myjs_test.dart' as MyJS_test;
import 'pappes_web_utility_myhtml_test.dart' as MyHtml_test;
import 'pappes_web_utility_myhtml_test_destructive.dart' as MyHtml_dest_test;
import 'pappes_web_utility_myhtml_test_very_destructive.dart' as MyHtml_very_dest_test;

main() {
  MyJS_test.defineTests();
  MyHtml_test.defineTests();
  //MyHtml_dest_test.defineTests();//stops javascipt in chrome as shown by a blank console
  //MyHtml_very_dest_test.defineTests();//stops dart in dartium
}
