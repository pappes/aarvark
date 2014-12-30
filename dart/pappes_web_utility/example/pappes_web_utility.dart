// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.example;

import 'package:pappes_web_utility/pappes_web_utility.dart';

main() {
  print(MyJS.base64Decode('SGVsbG8gV29ybGQ='));
  print(MyJS.base64Encode('Hello World'));
}
