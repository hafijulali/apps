'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"icons/Icon-512.png": "f67e19d1a8fd4ab69d9224ff7ec882ec",
"icons/Icon-maskable-512.png": "f67e19d1a8fd4ab69d9224ff7ec882ec",
"icons/Icon-192.png": "909c0ce7f3eaa4b0c49dffd0da280995",
"icons/Icon-maskable-192.png": "909c0ce7f3eaa4b0c49dffd0da280995",
"manifest.json": "602ff65a4bd69c7706194e68e325b40e",
"main.dart.mjs": "b674d5e83fc99663f89e3a946c300ebd",
"index.html": "dbfd61edba317ce6b814be5b87afeb30",
"/": "dbfd61edba317ce6b814be5b87afeb30",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "057187f1bae0d5dec0461d6bf65628ad",
"assets/assets/biped-robot.png": "0a29f007ee2c98758349dfe751f7a46e",
"assets/assets/smart-water-level-monitor.png": "692dd4914454102bea07c174b1c0c8c6",
"assets/assets/byte-advice.png": "c8e73d943b473dfb8e324c366dc30fda",
"assets/assets/cli-2048-game.png": "9a7b1b17511b48de95d53dd7ca774996",
"assets/assets/portrait-self.jpg": "b71139cad40108247e23d38031ecefdf",
"assets/assets/alive.png": "4a525c3ded9f83635c295d5a4e546ac8",
"assets/assets/portrait.jpg": "48dfe61ed21d4ff9506d0da02d6a9650",
"assets/assets/resumify.png": "a09aeae10d989418a3a375f22ec06668",
"assets/assets/obstacle-avoiding-robot.png": "7f8cb088351aa1b3439c7f907313e3b9",
"assets/assets/guess-me.png": "c0507be293c9a8fcbc17b0b081ad1985",
"assets/assets/face-mask-detector.png": "7c2f45349c22581b3619ce89a444fa14",
"assets/assets/tic-tac-toe-game.png": "5082087e20f43053b67eb1e1a55d12aa",
"assets/assets/rock-paper-scissors-game.png": "fdd95cc96d561ec76043d0dd5eb20840",
"assets/assets/cli-tic-tac-toe-game.png": "bcde755255de1866f2f2dce167fab012",
"assets/assets/cli-todo-app.png": "cd43ffd452107acddfdbf8cf1ffdd0af",
"assets/assets/alive.svg": "e65666e15a3473c5486504048136927e",
"assets/assets/profile-picture.jpg": "c2af7af245120dcf98fc79326f1c55c0",
"assets/assets/projects.json": "2808c0ca95c4bb8adb6240cb70af4d2c",
"assets/assets/2048-game.png": "bc18f70cbd50bd62487f23b9279a5b25",
"assets/assets/open-todo.png": "b76497c81fb950fb6d4945641b6526e6",
"assets/assets/flames-game.png": "2fdd78337c66e4f03257e99c91569e8f",
"assets/assets/greeter.png": "c5c8018956f38775faffb12d6fe5ab8a",
"assets/fonts/MaterialIcons-Regular.otf": "a47604fd8a1b36ea988326ac97985a52",
"assets/NOTICES": "dca48ca102599f5eb83e3e77be46624e",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin": "44bde70000586ad5de1fbdde26a114a6",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"favicon.png": "1371395e949e2906ed14f745ddb2fd13",
"main.dart.wasm": "240886584c8a4ee0a43aec7d7bd876b4",
"flutter_bootstrap.js": "396e1daf131f3cccc736149a418aa38c",
"version.json": "ec9b2ffba4de936bd9e28a519a236252",
"main.dart.js": "4e4500f42ded20861365c9951c0ec72e"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"main.dart.wasm",
"main.dart.mjs",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
