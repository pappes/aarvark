// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_web_utility.example;

import 'package:pappes_web_utility/pappes_web_utility.dart';

main() {
  print(base64Encode('Hello World'));
  print(base64Decode('SGVsbG8gV29ybGQ='));
  
  print(MyHtml.setUriSchemeToHttp('www.abc.com')); //prints 'http://www.abc.com'
  
  print(MyHtml.setUriParameters('http://www.abc.com?x=HelloWorld&a=b', searchFor: 'HelloWorld', replacementParameters: 'abc=123'));//prints 'http://www.abc.com?abc=123'
  
  print(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?u=www.realurl.com'));//prints 'http://www.realurl.com')
}
