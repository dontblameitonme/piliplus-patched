# Bolt's Journal

## 2026-08-30 - Single-Pass Code-Unit Scanning vs Regex Splitting in Hot Parsers
**Learning:** `DurationUtils.parseDuration` previously used `split(RegExp)` + `.reversed.map(int.parse).toList()` + `pow(60, i)`. This allocated multiple intermediate objects (`List`, `ReversedListIterable`, `MappedIterable`) and performed double-precision `pow` floating-point math per iteration. Replacing this with a single-pass `codeUnitAt` character scan yielded a 7.25x speedup (from ~3230ms down to ~440ms for 1M calls) and 0 heap allocations.
**Action:** In Dart/Flutter hot paths (like list item parsing), avoid RegExp splitting and higher-order iterable chains. Use direct character codeUnit inspection instead.

## 2026-08-30 - Double-to-String Conversions Can Bottleneck Micro-Optimizations
**Learning:** Attempting to optimize `numFormat` via double division (`rounded10 / 10`) caused a regression because `double.toString()` invokes Grisu3 conversion algorithms in Dart VM.
**Action:** Always measure first and avoid introducing unnecessary `double` toString conversions in formatting functions.
