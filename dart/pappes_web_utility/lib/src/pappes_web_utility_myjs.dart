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
      final js = JSWrapper();
      // Set a fake timeout to get the highest timeout id
      int highestTimeoutId = js.setTimeout(";");
      for (var i = 0; i < highestTimeoutId; i++) {
        js.clearTimeout(i);
      }
    } catch (e) {
      //ignore JS errors if running in dart VM
      return null;
    }
  }

  /// Determines the HTML that is used to compose an iFrame.
  ///
  /// dart is tighter about cross domain access
  /// if this was javascript you could do
  ///    document.getElementById('frame').contentWindow.document.body.innerHTML
  static String? getIFrameHtml(IFrameElement iFrame) {
    final jsIFrame = new JsObject.fromBrowserObject(iFrame);
    JsObject jsWindow = jsIFrame['contentWindow'] as JsObject;
    JsObject jsDocument = jsWindow['document'] as JsObject;
    JsObject jsBody = jsDocument['body'] as JsObject;
    String? jsHTML = jsBody['innerHTML'] as String?;
    return jsHTML;
  }

  /// Runs the javascript [command] and returns any result.
  ///
  ///   MyJS.runAnyJavaScript('"1"+"2"');//returns: '12'
  ///   MyJS.runAnyJavaScript('1+2');//returns: 3
  ///   MyJS.runAnyJavaScript('console.log(" 1 + 2 = " + (1+2));');//returns null, logs: 1 + 2 = 3
  ///
  static Object? runAnyJavaScript(String command) {
    JSWrapper js = JSWrapper();
    try {
      js = JSWrapper();
      dynamic retObject = js.eval(command);
      return retObject;
    } catch (e) {
      throw (new StateError(
          'Dart -> JavaScript interop not initialised.  Try changing your html to include <script src="packages/browser/inteerop.js"></script>);  Original error: $e'));
    }
  }

  /// Converts [val] from base64 to text.
  ///
  /// if [val] is not valid base64 then returns null
  /// if library dart:js is not working throws StateError
  ///
  ///    print(MyJS.atob('SGVsbG8gV29ybGQ='));
  ///
  static String? atob(String val) {
    JSWrapper js = JSWrapper();
    try {
      js = JSWrapper();
      js.atob(''); //Validate that simple decode can succeed
    } catch (e) {
      throw (new StateError(
          'Dart -> JavaScript interop not initialised.  Try changing your html to include <script src="packages/browser/inteerop.js"></script>);  Original error: $e'));
    }
    try {
      dynamic retObject = js.atob(val);
      return retObject;
    } catch (e) {
      //ignore attempts to decode invalid strings
      //"InvalidCharacterError: Failed to execute 'atob' on 'Window': The string to be decoded is not correctly encoded."
      return null;
    }
  }

  /// Converts [val] from text to base64.
  ///
  /// if library dart:js is not working throws StateError
  ///
  ///    print(MyJS.btoa('Hello World'));
  ///
  static String? btoa(String val) {
    JSWrapper js = JSWrapper();
    try {
      js = JSWrapper();
      js.btoa(''); //Validate that simple encode can succeed
    } catch (e) {
      throw (new StateError(
          'Dart -> JavaScript interop not initialised.  Try changing your html to include <script src="packages/browser/inteerop.js"></script>);  Original error: $e'));
    }
    dynamic retObject = js.btoa(val);
    return retObject;
  }

  ///Returns an existing singleton.
  ///
  ///Constructor as invoked by external instantiations.
  factory MyJS() {
    return _singleton;
  }

  ///Constructor as invoked by static instances of this class.
  MyJS._initialise() {}
}
