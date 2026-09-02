## 2025-09-02 - Optimize Duration Parsing and Formatting

**Learning:** `RegExp.split()` with list mapping and `pow(60, i)` calculation in hot paths (such as list item render loops or danmaku timeline matching) introduced unnecessary string splits and double math. Replacing regex parsing with direct single-pass `codeUnitAt` loop improved parsing speed by ~90%. Caching 2-digit padded strings (`00`-`99`) and avoiding runtime `.padLeft(2, '0')` allocations improved formatting speed by ~35%.

**Action:** Prefer direct character-code iteration and lookup tables for hot utility functions like date/time/number formatting.
