// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.example;

import 'package:pappes_web_utility/pappes_web_utility.dart';
import 'dart:html';

main() {
  print(base64Encode('Hello World')); //prints 'SGVsbG8gV29ybGQ='
  print(base64Decode('SGVsbG8gV29ybGQ=')); //prints 'Hello World'
  print(MyJS.runAnyJavaScript('1+2'));  //prints '3'
  MyJS.runAnyJavaScript('console.log("calculate 1+2 = " + (1+2));');//writes to the console 'calculate 1+2 = 3'
  
  print(MyHtml.setUriSchemeToHttp('www.abc.com')); //prints 'http://www.abc.com'
  
  print(MyHtml.setUriParameters('http://www.abc.com?x=HelloWorld&a=b', searchFor: 'HelloWorld', replacementParameters: 'abc=123'));//prints 'http://www.abc.com?abc=123'

  print(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?u=www.realurl.com'));//prints 'http://www.realurl.com')

  print(MyHtml.createElementFromHTML('<iframe src="www.google.com"></iframe>').outerHtml);//prints '<iframe src="www.google.com"></iframe>')
  print(new             Element.html('<iframe src="www.google.com"></iframe>').outerHtml);//prints '<iframe></iframe>')
}
