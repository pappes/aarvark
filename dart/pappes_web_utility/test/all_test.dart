// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.test;

import 'pappes_web_utility_myhtml_test.dart' as MyHtml_test;
import 'pappes_web_utility_myjs_test.dart' as MyJS_test;

main() {
  MyHtml_test.defineTests();
  MyJS_test.defineTests();
}
