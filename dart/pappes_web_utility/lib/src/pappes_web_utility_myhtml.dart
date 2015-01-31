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

typedef void _MyHtml_Element_Process(Element e);
typedef Object _MyHtml_Alter_Element(Object e);

class MyHtml {
  //implimented as a singleton as all instances would behave the same anyway
  static final _singleton = new MyHtml._initialise();



  /// Changes [originalURL] to remove parameters.
  /// Optionally can replace old parameters with [replacementParameters].
  /// Optionally can test for the presence of [searchFor]
  /// to identify URIs that should be modified.
  ///
  /// ## For example:
  ///    MyHtml.setUriParameters('http://www.abc.com?x=HelloWorld&a=b',
  ///    searchFor: 'HelloWorld', replacementParameters: 'abc=123')
  static String setUriParameters(String originalUrl, {String searchFor,
      String replacementParameters}) {
    String finalUrl;
    log.info(
        'Function : setUriParameters, '
            'Parameters : {[originalUrl,$originalUrl ][searchFor,$searchFor ]'
            '[replacementParameters,$replacementParameters ]}');

    Uri x = Uri.parse(originalUrl);
    if (searchFor == null ||
        x.query.toLowerCase().contains(searchFor.toLowerCase())) {
      x = new Uri(
          scheme: x.scheme,
          userInfo: x.userInfo,
          host: x.host,
          port: x.port,
          path: x.path,
          query: replacementParameters);
    }
    finalUrl = x.toString();

    log.fine('Function : setUriParameters, Return : $finalUrl');
    return finalUrl;
  }

  /// Changes [originalURL] to remove any attempt at redirection.
  ///
  /// ## Known redirect attempts:
  /// * u=http://www.mysite.com
  /// * u=www.mysite.com
  /// * u=base64Encode(www.mysite.com)
  /// * u=URLEncode(www.mysite.com)
  static String removeUrlRedirect(String originalUrl) {
    String finalUrl;
    String base64Uri;
    log.info(
        'Function : removeUrlRedirect, Parameters : {[originalUrl,$originalUrl ]}');
    final Map params = Uri.parse(originalUrl).queryParameters;
    if (params is Map) for (String param in params.values) {
      // we have a web address so use it now
      if (param.toLowerCase().startsWith('www') ||
          param.toLowerCase().startsWith('http')) {
        finalUrl = param;
        break;
      }

      //check that it is not null before decoding it.
      //Store decoded value for later if it is a valid URL.
      if (base64Decode(param) != null &&
          (base64Decode(param).toLowerCase().startsWith('www') ||
              base64Decode(param).toLowerCase().startsWith('http'))) {
        base64Uri = base64Decode(param);
      }
    }
    finalUrl = setUriSchemeToHttp(ifNull(finalUrl, base64Uri));
    finalUrl = ifNull(finalUrl, originalUrl);
    log.fine('Function : removeUrlRedirect, Return : $finalUrl');
    return finalUrl;
  }

  /// Changes [originalURL] to use the http protocol if none specified.
  ///
  /// This is used to unsure that URLs that do not include the scheme
  /// are treated as absolute paths (not relative to the document URL).
  static String setUriSchemeToHttp(String originalURL) {
    String finalUrl;
    Uri parsedUri;
    log.info(
        'Function : setUriSchemeToHttp, Parameters : {[originalURL,$originalURL ]}');
    try {
      parsedUri = Uri.parse(originalURL);
      if (parsedUri.scheme == '') {
        finalUrl =
            parsedUri.replace(scheme: 'http', path: r'//' + parsedUri.path).toString();
        //the following line to to work around a bug in Darts URI library
        finalUrl = finalUrl.replaceFirst(r'http:////', r'http://');
      }
    } catch (e) { //invalid URLs to be passed back unmodified
    }
    finalUrl = ifNull(finalUrl, originalURL);
    log.fine('Function : setUriSchemeToHttp, Return : $finalUrl');
    return finalUrl;
  }

  /// Creates an HTML element from any valid [htmlFragment] of HTML.
  ///
  /// Does not have any of the normal security limitations.
  static Element createElementFromHTML(String htmlFragment) {
    log.info(
        'Function : createElementFromHTML, '
            'Parameters : {[htmlFragment,$htmlFragment]}');
    Element e =
        new Element.html(htmlFragment, treeSanitizer: new _NonTreeSanitizer());
    log.fine('Function : createElementFromHTML, Return : ${e.outerHtml}');
    return e;
  }

  /// Alters a specific [attribute] of a HTML [Element], [node]
  /// by applying function [alter] to the [attribute].
  ///
  /// * [node] - any HTML [Element].
  /// * [attribute] - the name of the attribute to be modifiied.
  /// * [alter] - a function that takes in
  ///   * the old value
  ///   * and returns the new value.
  ///
  /// The following example uses alterAttribute
  /// to modify an attribute on an Element.
  /// Specifically it is altering the href attribute on a anchor element
  ///     <a href=http://www.google.com> go to google </a>
  /// the function removeUrlRedirect
  /// would be a declared to pass in a href [String]
  /// and return a modified href [string]
  ///
  ///     alterAttribute(element, 'href', (url) => removeUrlRedirect(url)));
  ///
  static alterAttribute(Element node, String attribute, Object
      alter(Object a)) {
    log.info(
        'Function : alterAttribute, '
            'Parameters : {[node,$node][attribute,$attribute][alter,$alter]}');
    assert(alter is _MyHtml_Alter_Element);
    if (node.attributes.containsKey(attribute)) {
      log.finer(
          'Function : alterAttribute, old : ${node.attributes[attribute]}');
      node.attributes[attribute] = alter(node.attributes[attribute]);
      log.finer(
          'Function : alterAttribute, new : ${node.attributes[attribute]}');
    }
    log.fine('Function : alterAttribute, Return : void');
  }

  /// Applies a [process] to every element of a HTML [DOM] element
  /// (or any other HTML [Element]).
  ///
  /// * [process] is a procedure that takes
  ///   * a single HTML [Element]
  ///   * and returns nothing
  ///
  ///    iterateHTMLDOM(document.body, (e) => printElement(e));
  static iterateHTMLDOM(Element DOM, void process(Element e)) {
    log.info(
        'Function : iterateHTMLDOM, '
            'Parameters : {[DOM , $DOM][process , $process]}');
    assert(process is _MyHtml_Element_Process);
    if (DOM.hasChildNodes()) DOM.children.forEach(
        (child) => iterateHTMLDOM(child, process));
    log.finest('Function : iterateHTMLDOM, old : ${DOM.outerHtml}');
    process(DOM);
    log.finest('Function : iterateHTMLDOM, new : ${DOM.outerHtml}');
    log.fine('Function : iterateHTMLDOM, Return : void');
  }

  /// Removes all script tags from [htmlDoc].
  static removeAllScripts(HtmlDocument htmlDoc) {
    log.info('Function : removeAllScripts, Parameters : {[htmlDoc,$htmlDoc]}');
    htmlDoc.querySelectorAll('script').forEach((Element e) {
      log.finest('Function : removeAllScripts, removed : ${e.outerHtml}');
      e.remove();
    });
    log.fine('Function : removeAllScripts, Return : void');
  }

  /// Removes all event handlers from all elements on the browser DOM.
  static void removeAllHandlers(HtmlDocument htmlDoc) {
    //clone the items in the body to sever any event handlers
    log.info('Function : removeAllHandlers, Parameters : {[htmlDoc,$htmlDoc]}');
    htmlDoc.body.children.toSet().forEach(
        (Element e) => e.replaceWith(e.clone(true)));
    MyJS.removeAllTimers();
    log.fine('Function : removeAllHandlers, Return : void');
  }

  /// Changes the target of all <a> anchor href elementsin [htmlDoc].
  ///
  /// * Default [target] is '_blank' (new tab)
  /// * Valid values for [target] are
  ///   * '_blank'
  ///   * '_self'
  ///   * '_parent'
  ///   * '_top'
  ///   * or _framename_
  static retargetAllHrefs(HtmlDocument htmlDoc, [String target = '_blank']) {
    log.info(
        'Function : retargetAllHrefs, '
            'Parameters : {[htmlDoc,$htmlDoc][target,$target]}');
    htmlDoc.querySelectorAll('a').forEach((Element e) {
      log.finest(
          'Function : retargetAllHrefs, old : ${e.attributes['target']}');
      e.attributes['target'] = target;
      log.finest(
          'Function : retargetAllHrefs, new : ${e.attributes['target']}');
    });
    log.fine('Function : retargetAllHrefs, Return : void');
  }

  /// Converts src and href attributes to be absolute URL's.
  ///
  /// * [childElement] the
  ///   * <img>,
  ///   * <iframe>
  ///   * <a>
  ///   * <object>
  ///   * or other element that has an external reference
  /// * [baseUrl] the parent URL to use for resolving

  static resolveElementUrl(Element childElement, String baseUrl) {
    log.info(
        'Function : resolveElementUrl, '
            'Parameters : {[childElement,$childElement][baseUrl,$baseUrl]}');
    Uri baseUri = Uri.parse(baseUrl);
    childElement.attributes.forEach((attr, val) {
      if (['src', 'href'].contains(attr)) {
        log.finest('Function : resolveElementUrl, old : $val');
        val = baseUri.resolve(val).toString();
        log.finest('Function : resolveElementUrl, new : $val');
      }
    });
    log.fine('Function : resolveElementUrl, Return : void');
  }
  /// Removes any element that obsures another element from [htmlDoc].
  ///
  /// If there is an iFrame or object on the page, finds the largest one and:
  /// * if it is an iFrame referencing another page and source is available,
  ///   * moves it inline
  /// * if it is an iFrame referencing another page and source is not available,
  ///   * opens it in the current tab
  /// * if it is an Object or inline iFrame,
  ///   * opens it in the current tab
  ///
  /// then strip out everything ont the resulting page except:
  /// * <a> tags that are based on text
  ///   * leave hyperlinks
  ///   * removes buttons
  /// * <object> tags to allow videos to remain
  /// * <video> tags to allow videos to remain
  /// * <input> tags to allow searching
  /// * <iframe> tags to allow external content
  /// and keep all elements that are parents of these elements
  ///
  ///    removeAllOverlays(document);
  static removeAllOverlays(HtmlDocument htmlDoc, [bool allowRedirect = true]) {
    log.info(
        'Function : removeAllOverlays, '
            'Parameters : {[htmlDoc,$htmlDoc], [allowRedirect,$allowRedirect]}');
    List pageElements = [];
    stripDownPage(htmlDoc);
    pageElements.addAll(htmlDoc.querySelectorAll('iframe'));
    pageElements.addAll(htmlDoc.querySelectorAll('object'));
    pageElements.sort(_compareElementArea);
    if (pageElements.isNotEmpty) {
      HtmlElement selected = pageElements.last;
      log.finest(
          'Function : removeAllOverlays, selected : ${selected} '
              '(width ${selected.clientWidth}) (height ${selected.clientHeight})');
      if (selected.className == 'iframe') {
        new MyIFrame(
            htmlDoc,
            pageElements.last).makeProminant(stripDownPage, allowRedirect);
      } else {
        stripDownPage(htmlDoc, selected);
      }
    } else {
      log.finest('Function : removeAllOverlays,  no iframe/object selected');
      stripDownPage(htmlDoc);
    }
    log.fine('Function : removeAllOverlays, Return : void');
  }

  /// Remove unwanted HTML [Element] tags from a [HtmlDocument] or [ParentNode]
  ///
  /// strips out everything except:
  /// * <a> tags that are based on text (leave hyperlinks, removes buttons)
  /// * <object> tags to allow videos to remain
  /// * <video> tags to allow videos to remain
  /// * <input> tags to allow searching
  /// * <iframe> tags to allow external content
  /// and keep all elements that are parents of these elements
  ///
  /// If [selected] is passed in, strips out everything except
  /// * [selected]
  /// * parents/ancestors of [selected]
  ///
  ///    stripDownPage(document);
  ///
  ///    stripDownPage(document, document.body.children.first);
  static stripDownPage(target, [HtmlElement selected = null]) {
    log.info(
        'Function : _stripDownPage, '
            'Parameters : {[target,$target][selected,$selected]}');

    Set<Element> elementsToBeDeleted = target.querySelectorAll('*').toSet();

    if (selected != null) {
      _whitelistElementAndParents(selected, elementsToBeDeleted);
    } else {
      //whitelist all elements of type input so that the user can still search
      target.querySelectorAll(
          'input').forEach((e) => _whitelistElementAndParents(e, elementsToBeDeleted));
      //whitelist all elements of type object so the user can watch videos
      target.querySelectorAll(
          'object').forEach((e) => _whitelistElementAndParents(e, elementsToBeDeleted));
      //whitelist all elements of type video so the user can watch videos
      target.querySelectorAll(
          'video').forEach((e) => _whitelistElementAndParents(e, elementsToBeDeleted));

          //whitelist all elements of type iframe so that external content can remain
      target.querySelectorAll(
          'iframe').forEach((e) => _whitelistElementAndParents(e, elementsToBeDeleted));

      //whitelist all elements of type anchor that have text
      //so the user can click on links but not buttons
      target.querySelectorAll('a').forEach((Element e) {
        String txt = e.text;
        if (ifNull(txt, '') !=
            '') _whitelistElementAndParents(e, elementsToBeDeleted);
      });
    }
    //destroy everything that remains
    elementsToBeDeleted.forEach((Element e) {
      log.finest('Function : _stripDownPage, remove : $e');
      e.remove();
    });
    if (target is HtmlDocument) {
      removeAllHandlers(target);
    }
    log.fine('Function : _stripDownPage, Return : void');
  }

  /// Impliments Comparator to allow sorting [Element]s based on ClientWidth;
  static int _compareElementArea(Element a, Element b) {
    log.info('Function : _compareElementArea, Parameters : {[a,$a][b,$b]}');
    log.fine(
        'a.width=${a.clientWidth} a.height=${a.clientHeight} '
        'b.width=${b.clientWidth} b.height=${b.clientHeight}');
    int comparison;
    if (a.clientWidth * a.clientHeight <
        b.clientWidth * b.clientHeight) comparison = -1; 
    else if (a.clientWidth * a.clientHeight ==
             b.clientWidth * b.clientHeight) comparison = 0; 
    else comparison = 1;
    log.fine('Function : _compareElementArea, Return : $comparison');
    return comparison;
  }

  /// Removes [e] and all it's parents/ancestors from [s]
  static void _whitelistElementAndParents(Element e, Set s) {
    if (e.parent != null) _whitelistElementAndParents(e.parent, s);
    s.remove(e);
  }

  ///Returns an exisiting singleton.
  ///
  ///Constructor as invoked by external instanciations.
  factory MyHtml() {
    return _singleton;
  }

  ///Constructor as invoked by static instances of this class.
  MyHtml._initialise() {
  }
}

class MyIFrame {//TODO(pappes) remove direct reference to window
  IFrameElement
      _iFrame;//TODO (pappes) inherit from IframeElement would be better
  HtmlDocument _htmlDoc;//TODO(pappes) get doc from IFrame would be better
  String _iFrameHtml;

  /// Enhances the IFrame to make it more visible for the user.
  ///
  /// * attempts to inline the iframe
  /// * otherwise loads IFrame source in tab
  /// [cleanUpProcess] is an optional function that takes
  /// * a [HtmlDocument] (when the IFrame was loaded in the tab)
  /// * or [IFrameElement] (when the IFrame was inlined into the document)
  /// and runs extra cleanup processing on it
  makeProminant([void cleanUpProcess(dynamic parentNode), bool allowRedirect =
      true]) {
    log.info(
        'Function : makeProminant, Parameters : {[cleanUpProcess,$cleanUpProcess], '
            '[allowRedirect,$allowRedirect]}');
    String iFrameSource = _iFrame.attributes['src'];
    if (!iFrameSource.contains('</html>')) {
      iFrameSource =
          Uri.parse(window.location.href).resolve(iFrameSource).toString();
    }
    _buildIFrameAsHtml(iFrameSource, cleanUpProcess, allowRedirect);
    _htmlDoc.querySelectorAll('iframe').forEach((Element frame) {
      //if it is not the new frame or it is not the same frame (redirect denied)
      if ((frame.id != 'iframe_rebuilt' && allowRedirect) ||
          (iFrameSource != frame.attributes['src'] && !allowRedirect)) {
        log.finest('Function : makeProminant, remove : $frame');
        frame.remove(); //remove all iFrames from document body
      }
    });
    if (cleanUpProcess != null) cleanUpProcess(_htmlDoc);
    log.fine('Function : makeProminant, Return : void');
  }


  /// Determines the HTML that is used to compose an iFrame.
  ///
  /// dart is tighter about cross domain access
  /// if this was javascript you could do
  ///    document.getElementById('frame').contentWindow.document.body.innerHTML
  String getIFrameHtml() {
    log.info('Function : getIFrameHtml, Parameters : {}');
    js.JsObject jsIFrame = new js.JsObject.fromBrowserObject(_iFrame);
    String innerHtml =
        jsIFrame['contentWindow']['document']['body']['innerHTML'];
    log.fine('Function : getIFrameHtml, Return : $innerHtml');
    return (innerHtml);
  }

  /// Breaks tags and attributes commonly used for malicious activity.
  String _modifyHtmlToSanitise(String originalHtml) {
    log.info(
        'Function : _modifyHtmlToSanitise, '
            'Parameters : {[originalHtml,$originalHtml]}');
    String retval = originalHtml
        ..replaceAll('class', 'crass')
        ..replaceAll('setTimeout', 'dontSetTimeout')
        ..replaceAll('style', 'smile')
        ..replaceAll('position:', 'poison:')
        ..replaceAll('position%3A', 'poison%3A')
        ..replaceAll('onclick', 'oncrick')//..replaceAll('<style', '<!--')
    //..replaceAll('</style>', '-->')
    ;
    log.fine('Function : _modifyHtmlToSanitise, Return : $retval');
    return retval;
  }

  /// Inserts an [IFrameElement] to the start of the document.
  ///
  /// * [contents] can be either a URL or a HTML in a string
  /// * [cleanUpProcess] is an optional function that takes an
  ///   *[IFrameElement] and runs extra cleanup processing on it
  _embedIFrameInBody(String contents, [void cleanUpProcess(dynamic parentNode),
      String baseUrl]) {
    log.info(
        'Function : _embedIFrameInBody, '
            'Parameters : {[contents,$contents][cleanUpProcess,$cleanUpProcess]'
            '[baseUrl,$baseUrl]}');
    String fragment = '<iframe id=iframe_rebuilt src=\'$contents\'>';
    fragment = _modifyHtmlToSanitise(fragment);
    Element iframeElement = MyHtml.createElementFromHTML(fragment);
    iframeElement.querySelectorAll(
        '*').forEach((Element e) => MyHtml.resolveElementUrl(e, baseUrl));
    if (cleanUpProcess != null) cleanUpProcess(iframeElement);
    try {
      log.finer(
          'Function : _embedIFrameInBody, '
              'insertBefore : [Value,${iframeElement.outerHtml}]'
              '[AheadOf,${_htmlDoc.body.children.first.outerHtml}]');
      _htmlDoc.body.insertBefore(iframeElement, _htmlDoc.body.children.first);
    } catch (e) {
      log.finer(
          'Function : _embedIFrameInBody, append : ${iframeElement.outerHtml}');
      _htmlDoc.body.append(iframeElement);
    }
    log.fine('Function : _embedIFrameInBody, Return : void');
  }

  /// Opens the [url] in the current browser tab.
  ///
  /// * [url] is the site to open
  /// * [cleanUpProcess] is an optional function that takes an
  ///   *[IFrameElement] and runs extra cleanup processing on it
  _openIFrameInCurrentTab(String url, [void
      cleanUpProcess(dynamic parentNode)]) {
    log.info(
        'Function : _openIFrameInCurrentTab, '
            'Parameters : {[url,$url][cleanUpProcess,$cleanUpProcess]}');
    window.location.assign(url);
    if (cleanUpProcess != null) cleanUpProcess(window.document);
    log.fine('Function : _openIFrameInCurrentTab, Return : void');
  }


  /// Converts an IFrame from referenced to inline
  /// and inserts it into the DOM (if source is available)
  /// or opens the IFrame in current tab (if the source is not available)
  _buildIFrameAsHtml(String iFrameSource, [void
      cleanUpProcess(dynamic parentNode), bool allowRedirect = true]) {
    log.info(
        'Function : _buildIFrameAsHtml, Parameters : {[iFrameSource,$iFrameSource]'
            '[cleanUpProcess,$cleanUpProcess], [allowRedirect,$allowRedirect]}');
    if (iFrameSource.contains('</html>')) {
      _embedIFrameInBody(iFrameSource, cleanUpProcess);
    } else if (ifNull(getIFrameHtml(), '') != '') {
      _embedIFrameInBody(
          ' data:text/html,' + getIFrameHtml(),
          cleanUpProcess,
          iFrameSource);
    } else {
      //attempt to load external web site content
      HttpRequest.request(iFrameSource).then((contents) {
        log.finest(
            'Function : _buildIFrameAsHtml, '
                'HttpRequest.request.contents__(expecting: 4,200)__ : {'
                '[readyState,${contents.readyState}][status,!{contents.status}]}');
        if (contents.readyState == HttpRequest.DONE) {
          if (contents.status == 200) {
            _embedIFrameInBody(
                ' data:text/html,' + contents.responseText,
                cleanUpProcess,
                iFrameSource);
          } else {
            if (allowRedirect) _openIFrameInCurrentTab(iFrameSource);
          }
        }
      }).catchError((e) {
        log.fine(
            'Function : _buildIFrameAsHtml, HttpRequest.request.catchError',
            e);
        if (allowRedirect) _openIFrameInCurrentTab(iFrameSource);
      });
    }
    log.fine('Function : _buildIFrameAsHtml, Return : void');
  }

  ///saves [_iFrame] and containing [_htmlDoc] for later use
  MyIFrame(HtmlDocument this._htmlDoc, IFrameElement this._iFrame) {
  }
}



///implimentation of NodeTreeSanitizer that allows the HTML to contain anything.
///Used to build unsafe iframes.
class _NonTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {
    //allow anything
  }
}
