// Copyright (c) 2015, Pappes. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pappes_utility.base;

part 'pappes_utility_ramcache.dart';

/// Pull the values of of a [Map] and comma seperate them with quotes.
///
///
String? mapToCSV(Map original) {
  return original.values.map(quoteString).join(',');
}

/// Convert.
///
///
String quoteString(dynamic original) {
  String? replacement = original?.toString().replaceAll('"', '""');
  return '"' + (replacement ?? '') + '"';
}
