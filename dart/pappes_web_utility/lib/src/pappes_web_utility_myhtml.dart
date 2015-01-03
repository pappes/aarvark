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
    if (searchFor == null || x.query.toLowerCase().contains(searchFor.toLowerCase()))
      x = new Uri(
          scheme: x.scheme, 
          userInfo: x.userInfo, 
          host: x.host, 
          port: x.port, 
          path: x.path,
          query: replacementParameters);
    finalUrl = x.toString();
        
    if (RamCache.recall('loglevel')=='[INFO]')
      print ('''
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
    if (RamCache.recall('loglevel')=='[INFO]')
      print ('''
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
        finalURL = parsedUri.replace(scheme: 'http', path: r'//'+parsedUri.path).toString();
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
    return new Element.html(htmlFragment,treeSanitizer:new _NonTreeSanitizer());
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
    assert( alter is _MyHtml_Alter_Element);
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
    assert( process is _MyHtml_Element_Process);
    if (DOM.hasChildNodes()) 
      DOM.children.forEach((child) => iterateHTMLDOM(child, process));
    process(DOM);
  }
  
  /// Removes any element that obsures another element.
  static void removeAllOverlays() {
  }
  
  /// Removes all scripts from the browser DOM.
  static void removeAllScripts() {
    document.querySelectorAll('script').forEach((Element e) {
      print(e.attributes['src']);
      e.remove();
    });
  }
  
  /// Removes all event handlers from all elements on the browser DOM.
  static void removeAllHandlers() {
  }
  
  /// Changes the target of all <a> anchor href elements.  
  /// 
  /// * Default [target] is '_blank' (new tab)
  /// * Valid values for [target] are '_blank', '_self', '_parent', '_top', or _framename_
  static void retargetAllHrefs([String target = '_blank']) {
    document.querySelectorAll('a').forEach((Element e) => e.attributes['target'] = target);
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




///implimentation of NodeTreeSanitizer that allows the HTML to contain anything
class _NonTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {
    //allow anything
  }
}
