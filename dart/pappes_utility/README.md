# pappes_utility

A library for Pappes.   Others may find it useful.

## Usage

A simple usage example:

    import 'package:pappes_utility/pappes_utility.dart';

    main() {
      int x=10;
      int y=20;
      x = ifNull(x, y);//use x if it has a value otherwise use y
      
      
      RamCache.remember('MyKey', x);
      print(RamCache.recall('MyKey'));
      RamCache.forget('MyKey');
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/pappes/aarvark/issues
