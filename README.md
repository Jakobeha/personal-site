# Personal Site

My (Jakob Hain's) personal site. It uses a really basic template system (see [build/README.md](build/README.md)) for details.

- `/build`: Contains the build scripts which turn `/site` into `/dist`
- `/site`: Contains assets
  - `/site/static`: Contains static assets
  - `/site/fragments` contains fragments which are stitched together by the build scripts and data from `root.json` and `pages.json`
- `/dist` (excluded from Git): contains the output site.

Cloning this and creating your own site is fine, just make sure to keep the MIT license somewhere.
