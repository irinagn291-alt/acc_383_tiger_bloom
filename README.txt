TIGER BLOOM
An offline animal coloring studio for iPhone and iPad.

Open TigerBloom.xcodeproj and run the shared TigerBloom scheme in Xcode.
Minimum OS: iOS 17.0. Bundle ID: studio.tiger.bloom.
Choose your development team to run on a physical device.

ONE SWIFT FILE
TigerBloom.swift contains the complete app: the 100-page catalog, views,
coloring renderer, undo history, local storage, camera, photo conversion,
import, export, favorites and the UI test suite. The BLOOM_UI_TESTS condition
compiles the XCTest section only in the test target. The application target
contains no testing screens or launch shortcuts. Images and paintable-region
data are bundled separately in Assets.xcassets. No third-party packages.

COLLECTION
100 distinct offline coloring pages: 70 tigers and 30 other animals.
Tigers include cubs, families, jungle and snow scenes, portraits, geometric
patterns, flowers, paper boats, telescopes, lanterns and other playful scenes.
Artwork is curated from the existing Tiger Trails and Tiger Press libraries.
The interface, navigation, palette and combined coloring studio are specific
to Tiger Bloom. All interface copy is English.

FEATURES
- Explore: search by animal or scene; Tigers, Wildlife and Favorites filters.
- My Art: saved coloring pages and imported photo pages.
- Fill shapes, paint with a brush, erase, move and zoom the canvas.
- Fourteen preset colors and a custom color picker.
- Adjustable brush size and optional clipping inside an outlined region.
- Undo/redo and reversible reset. Edits are saved automatically on device.
- Camera capture and the native photo picker. Camera access is requested
  only when Camera is tapped. Canceling or denying access preserves artwork.
- Photo Lab turns a photo into a simplified, paintable mosaic of shapes.
  Conversion is entirely local; images are not uploaded.
- Export a 1800 x 1800 PNG to Photos or Files.
- Long-press a gallery card to delete a custom photo page after confirmation.

QA
The shared scheme includes four UI journeys: coloring/persistence/export,
brush/erase/undo history, collections/search/favorites, and photo import.
When working in gambling_factory, run simulator QA through simulator_pool.py
as required by the repository's AGENTS.md. Physical camera capture requires
a real device; the simulator checks the camera-unavailable fallback.
