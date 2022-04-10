// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Collection of utility classes and functions to make programs simpler.
part of pappes_web_utility.base;

/// Utility functions to abstract working with the HTML DOM.
///
/// ## purpose
///
/// * Extend built-in dart HTML functionality.
///

class MyWebScraper {
  /// Uses a JS query [selector] to find an element in the page
  /// and returns a text version of it.
  ///
  ///
  /// ## For example:
  ///    MyHtml.getElementText('div[data-testid="storyline-plot-summary"]');
  static String? getElementText(Element root, String selector,
      [String? defaultVal]) {
    log.info('Function : getElementText, Parameters : {[selector,$selector]}');

    // find element
    var element = root.querySelector(selector);
    log.finest('Function : getElementText, found : ${element?.text}');

    return element?.text ?? defaultVal;
  }

  /// Uses a JS query selector to find an element in the page
  /// and returns a text version of it.
  ///
  /// [selectors] is a [List] of selectors that will be searched
  /// to progressively narrow down the target.
  /// If a later list item does not find a match under the parent
  /// the parent text is returned.
  ///
  /// ## For example:
  ///    MyHtml.getElementHierachicalText
  ///       'div[data-testid="storyline-plot-summary"]',
  ///       'div[span[data-testid*="plot"]]',
  ///      ]);
  static String? getElementHierachicalText(
      Element root, Iterable<String> selectors,
      [String? defaultVal]) {
    log.info(
        'Function : getElementHierachicalText, Parameters : {[selectors,$selectors]}');

    Element? element = root;
    String? elementText = element.text ?? defaultVal;

    for (final selector in selectors) {
      // find element
      element = element?.querySelector(selector);
      if (null == element) return elementText;
      elementText = element.text ?? elementText;
      log.finest('Function : getElementHierachicalText, found : $elementText');
    }

    return elementText;
  }

  /// Uses a JS query selector to find an element in the page
  /// and returns a text version of it.
  ///
  /// [selectors] is a [List] of selectors that will be searched
  /// itteratively to find target.
  /// The first matching element is converted to text and returned.
  ///
  /// ## For example:
  ///    MyHtml.getElementSequencialText(
  ///      document.documentElement,
  ///      [
  ///       'div[data-testid="storyline-plot-summary"]',
  ///       'div[span[data-testid*="plot"]]',
  ///      ]);
  static String? getElementSequencialText(
      Element root, Iterable<String> selectors,
      [String? defaultVal]) {
    log.info(
        'Function : getElementSequencialText, Parameters : {[selectors,$selectors]}');

    String? elementText;
    for (final selector in selectors) {
      // find element
      var element = root.querySelector(selector);
      log.finest(
          'Function : getElementSequencialText, found : ${element?.text}');

      if (null != element) {
        return element.text;
      }
    }

    return elementText ?? defaultVal;
  }
}
