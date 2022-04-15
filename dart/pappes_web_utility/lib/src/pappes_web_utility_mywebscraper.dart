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
  static final fmt = DateFormat('dd-MMM-yyyy hh:mm a');

  /// Pull details from an IMDB web page into a map.
  ///
  static Map scrapeIMDB() {
    log.info('Function : scrapeIMDB');
    final retval = {};

    retval['Name'] = getElementSequencialText(
      document.documentElement!,
      ['h1[data-testid="hero-title-block"]', 'h1[class*="TitleHeader"]'],
    );
    retval['Description'] = getElementSequencialText(
      document.documentElement!,
      [
        'div[data-testid="storyline-plot-summary"]',
        'span[data-testid*="plot"]'
      ],
    );
    retval['Languages'] = getElementSequencialText(
      document.documentElement!,
      [
        'li[data-testid="title-details-languages"]',
        'a[href*="primary_language"]'
      ],
    );

    log.info('Function : scrapeIMDB, found : {[map,${retval.toString()}]}');
    return retval;
  }

  /// Pull details from an anywhere search result web page into a map.
  ///
  static List<Map> scrapeAnywhereList() {
    log.info('Function : scrapeAnywhereList');
    final retval = <Map>[];

    final jsonList = getElementsList(
      document.documentElement!,
      'div.tribe-events-l-container script',
    );
    var resultIndex = 1;
    for (final resultJson in jsonList) {
      log.info(
          'Function : scrapeAnywhereList, found : {[encoded json,${resultJson.toString()}]}');
      final result = jsonDecode(resultJson);
      log.info(
          'Function : scrapeAnywhereList, found : {[decoded json,${result.toString()}]}');
      retval.add(summariseAnywhereShow(resultIndex++, result));
    }

    log.info(
        'Function : scrapeAnywhereList, found : {[list,${retval.toString()}]}');
    return retval;
  }

  static Map summariseAnywhereShows(int index, Object results) {
    log.info('Function : summariseAnywhereShows');
    if (results is Map) {
      return summariseAnywhereShow(index, results);
    } else if (results is Iterable) {
      for (final result in results) {
        if (result is Map) {
          return summariseAnywhereShow(index, result);
        } else if (result is Iterable) {
          return summariseAnywhereShows(index, result);
        }
      }
    }
    log.info(
        'Function : summariseAnywhereShow, found : {[unexpected json contents,${results.toString()}]}');
    return {};
  }

  static Map summariseAnywhereShow(int index, Map resultMap) {
    log.info('Function : summariseAnywhereShow');
    final retval = {};
    if (resultMap["@type"] == "Event") {
      retval["index"] = index;
      retval["name"] = resultMap["name"];
      retval["description"] = resultMap["description"];
      retval["link"] = resultMap["url"];
      retval["startTime"] = fmt.format(resultMap["startDate"]);
      retval["endTime"] = fmt.format(resultMap["endDate"]);
      retval["duration"] = getDurationText(
        resultMap["startDate"],
        resultMap["endDate"],
      );
      retval["venue"] = resultMap["location"]["name"];
      retval["suburb"] = resultMap["location"]["addressLocality"];
      retval["postcode"] = resultMap["location"]["postalCode"];
      retval["producer"] = resultMap["organizer"]["name"];
      var price = -1;
      for (final ticketCat in resultMap["offers"]) {
        if (ticketCat["availability"] == "InStock" &&
            ticketCat["price"] > price &&
            ticketCat["validThrough"] < DateTime.now()) {
          price = ticketCat["price"];
        }
      }
    }
    log.info(
        'Function : summariseAnywhereShow, found : {[map,${retval.toString()}]}');

    return retval;
  }

  static String? getDurationText(DateTime start, DateTime end) {
    try {
      final totalMinutes = end.difference(start).inMinutes;
      final hours = (totalMinutes / 60).round();
      final minutes = (totalMinutes % 60).round();
      return "${hours}:${minutes}";
    } finally {}
  }

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

  /// Uses a JS query [selector] to find all matching elements in the page/
  ///
  ///
  /// ## For example:
  ///    MyHtml.getElementText('div[data-testid="storyline-plot-summary"]');
  static List getElementsList(Element root, String selector,
      [List defaultVal = const []]) {
    log.info('Function : getElementsList, Parameters : {[selector,$selector]}');

    // find element
    final elements = root.querySelectorAll(selector);
    log.finest('Function : getElementsList, # found : ${elements.length}');

    if (elements.isEmpty) {
      return defaultVal;
    }
    return elements;
  }
}
