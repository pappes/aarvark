// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

//Public facing types in this file.

library pappes_web_utility.base;


import 'dart:html';
import 'dart:js' as js;
import 'package:pappes_utility/pappes_utility.dart';
import 'package:logging/logging.dart';

part 'pappes_web_utility_myhtml.dart';
part 'pappes_web_utility_myjs.dart';


/// Converts [val] from base64 to text.
///
/// if [val] is not valid base64 then returns null
/// if library dart:js is not working throws StateError
/// 
///    print(base64Decode('SGVsbG8gV29ybGQ='));
///    
String base64Decode(String val) {
  return MyJS.atob(val);
}


/// Converts [val] from text to base64.
///
/// if [val] is not valid base64 then returns null
/// if library dart:js is not working throws StateError
/// 
///    print(base64Encode('Hello World'));
///    
String base64Encode(String val) {
  return MyJS.btoa(val);
}


final Logger log = new Logger('pappes.pappes_web_utility');