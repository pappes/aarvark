// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.MyHtml.very.dest.test;

import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'dart:html';
import 'package:pappes_web_utility/pappes_web_utility.dart';

void main() => defineTests();

void defineTests() {
  
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });


  group('pappes_web_utility MyHtml removeAllOverlays tests initial HTML state', () {
    test('element_p', () => expect(document.querySelector('#outside_p').attributes['id'], 'outside_p'));
    test('element_a_text', () => expect(document.querySelector('#outside_anchor_text').attributes['id'], 'outside_anchor_text'));
    test('element_a_blank', () => expect(document.querySelector('#outside_anchor_button').attributes['id'], 'outside_anchor_button'));
    test('element_iframe', () => expect(document.querySelector('#outside_iframe').attributes['src'], 'pappes_web_utility_myhtml_iframe_test.html'));
    test('element_iframe_unnamed', () => expect(document.querySelector('iframe').attributes['src'], 'pappes_web_utility_myhtml_iframe_test.html'));
    //test('element_frame', () => expect(document.querySelector('#outside_frame_a').attributes['id'], 'outside_frame_a'));
    test('element_frame', () => expect(document.querySelector('#outside_frame_a'), isNull));//dart cant find frames
    //test('element_frame_unnamed', () => expect(document.querySelector('frame').attributes['id'], 'outside_frame_a'));
    test('element_frame_unnamed', () => expect(document.querySelector('frame'), isNull));//dart cant find frames
    test('element_p', () => expect(document.querySelector('#inside_p'), isNull));
    test('element_a_text', () => expect(document.querySelector('#inside_anchor_text'), isNull));
    test('element_a_blank', () => expect(document.querySelector('#inside_anchor_button'), isNull));
    test('element_frame', () => expect(document.querySelector('#inside_frame_a'), isNull));
  });
  group('pappes_web_utility MyHtml removeAllOverlays change state', () {
    test('alter href links', () {
      expect(MyHtml.removeAllOverlays(document), isNull);
    });
  });
  group('pappes_web_utility MyHtml removeAllOverlays tests intermediate HTML state', () {
    test('element_p', () => expect(document.querySelector('#outside_p'), isNull));
    test('element_a_text', () => expect(document.querySelector('#outside_anchor_text').attributes['id'], 'outside_anchor_text'));
    test('element_a_blank', () => expect(document.querySelector('#outside_anchor_button'), isNull));
    /*test('element_iframe', () => expect(document.querySelector('#iframe_rebuilt').attributes['id'], 'iframe_rebuilt'));
    test('element_iframe_unnamed', () => expect(document.querySelector('iframe').attributes['id'], 'iframe_rebuilt'));
    timeing issues with tests being run before frame creation is completed
     */
    test('element_frame', () => expect(document.querySelector('#outside_frame_a'), isNull));
    test('element_frame_unnamed', () => expect(document.querySelector('#frame'), isNull));
    test('element_p', () => expect(document.querySelector('#inside_p'), isNull));
    test('element_a_text', () => expect(document.querySelector('#inside_anchor_text'), isNull));
    test('element_a_blank', () => expect(document.querySelector('#inside_anchor_button'), isNull));
    test('element_frame', () => expect(document.querySelector('#inside_frame_a'), isNull));
  });
  
  //*/ * this kills the test because of a timing issue
  group('pappes_web_utility MyHtml removeAllOverlays change state', () {
    test('alter href links', () {
      expect(MyHtml.removeAllOverlays(document), isNull);
    });
  });
  group('pappes_web_utility MyHtml removeAllOverlays tests final HTML state', () {
    test('outside_element_p', () => expect(document.querySelector('#outside_p'), isNull));
    //test('outside_element_a_text', () => expect(document.querySelector('#outside_anchor_text'), isNull));
    test('outside_element_a_blank', () => expect(document.querySelector('#outside_anchor_button'), isNull));
    test('outside_element_iframe', () => expect(document.querySelector('#outside_iframe'), isNull));
    test('outside_element_frame', () => expect(document.querySelector('#outside_frame_a'), isNull));
    test('inside_element_p', () => expect(document.querySelector('#inside_p'), isNull));
    test('inside_element_a_text', () => expect(document.querySelector('#inside_anchor_text'), isNull));
    test('inside_element_a_blank', () => expect(document.querySelector('#inside_anchor_button'), isNull));
    test('inside_element_frame', () => expect(document.querySelector('#inside_frame_a'), isNull));
  });

}
