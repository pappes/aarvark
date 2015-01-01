// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.MyHtml.test;

import 'package:unittest/unittest.dart';
import 'dart:html';
import 'package:pappes_web_utility/pappes_web_utility.dart';

void main() => defineTests();

void defineTests() {

  group('pappes_web_utility MyHtml tests for remove URI paramseters', () {
    test('no paramaters', () => expect(MyHtml.setUriParameters('http://www.abc.com'), 'http://www.abc.com'));
    test('two existing parameters', () => expect(MyHtml.setUriParameters('http://www.abc.com?x=y&a=b'), 'http://www.abc.com'));
    test('supply replacement', () => expect(MyHtml.setUriParameters('http://www.abc.com?x=y&a=b', replacementParameters: 'abc=123'), 'http://www.abc.com?abc=123'));
    test('able to find match', () => expect(MyHtml.setUriParameters('http://www.abc.com?x=HelloWorld&a=b', searchFor: 'HelloWorld'), 'http://www.abc.com'));
    test('not able to find match', () => expect(MyHtml.setUriParameters('http://www.abc.com?x=y&a=b', searchFor: 'HelloWorld'), 'http://www.abc.com?x=y&a=b'));
    test('supply replacement able to find match', () => expect(MyHtml.setUriParameters('http://www.abc.com?x=HelloWorld&a=b', searchFor: 'HelloWorld', replacementParameters: 'abc=123'), 'http://www.abc.com?abc=123'));
    test('supply replacement not able to find match', () => expect(MyHtml.setUriParameters('http://www.abc.com?x=y&a=b', searchFor: 'HelloWorld', replacementParameters: 'abc=123'), 'http://www.abc.com?x=y&a=b'));
    });  
  
  group('pappes_web_utility MyHtml tests for set scheme', () {
    test('existing http scheme', () => expect(MyHtml.setUriSchemeToHttp('http://www.abc.com'), 'http://www.abc.com'));
    test('existing https scheme', () => expect(MyHtml.setUriSchemeToHttp('https://www.abc.com'), 'https://www.abc.com'));
    test('existing ftp scheme', () => expect(MyHtml.setUriSchemeToHttp('ftp://www.abc.com'), 'ftp://www.abc.com'));
    test('no existing scheme', () => expect(MyHtml.setUriSchemeToHttp('www.abc.com'), 'http://www.abc.com'));
    });  
  
  group('pappes_web_utility MyHtml removeUrlRedirect tests', () {
     test('test modified HTML state', () => expect(MyHtml.removeUrlRedirect('http://www.abc.com/noredirect?u=realurl_com'), 'http://www.abc.com/noredirect?u=realurl_com'));
     test('redirect_simple_www', () =>  expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?u=www.realurl.com'), 'http://www.realurl.com'));
     test('redirect_simple_http', () =>    expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?u=http://www.realurl.com'), 'http://www.realurl.com'));
     test('redirect_simple_http_dir', () =>  expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?u=http://www.realurl.com/target/'), 'http://www.realurl.com/target/'));
     test('redirect_http_param', () => expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?u=http://www.realurl.com/target/?x=y&a=b'), 'http://www.realurl.com/target/?x=y'));
     test('redirect_http_fake_param', () => expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?u=http://www.realurl.com/target/&x=y&a=b'), 'http://www.realurl.com/target/'));//unusual expectd /&x=y
     test('redirect_http_url_encode', () =>   expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?u=http%3A%2F%2Fwww.realurl.com%2Ftarget%2F'), 'http://www.realurl.com/target/'));
     test('redirect_http_url_encode_param', () => expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?u=http%3A%2F%2Fwww.realurl.com%2Ftarget%2F%3Fx%3Dy%26a%3Db'), 'http://www.realurl.com/target/?x=y&a=b'));
     test('redirect_http_fake_b64_encode', () => expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?l=YTo5OntzOjE6ImMiO2k6MTtzOjM6InNpZCI7aToxNTU5O3M6MzoiaWlkIjtpOjQ5O3M6MjoiaXQiO3M6MjoiaWMiO3M6MzoiZ2lkIjtzOjc6Ijc4NzU1NzAiO3M6NDoia3dpZCI7aTo1ODY5O3M6NDoiY3NpZCI7czozOiIzNTkiO3M6MzoicG9zIjtpOjE7czoyOiJycyI7aToxMTt9&u=http://www.realurl.com/target/?x=y&a=b'), 'http://www.realurl.com/target/?x=y'));
     test('redirect_http_fake_b64_encode_param', () => expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?l=YTo5OntzOjE6ImMiO2k6MTtzOjM6InNpZCI7aToxNTU5O3M6MzoiaWlkIjtpOjQ5O3M6MjoiaXQiO3M6MjoiaWMiO3M6MzoiZ2lkIjtzOjc6Ijc4NzU1NzAiO3M6NDoia3dpZCI7aTo1ODY5O3M6NDoiY3NpZCI7czozOiIzNTkiO3M6MzoicG9zIjtpOjE7czoyOiJycyI7aToxMTt9&u=http%3A%2F%2Fwww.realurl.com%2Ftarget%2F%3Fx%3Dy%26a%3Db'), 'http://www.realurl.com/target/?x=y&a=b'));
     test('redirect_http_b64_encode', () => expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?l=aHR0cDovL3d3dy5yZWFsdXJsLmNvbS90YXJnZXQvP2M9ZCZlPTEyMw=='), 'http://www.realurl.com/target/?c=d&e=123'));
     test('redirect_http_b64_encode_param', () => expect(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?l=aHR0cDovL3d3dy5yZWFsdXJsLmNvbS90YXJnZXQvP2M9ZCZlPTEyMw==&x=y&a=b'), 'http://www.realurl.com/target/?c=d&e=123'));
   });
  
  group('pappes_web_utility MyHtml integration tests test initial HTML state ', () {
    test('non_redirect', () => expect(document.querySelector('#non_redirect').attributes['href'], 'http://www.abc.com/noredirect?u=realurl_com'));
    test('redirect_simple_www', () =>  expect(document.querySelector('#redirect_simple_www').attributes['href'], 'http://www.abc.com/redirect?u=www.realurl.com'));
    test('redirect_simple_http', () =>  expect(document.querySelector('#redirect_simple_http').attributes['href'], 'http://www.abc.com/redirect?u=http://www.realurl.com'));
    test('redirect_simple_http_dir', () =>  expect(document.querySelector('#redirect_simple_http_dir').attributes['href'], 'http://www.abc.com/redirect?u=http://www.realurl.com/target/'));
    test('redirect_http_param', () =>  expect(document.querySelector('#redirect_http_param').attributes['href'], 'http://www.abc.com/redirect?u=http://www.realurl.com/target/?x=y&a=b'));
    test('redirect_http_fake_param', () =>  expect(document.querySelector('#redirect_http_fake_param').attributes['href'], 'http://www.abc.com/redirect?u=http://www.realurl.com/target/&x=y&a=b'));
    test('redirect_http_url_encode', () =>  expect(document.querySelector('#redirect_http_url_encode').attributes['href'], 'http://www.abc.com/redirect?u=http%3A%2F%2Fwww.realurl.com%2Ftarget%2F'));
    test('redirect_http_url_encode_param', () =>  expect(document.querySelector('#redirect_http_url_encode_param').attributes['href'], 'http://www.abc.com/redirect?u=http%3A%2F%2Fwww.realurl.com%2Ftarget%2F%3Fx%3Dy%26a%3Db'));
    test('redirect_http_fake_b64_encode', () =>  expect(document.querySelector('#redirect_http_fake_b64_encode').attributes['href'], 'http://www.abc.com/redirect?l=YTo5OntzOjE6ImMiO2k6MTtzOjM6InNpZCI7aToxNTU5O3M6MzoiaWlkIjtpOjQ5O3M6MjoiaXQiO3M6MjoiaWMiO3M6MzoiZ2lkIjtzOjc6Ijc4NzU1NzAiO3M6NDoia3dpZCI7aTo1ODY5O3M6NDoiY3NpZCI7czozOiIzNTkiO3M6MzoicG9zIjtpOjE7czoyOiJycyI7aToxMTt9&u=http://www.realurl.com/target/?x=y&a=b'));
    test('redirect_http_fake_b64_encode_param', () =>  expect(document.querySelector('#redirect_http_fake_b64_encode_param').attributes['href'], 'http://www.abc.com/redirect?l=YTo5OntzOjE6ImMiO2k6MTtzOjM6InNpZCI7aToxNTU5O3M6MzoiaWlkIjtpOjQ5O3M6MjoiaXQiO3M6MjoiaWMiO3M6MzoiZ2lkIjtzOjc6Ijc4NzU1NzAiO3M6NDoia3dpZCI7aTo1ODY5O3M6NDoiY3NpZCI7czozOiIzNTkiO3M6MzoicG9zIjtpOjE7czoyOiJycyI7aToxMTt9&u=http%3A%2F%2Fwww.realurl.com%2Ftarget%2F%3Fx%3Dy%26a%3Db'));
    test('redirect_http_b64_encode', () =>  expect(document.querySelector('#redirect_http_b64_encode').attributes['href'], 'http://www.abc.com/redirect?l=aHR0cDovL3d3dy5yZWFsdXJsLmNvbS90YXJnZXQvP2M9ZCZlPTEyMw=='));
    test('redirect_http_b64_encode_param', () =>  expect(document.querySelector('#redirect_http_b64_encode_param').attributes['href'], 'http://www.abc.com/redirect?l=aHR0cDovL3d3dy5yZWFsdXJsLmNvbS90YXJnZXQvP2M9ZCZlPTEyMw==&x=y&a=b'));
    });  

  group('pappes_web_utility MyHtml integration tests change state', () {
    test('alter href links', () {
      expect(MyHtml.iterateHTMLDOM(
          document.body, 
          (element) => MyHtml.alterAttribute(
              element, 
              'href', 
              (url) => MyHtml.removeUrlRedirect(url)))
    , isNull);
    });
  });  
  
 group('pappes_web_utility MyHtml integration tests test modified HTML state', () {
    test('test modified HTML state', () => expect(document.querySelector('#non_redirect').attributes['href'], 'http://www.abc.com/noredirect?u=realurl_com'));
    test('redirect_simple_www', () =>  expect(document.querySelector('#redirect_simple_www').attributes['href'], 'http://www.realurl.com'));
    test('redirect_simple_http', () =>    expect(document.querySelector('#redirect_simple_http').attributes['href'], 'http://www.realurl.com'));
    test('redirect_simple_http_dir', () =>  expect(document.querySelector('#redirect_simple_http_dir').attributes['href'], 'http://www.realurl.com/target/'));
    test('redirect_http_param', () => expect(document.querySelector('#redirect_http_param').attributes['href'], 'http://www.realurl.com/target/?x=y'));
    test('redirect_http_fake_param', () => expect(document.querySelector('#redirect_http_fake_param').attributes['href'], 'http://www.realurl.com/target/'));//unusual expectd /&x=y
    test('redirect_http_url_encode', () =>   expect(document.querySelector('#redirect_http_url_encode').attributes['href'], 'http://www.realurl.com/target/'));
    test('redirect_http_url_encode_param', () => expect(document.querySelector('#redirect_http_url_encode_param').attributes['href'], 'http://www.realurl.com/target/?x=y&a=b'));
    test('redirect_http_fake_b64_encode', () => expect(document.querySelector('#redirect_http_fake_b64_encode').attributes['href'], 'http://www.realurl.com/target/?x=y'));
    test('redirect_http_fake_b64_encode_param', () => expect(document.querySelector('#redirect_http_fake_b64_encode_param').attributes['href'], 'http://www.realurl.com/target/?x=y&a=b'));
    test('redirect_http_b64_encode', () => expect(document.querySelector('#redirect_http_b64_encode').attributes['href'], 'http://www.realurl.com/target/?c=d&e=123'));
    test('redirect_http_b64_encode_param', () => expect(document.querySelector('#redirect_http_b64_encode_param').attributes['href'], 'http://www.realurl.com/target/?c=d&e=123'));
  });
}

