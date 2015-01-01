// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

//Public facing types in this file.

library pappes_web_utility.base;


import 'dart:html' show Element;
import 'dart:js' as js show context;
//import 'package:pappesUtility/pappesUtility.dart';

part 'pappes_web_utility_myhtml.dart';
part 'pappes_web_utility_myjs.dart';


//TODO remove
/// Substitutes the value [alternate] if the value [test] is null.
/// For exampple:
/// 
///    x = ifNull(x, y);//use x if it has a value otherwise use y
String ifNull(test, alternate) {
return test != null ? test : alternate;
}


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
