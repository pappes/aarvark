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

    log.fine('Function : scrapeIMDB, found : {[map,${retval.toString()}]}');
    return retval;
  }

  /// Pull details from an anywhere search result web page into a map.
  ///
  static List<Map> scrapeAnywhereList() {
    log.info('Function : scrapeAnywhereList V 0.10');
    final retval = <Map>[];

    final jsonList = getElementsList(
      document.documentElement!,
      'div.tribe-events-l-container script',
    );
    var resultIndex = 1;
    for (final resultJson in jsonList) {
      log.finest(
          'Function : scrapeAnywhereList, found : {[encoded json.InnerHtml ,${resultJson.innerHtml.toString()}]}');
      var result;
      try {
        result = jsonDecode(resultJson.innerHtml);
      } catch (ignore) {}
      if (result != null) {
        log.finest(
            'Function : scrapeAnywhereList, found : {[decoded json,${result.toString()}]}');
        retval.addAll(summariseAnywhereShows(resultIndex++, result));
      }
    }

    log.fine(
        'Function : scrapeAnywhereList, found : {[list,${retval.toString()}]}');
    return retval;
  }

  static List<Map> summariseAnywhereShows(int index, Object results) {
    log.info('Function : summariseAnywhereShows');
    if (results is Map) {
      return [summariseAnywhereShow(index, results)];
    } else if (results is Iterable) {
      log.finest(
          'Function : summariseAnywhereShows, number found : ${results.length}');
      final retval = <Map>[];
      for (final result in results) {
        if (result is Map) {
          retval.add(summariseAnywhereShow(index, result));
        } else if (result is Iterable) {
          return summariseAnywhereShows(index, result);
        }
      }
      return retval;
    }
    log.fine(
        'Function : summariseAnywhereShow, found : {[unexpected json contents,${results.toString()}]}');
    return [];
  }

  static Map summariseAnywhereShow(int index, Map resultMap) {
    log.info('Function : summariseAnywhereShow');
    final retval = {};
    if (resultMap["@type"] == "Event") {
      retval["index"] = index;
      retval["name"] = resultMap["name"];
      retval["description"] = resultMap["description"];
      retval["link"] = resultMap["url"];
      retval["venue"] = resultMap["location"]?["name"];
      retval["suburb"] = resultMap["location"]?["address"]?["addressLocality"];
      retval["postcode"] = resultMap["location"]?["address"]?["postalCode"];
      retval["producer"] = resultMap["organizer"]["name"];
      retval["price"] = -1.0;
      if (resultMap["offers"] is Map)
        getAnywhereOffer(resultMap, retval);
      else {
        for (final ticketCat in resultMap["offers"]) {
          getAnywhereOffer(ticketCat, retval);
        }
      }
    }
    log.fine(
        'Function : summariseAnywhereShow, found : {[map,${retval.toString()}]}');

    return retval;
  }

  static void getAnywhereOffer(Map offer, Map result) {
    log.info('Function : getAnywhereOffer, offer : ${offer.toString()}');
    // Grab max price to avoid concession prices.  May accidentally grab VIP price.
    final maxPrice = double.parse(result["price"]);
    log.finest('Function : getAnywhereOffer, maxPrice : $maxPrice');
    final offerPrice = double.parse(offer["price"]);
    log.finest('Function : getAnywhereOffer, offerPrice : $offerPrice');
    final validThrough = DateTime.parse(offer["validThrough"]);
    log.finest('Function : getAnywhereOffer, validThrough : $validThrough');
    final availability = DateTime.parse(offer["availability"]);
    log.finest('Function : getAnywhereOffer, availability : $availability');
    if (availability == "InStock" &&
        offerPrice > maxPrice &&
        validThrough.isAfter(DateTime.now())) {
      log.finest('Function : getAnywhereOffer, value : $offerPrice');
      result["Price"] = offerPrice;
    }
    log.finest('Function : getAnywhereOffer, get duration');

    // Session time is hidden in one of the offers!
    if (offer.containsKey("startTime") && offer.containsKey("endTime")) {
      final startDate = DateTime.parse(offer["startTime"]);
      final endDate = DateTime.parse(offer["endTime"]);
      result["startTime"] = fmt.format(startDate);
      result["endTime"] = fmt.format(endDate);
      result["duration"] = getDurationText(
        startDate,
        endDate,
      );
      log.fine(
          'Function : getAnywhereOffer, found : {[map,${result.toString()}]}');
    }
  }

  static void getAnywhereDuration(Map event, Map result) {
    log.info('Function : getAnywhereDuration, event : ${event.toString()}');

    // Session time is hidden in one of the offers!
    if (event.containsKey("startTime") && event.containsKey("endTime")) {
      final startDate = DateTime.parse(event["startTime"]);
      log.finest('Function : getAnywhereOffer, startDate : $startDate');
      final endDate = DateTime.parse(event["endTime"]);
      log.finest('Function : getAnywhereOffer, endDate : $endDate');
      result["startTime"] = fmt.format(startDate);
      result["endTime"] = fmt.format(endDate);
      result["duration"] = getDurationText(
        startDate,
        endDate,
      );
      log.fine(
          'Function : getAnywhereDuration, found : {[map,${result.toString()}]}');
    }
  }

  static String? getDurationText(DateTime start, DateTime end) {
    log.info('Function : getDurationText');
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
