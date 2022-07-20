#!/bin/env node
// noinspection NpmUsedModulesInstalled

console.log("make sure live-server and chokidar are installed or this will not work");

import liveServer from "live-server"
import {watch} from "chokidar"
import { dirname } from "node:path"
import { fileURLToPath } from "node:url"
import { execSync } from "node:child_process"

const workspace = dirname(dirname(fileURLToPath(import.meta.url)))

// Start live server which will reload the browser when dist files change
liveServer.start({
  root: `${workspace}/dist`, // Set root directory that's being served. Defaults to cwd.
  file: "404.html", // When set, serve this file (server root relative) for every 404 (useful for single-page applications)
  logLevel: 1, // 0 = errors only, 1 = some, 2 = lots
})
console.log("started live server")

// re-run lua build script when site files change
watch(`${workspace}/site`, {
  ignored: /(^|[\/\\])\../, // ignore dotfiles
  persistent: true
}).on("all", (event, path) => {
  console.log("rebuild because", event, "at", path)
  // We want synchronous so we don't batch changes, and because building is so fast it doesn't matter
  try {
    execSync(`cd ${workspace}/build; luajit build.lua`)
  } catch (err) {
    console.error("rebuild failed")
  }
})
console.log("started rebuild on change")
