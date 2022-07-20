# Personal Site

My (Jakob Hain's) personal site. It uses a really basic template system (see [build/README.md](build/README.md)) for details.

## Building

`build.sh` builds `site` to `build`. You must have [LuaJIT](http://luajit.org/) installed.

`watch.sh` launches a file-watcher and live-server. You must have [node.js](https://nodejs.com) and [pnpm](https://www.npmjs.com/package/pnpm) installed.

## File structure

- `/build`: Contains the build scripts which turn `/site` into `/dist`
- `/site`: Contains assets
  - `/site/static`: Contains static assets
  - `/site/fragments` contains fragments which are stitched together by the build scripts and data from `root.json` and `pages.json`
  - `/site/pages` contains the almost-complete webpages
  - `/site/root.json` contains site data
  - `/site/pages.json` specifically loads the webpages and wraps them in boilerplate, and this is the entry-point for the builder
- `/dist` (excluded from Git): contains the output site.
- `build.sh` = `build/build.lua` = build script, `watch.sh` = `watch/index.mjs` = live-server and file-watcher


## Distribution

Cloning this and creating your own site is fine, just make sure to keep the MIT license somewhere.
