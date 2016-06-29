# pappes_web_utility

A library for Pappes.  Others might find it useful

## Usage

A simple usage example:

    import 'package:pappes_web_utility/pappes_web_utility.dart';

    main() {
      print(base64Encode('Hello World'));
      print(base64Decode('SGVsbG8gV29ybGQ='));
      
      print(MyHtml.setUriSchemeToHttp('www.abc.com')); //prints 'http://www.abc.com'
      print(MyHtml.removeUrlRedirect('http://www.abc.com/redirect?u=www.realurl.com'));//prints 'http://www.realurl.com')
      print(MyHtml.setUriParameters('http://www.abc.com?x=HelloWorld&a=b', searchFor: 'HelloWorld', replacementParameters: 'abc=123'));//prints 'http://www.abc.com?abc=123'
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/pappes/aarvark/issues
