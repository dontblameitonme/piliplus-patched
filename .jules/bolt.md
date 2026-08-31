## 2026-08-20 - Static RegExp Reuse in Flutter Callbacks
**Learning:** Re-creating `RegExp` instances inside inner event callbacks (such as link tap gesture recognizers) causes redundant object allocations and regex re-compilation on user interactions in item widgets.
**Action:** Always promote static patterns used inside item build methods or tap handlers to `static final` class fields so they are compiled only once.
