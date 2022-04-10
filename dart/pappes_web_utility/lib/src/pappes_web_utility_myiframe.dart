// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Collection of utility classes and functions to make programs simpler.
part of pappes_web_utility.base;

/// Utility functions to abstract working with iframes.
///
/// ## purpose
///
/// * Extend built-in dart HTML functionality.
///

class MyIFrame {
  //TODO(pappes) remove direct reference to window
  IFrameElement
      _iFrame; //TODO (pappes) inherit from IframeElement would be better
  HtmlDocument _htmlDoc; //TODO(pappes) get doc from IFrame would be better

  /// Enhances the IFrame to make it more visible for the user.
  ///
  /// * attempts to inline the iframe
  /// * otherwise loads IFrame source in tab
  /// [cleanUpProcess] is an optional function that takes
  /// * a [HtmlDocument] (when the IFrame was loaded in the tab)
  /// * or [IFrameElement] (when the IFrame was inlined into the document)
  /// and runs extra cleanup processing on it
  makeProminant(
      [void cleanUpProcess(dynamic parentNode)?, bool allowRedirect = true]) {
    //TODO (pappes) fix typo in method name "Prominent"
    log.info(
        'Function : makeProminant, Parameters : {[cleanUpProcess,$cleanUpProcess], '
        '[allowRedirect,$allowRedirect]}');
    String iFrameSource = _iFrame.attributes['src']!;
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
  String? getIFrameHtml() {
    log.info('Function : getIFrameHtml, Parameters : {}');
    final innerHtml = MyJS.getIFrameHtml(_iFrame);
    log.fine('Function : getIFrameHtml, Return : $innerHtml');
    return (innerHtml);
  }

  /// Breaks tags and attributes commonly used for malicious activity.
  String _modifyHtmlToSanitise(String originalHtml) {
    log.info('Function : _modifyHtmlToSanitise, '
        'Parameters : {[originalHtml,$originalHtml]}');
    String retval = originalHtml
          ..replaceAll('class', 'crass')
          ..replaceAll('setTimeout', 'dontSetTimeout')
          ..replaceAll('style', 'smile')
          ..replaceAll('position:', 'poison:')
          ..replaceAll('position%3A', 'poison%3A')
          ..replaceAll('onclick', 'oncrick')
        //..replaceAll('<style', '<!--')
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
  _embedIFrameInBody(String contents,
      [void cleanUpProcess(dynamic parentNode)?, String? baseUrl]) {
    log.info('Function : _embedIFrameInBody, '
        'Parameters : {[contents,$contents][cleanUpProcess,$cleanUpProcess]'
        '[baseUrl,$baseUrl]}');
    String fragment = '<iframe id=iframe_rebuilt src=\'$contents\'>';
    fragment = _modifyHtmlToSanitise(fragment);
    Element iframeElement = MyHtml.createElementFromHTML(fragment);
    iframeElement
        .querySelectorAll('*')
        .forEach((Element e) => MyHtml.resolveElementUrl(e, baseUrl!));
    if (cleanUpProcess != null) cleanUpProcess(iframeElement);
    try {
      log.finer('Function : _embedIFrameInBody, '
          'insertBefore : [Value,${iframeElement.outerHtml}]'
          '[AheadOf,${_htmlDoc.body!.children.first.outerHtml}]');
      _htmlDoc.body!.insertBefore(iframeElement, _htmlDoc.body!.children.first);
    } catch (e) {
      log.finer(
          'Function : _embedIFrameInBody, append : ${iframeElement.outerHtml}');
      _htmlDoc.body!.append(iframeElement);
    }
    log.fine('Function : _embedIFrameInBody, Return : void');
  }

  /// Opens the [url] in the current browser tab.
  ///
  /// * [url] is the site to open
  /// * [cleanUpProcess] is an optional function that takes an
  ///   *[IFrameElement] and runs extra cleanup processing on it
  _openIFrameInCurrentTab(String url,
      [void cleanUpProcess(dynamic parentNode)?]) {
    log.info('Function : _openIFrameInCurrentTab, '
        'Parameters : {[url,$url][cleanUpProcess,$cleanUpProcess]}');
    window.location.assign(url);
    if (cleanUpProcess != null) cleanUpProcess(window.document);
    log.fine('Function : _openIFrameInCurrentTab, Return : void');
  }

  /// Converts an IFrame from referenced to inline
  /// and inserts it into the DOM (if source is available)
  /// or opens the IFrame in current tab (if the source is not available)
  _buildIFrameAsHtml(String iFrameSource,
      [void cleanUpProcess(dynamic parentNode)?, bool allowRedirect = true]) {
    log.info(
        'Function : _buildIFrameAsHtml, Parameters : {[iFrameSource,$iFrameSource]'
        '[cleanUpProcess,$cleanUpProcess], [allowRedirect,$allowRedirect]}');
    if (iFrameSource.contains('</html>')) {
      _embedIFrameInBody(iFrameSource, cleanUpProcess);
    } else if ((getIFrameHtml() ?? '') != '') {
      _embedIFrameInBody(
          ' data:text/html,' + getIFrameHtml()!, cleanUpProcess, iFrameSource);
    } else {
      //attempt to load external web site content
      HttpRequest.request(iFrameSource).then((contents) {
        log.finest('Function : _buildIFrameAsHtml, '
            'HttpRequest.request.contents__(expecting: 4,200)__ : {'
            '[readyState,${contents.readyState}][status,!{contents.status}]}');
        if (contents.readyState == HttpRequest.DONE) {
          if (contents.status == 200) {
            _embedIFrameInBody(' data:text/html,' + contents.responseText!,
                cleanUpProcess, iFrameSource);
          } else {
            if (allowRedirect) _openIFrameInCurrentTab(iFrameSource);
          }
        }
      }).catchError((e) {
        log.fine(
            'Function : _buildIFrameAsHtml, HttpRequest.request.catchError', e);
        if (allowRedirect) _openIFrameInCurrentTab(iFrameSource);
      });
    }
    log.fine('Function : _buildIFrameAsHtml, Return : void');
  }

  ///saves [_iFrame] and containing [_htmlDoc] for later use
  MyIFrame(HtmlDocument this._htmlDoc, IFrameElement this._iFrame) {}
}
