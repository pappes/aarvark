# pappes_utility

A library for Pappes.   Others may find it useful.

## Usage

A simple usage example:

    import 'package:pappes_utility/pappes_utility.dart';

    main() {
      Map values = {'a': 1, 'b': 'abc"def'};
      final csv = mapToCSV(values); // will return "1","abc""def"
      
      RamCache.remember('MyKey', x);
      print(RamCache.recall('MyKey'));
      RamCache.forget('MyKey');
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/pappes/aarvark/issues
