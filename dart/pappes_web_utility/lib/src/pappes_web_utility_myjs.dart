// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Collection of utility classes and functions to make programs simpler.
part of pappes_web_utility.base;



/// Utility functions to abstract working with the browsers JavaScript engine.
///
/// ## purpose 
/// 
/// * Extend built-in dart JavaScript functionality.
/// Note: atob and btoa are also available from dart:html.window without reverting to a javascript interop.
///   


class MyJS {
  //implimented as a singleton as all instances would behave the same anyway
  static final _singleton = new MyJS._initialise();

  /// Removes all javascript timers from the browser tab.
  static void removeAllTimers() {
    try {
      // Set a fake timeout to get the highest timeout id
      int highestTimeoutId = js.context.callMethod('setTimeout', [";"]);
      for (var i = 0 ; i < highestTimeoutId ; i++) {
        js.context.callMethod('clearTimeout', [i]); 
      }
    } catch (e) {
      //ignore JS errors if running in dart VM
      return null;
    }
  }
  
  /// Runs the javascript [command] and returns any result.
  /// 
  ///   MyJS.runAnyJavaScript('"1"+"2"');//returns: '12'
  ///   MyJS.runAnyJavaScript('1+2');//returns: 3
  ///   MyJS.runAnyJavaScript('console.log(" 1 + 2 = " + (1+2));');//returns null, logs: 1 + 2 = 3
  ///   
  static Object runAnyJavaScript(String command) {
    dynamic retObject;
    bool jsHasEval;
    try {
      jsHasEval = js.context.hasProperty('eval');
    } catch (e) {
      throw (new StateError('Dart -> JavaScript interop not initialised.  Try changing your html to include <script src="packages/browser/inteerop.js"></script>);  Original error: $e'));
    }
    if (jsHasEval) {
      retObject = js.context.callMethod('eval', ["$command"]);
      return retObject;
    }
    throw (new StateError('Dart -> JavaScript interop not accepting calls to eval().  Try changing your html to include <script src="packages/browser/inteerop.js"></script>);'));
  }
  
  /// Converts [val] from base64 to text.
  ///
  /// if [val] is not valid base64 then returns null
  /// if library dart:js is not working throws StateError
  /// 
  ///    print(MyJS.atob('SGVsbG8gV29ybGQ='));
  ///    
  static String atob(String val) {
    bool jsHasAtob;
    try {
      jsHasAtob = js.context.hasProperty('atob');
    } catch (e) {
      throw (new StateError('Dart -> JavaScript interop not initialised.  Try changing your html to include <script src="packages/browser/inteerop.js"></script>);  Original error: $e'));
    }
    if (jsHasAtob) try {
      return js.context.callMethod('atob', ["$val"]);
    } catch (e) {
      //ignore attempts to decode invalid strings
      //"InvalidCharacterError: Failed to execute 'atob' on 'Window': The string to be decoded is not correctly encoded."
      return null;
    }
    throw (new StateError('Dart -> JavaScript interop not accepting calls to atob().  Try changing your html to include <script src="packages/browser/inteerop.js"></script>);'));
  }

  /// Converts [val] from text to base64.
  ///
  /// if [val] is not valid base64 then returns null
  /// if library dart:js is not working throws StateError
  /// 
  ///    print(MyJS.btoa('Hello World'));
  ///    
  static String btoa(String val) {
    bool jsHasBtoA;
    try {
      jsHasBtoA = js.context.hasProperty('btoa');
    } catch (e) {
      throw (new StateError('Dart -> JavaScript interop not initialised.  Try changing your html to include <script src="packages/browser/inteerop.js"></script>);  Original error: $e'));
    }
    if (jsHasBtoA) try {
      return js.context.callMethod('btoa', ["$val"]);
    } catch (e) {
      //ignore attempts to decode invalid strings
      //"InvalidCharacterError: Failed to execute 'atob' on 'Window': The string to be decoded is not correctly encoded."
      return null;
    }
    throw (new StateError('Dart -> JavaScript interop not accepting calls to btoa().  Try changing your html to include <script src="packages/browser/inteerop.js"></script>);'));
  }


  ///Returns an exisiting singleton.
  ///
  ///Constructor as invoked by external instanciations.
  factory MyJS() {
    return _singleton;
  }
  
  ///Constructor as invoked by static instances of this class.
  MyJS._initialise() {
  }
}
