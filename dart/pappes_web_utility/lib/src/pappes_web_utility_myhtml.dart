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
  /// Optionally can test for the presence of [searchFor] to identify URIs that should be modified.
  ///
  /// ## For example:
  ///    MyHtml.setUriParameters('http://www.abc.com?x=HelloWorld&a=b', searchFor: 'HelloWorld', replacementParameters: 'abc=123')
  static String setUriParameters(String originalUrl, {String searchFor, String replacementParameters}) {
    String finalUrl;

    Uri x = Uri.parse(originalUrl);
    if (searchFor == null || x.query.toLowerCase().contains(searchFor.toLowerCase())) {
      x = new Uri(scheme: x.scheme, userInfo: x.userInfo, host: x.host, port: x.port, path: x.path, query: replacementParameters);
    }
    finalUrl = x.toString();

    if (RamCache.recall('loglevel') == '[INFO]') print('''
             setUriParameters 
                  originalUrl: $originalUrl 
              became finalUrl: $finalUrl''');
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
    final Map params = Uri.parse(originalUrl).queryParameters;
    if (params is Map) for (String param in params.values) {
      // we have a web address so use it now
      if (param.toLowerCase().startsWith('www') || param.toLowerCase().startsWith('http')) {
        finalUrl = param;
        break;
      }
      //check that it is not null before decoding it.  Store decoded value for later if it is a valid URL.
      if (base64Decode(param) != null && (base64Decode(param).toLowerCase().startsWith('www') || base64Decode(param).toLowerCase().startsWith('http'))) {
        base64Uri = base64Decode(param);
      }
    }
    finalUrl = setUriSchemeToHttp(ifNull(finalUrl, base64Uri));
    finalUrl = ifNull(finalUrl, originalUrl);
    if (RamCache.recall('loglevel') == '[INFO]') print('''
            removeUrlRediriect 
                  originalUrl: $originalUrl 
              became finalUrl: $finalUrl''');
    return finalUrl;
  }

  /// Changes [originalURL] to use the http protocol if none specified.
  ///
  /// This is used to unsure that URLs that do not include the scheme
  /// are treated as absolute paths (not relative to the document URL).
  static String setUriSchemeToHttp(String originalURL) {
    String finalURL;
    Uri parsedUri;
    try {
      parsedUri = Uri.parse(originalURL);
      if (parsedUri.scheme == '') {
        finalURL = parsedUri.replace(scheme: 'http', path: r'//' + parsedUri.path).toString();
        //the following line to to work around a bug in Darts URI library
        finalURL = finalURL.replaceFirst(r'http:////', r'http://');
      }
    } catch (e) { //invalid URLs to be passed back unmodified
    }
    return ifNull(finalURL, originalURL);
  }

  /// Creates an HTML element from any valid [htmlFragment] of HTML.
  ///
  /// Does not have any of the normal security limitations.
  static Element createElementFromHTML(String htmlFragment) {
    return new Element.html(htmlFragment, treeSanitizer: new _NonTreeSanitizer());
  }

  /// Alters a specific [attribute] of a HTML [Element], [node]
  /// by applying function [alter] to the [attribute].
  ///
  /// * [node] - any HTML [Element].
  /// * [attribute] - the name of the attribute to be modifiied.
  /// * [alter] - a function that takes in the old value and returns the new value.
  ///
  /// The following example uses alterAttribute to modify an attribute on an Element.
  /// Specifically it is altering the href attribute on a anchor element
  ///     <a href=http://www.google.com> go to google </a>
  /// the function removeUrlRedirect would be a declared to pass in a href [String]
  /// and return a modified href [string]
  ///
  ///     alterAttribute(element, 'href', (url) => removeUrlRedirect(url)));
  ///
  static void alterAttribute(Element node, String attribute, Object alter(Object a)) {
    assert(alter is _MyHtml_Alter_Element);
    if (node.attributes.containsKey(attribute)) {
      node.attributes[attribute] = alter(node.attributes[attribute]);
    }
  }

  /// Applies a [process] to every element of a HTML [DOM] element
  /// (or any other HTML [Element]).
  ///
  /// * [process] is a procedure that takes a single HTML [Element] and returns nothing
  ///
  ///    iterateHTMLDOM(document.body, (e) => printElement(e));
  static void iterateHTMLDOM(Element DOM, void process(Element e)) {
    assert(process is _MyHtml_Element_Process);
    if (DOM.hasChildNodes()) DOM.children.forEach((child) => iterateHTMLDOM(child, process));
    process(DOM);
  }
  
  /// Removes all script tags from [htmlDoc].
  static void removeAllScripts(HtmlDocument htmlDoc) {
    htmlDoc.querySelectorAll('script').forEach((Element e) {
      e.remove();
    });
  }

  /// Removes all event handlers from all elements on the browser DOM.
  static void removeAllHandlers(HtmlDocument htmlDoc) {
    //clone the items in the body to sever any event handlers
    htmlDoc.body.children.toSet().forEach((Element e) => e.replaceWith(e.clone(true)));
    MyJS.removeAllTimers();
  }

  /// Changes the target of all <a> anchor href elementsin [htmlDoc].
  ///
  /// * Default [target] is '_blank' (new tab)
  /// * Valid values for [target] are '_blank', '_self', '_parent', '_top', or _framename_
  static void retargetAllHrefs(HtmlDocument htmlDoc, [String target = '_blank']) {
    htmlDoc.querySelectorAll('a').forEach((Element e) => e.attributes['target'] = target);
  }

  /// Removes any element that obsures another element from [htmlDoc].
  ///
  /// If there is an iFrame on the page, finds the widest iFrame and:
  /// *if it is referenced and source is available, moves it inline
  /// *if it is referenced and source is not available, opens it in the current tab
  /// *if it is inline, opens it in the current tab
  /// 
  /// IFrame or not it then, strips out everything except:
  /// * <a> tags that are based on text (leave hyperlinks, removes buttons)
  /// * <object> tags to allow videos to remain
  /// * <video> tags to allow videos to remain
  /// * <input> tags to allow searching
  /// and keep all elements that are parents of these elements
  /// 
  ///    removeAllOverlays(document);
  static void removeAllOverlays(HtmlDocument htmlDoc) {
    _stripDownPage(htmlDoc);
    ElementList iFrames = htmlDoc.querySelectorAll('iframe');
    if (iFrames != null) {
      iFrames.sort(_compareElementWidth);
      new MyIFrame(htmlDoc, iFrames.last).makeProminant(_stripDownPage);
    }
  }

  /// Impliments Comparator to allow sorting [Element]s based on ClientWidth;
  static int _compareElementWidth(Element a, Element b) {
    return a.clientWidth < b.clientWidth ? -1 : 1;
  }

  /// Remove unwanted HTML [Element] tags from a [HtmlDocument] or [ParentNode]
  /// 
  /// strips out everything except:
  /// * <a> tags that are based on text (leave hyperlinks, removes buttons)
  /// * <object> tags to allow videos to remain
  /// * <video> tags to allow videos to remain
  /// * <input> tags to allow searching
  /// and keep all elements that are parents of these elements
  /// 
  ///    _stripDownPage(document);
  static void _stripDownPage(target) {
    //internal recursive function
    void _whitelistElementAndParents(Element e, Set s) {
      if (e.parent != null) _whitelistElementAndParents(e.parent, s);
      s.remove(e);
    }

    Set<Element> elementsToBeDeleted = target.querySelectorAll('*').toSet();

    //whitelist all elements of type input so that the user can still search
    target.querySelectorAll('input').forEach((e) => _whitelistElementAndParents(e, elementsToBeDeleted));
    //whitelist all elements of type object so the user can watch videos
    target.querySelectorAll('object').forEach((e) => _whitelistElementAndParents(e, elementsToBeDeleted));
    //whitelist all elements of type video so the user can watch videos
    target.querySelectorAll('video').forEach((e) => _whitelistElementAndParents(e, elementsToBeDeleted));
    //whitelist all elements of type iframe so that external content can remain
    target.querySelectorAll('iframe').forEach((e) => _whitelistElementAndParents(e, elementsToBeDeleted));
    //whitelist all elements of type anchor that have text so the user can click on links but not buttons
    target.querySelectorAll('a').forEach((Element e) {
      if (e.text != null) _whitelistElementAndParents(e, elementsToBeDeleted);
    });
    //destroy everything that remains
    elementsToBeDeleted.forEach((Element e) => e.remove());
    if (target is HtmlDocument) {
      removeAllHandlers(target);
    }
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




class MyIFrame{//TODO(pappes) remove direct reference to window
  IFrameElement _iFrame;//TODO (pappes) inherit from IframeElement would be better
  HtmlDocument _htmlDoc;//TODO(pappes) get doc from IFrame would be better
  
  /// Enhances the IFrame to make it more visible for the user.
  /// 
  /// * attempts to inline the iframe
  /// * otherwise loads IFrame source in tab
  /// [cleanUpProcess] is an optional function that takes 
  /// * a [HtmlDocument] (when the IFrame was loaded in the tab)
  /// * or [IFrameElement] (when the IFrame was inlined into the document)
  /// and runs extra cleanup processing on it 
  makeProminant([void cleanUpProcess(dynamic parentNode)]) {
    String iFrameHtml;
    if (Uri.parse(window.location.href).host == Uri.parse(_iFrame.attributes['src']).host) {
      iFrameHtml = _buildIFrameAsHtml(_iFrame, cleanUpProcess);
    }
    if (iFrameHtml != null) {
      _htmlDoc.querySelectorAll('iframe').forEach((Element frame) => frame.remove()); //remove all iFrames from document body
      _embedIFrameInBody(iFrameHtml, cleanUpProcess);
    } else {
      window.location.assign(_iFrame.attributes['src']);
    }
    if (cleanUpProcess != null) cleanUpProcess(_htmlDoc);
  }

  /// Breaks tags and attributes commonly used for malicious activity.
  String _modifyHtmlToSanitise(String originalHtml) {
    return originalHtml
        ..replaceAll('class', 'crass')
        ..replaceAll('setTimeout', 'dontSetTimeout')
        ..replaceAll('style', 'smile')
        ..replaceAll('position:', 'poison:')
        ..replaceAll('position%3A', 'poison%3A')
        ..replaceAll('onclick', 'oncrick')
        //..replaceAll('<style', '<!--')
        //..replaceAll('</style>', '-->')
    ;
  }

  /// Inserts an [IFrameElement] to the start of the document.
  /// 
  /// * [contents] can be either a URL or a HTML in a string
  /// * [cleanUpProcess] is an optional function that takes an [IFrameElement] and runs extra cleanup processing on it
  _embedIFrameInBody(String contents, [void cleanUpProcess(dynamic parentNode)]) {
    String fragment = '<iframe src=\'$contents\'>';
    fragment = _modifyHtmlToSanitise(fragment);
    Element iframeElement = MyHtml.createElementFromHTML(fragment);
    if (cleanUpProcess != null) cleanUpProcess(iframeElement);
    _htmlDoc.body.insertBefore(_htmlDoc.body.children.first, iframeElement);
  }

  /// Converts an IFrame from referenced to inline and inserts it into the DOM (if source is available)
  /// or opens the IFrame in a new tab (if the source is not available)
  _buildIFrameAsHtml(Element e, [void cleanUpProcess(dynamic parentNode)]) {
    if (e.attributes['src'].contains('</html>')) {
      _embedIFrameInBody(e.attributes['src'], cleanUpProcess);
    } else {
      //attempt to load external web site content
      //TODO(pappes) redirect iFrame conents to be absolute addresses not relative
      HttpRequest.request(e.attributes['src'])
      .then((contents) => _embedIFrameInBody(' data:text/html,'+contents))
      .catchError((e) => window.location.assign(e.attributes['src']));
    }
  }
  
  ///saves [_iFrame] and containing [_htmlDoc] for later use
  MyIFrame(HtmlDocument this._htmlDoc, IFrameElement this._iFrame) {
  }
  
}



///implimentation of NodeTreeSanitizer that allows the HTML to contain anything.  Used to build unsafe iframes.
class _NonTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {
    //allow anything
  }
}
