#!/usr/bin/env node
/**
 * Render assets/wtls-demo.svg → assets/wtls-demo.gif via headless Chrome + ffmpeg.
 *
 * Prerequisites:
 *   - Google Chrome
 *   - ffmpeg
 *   - puppeteer-core (e.g. `npm i puppeteer-core` in /tmp or locally)
 *
 *   CHROME_PATH=... PUPPETEER_MODULE=/path/to/puppeteer-core node assets/export-gif.mjs
 */
import { spawn } from "node:child_process";
import { readFile, mkdir, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const svgPath = join(__dirname, "wtls-demo.svg");
const outGif = join(__dirname, "wtls-demo.gif");
const chrome =
  process.env.CHROME_PATH ||
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";

const moduleRoot = process.env.PUPPETEER_MODULE || "/tmp/node_modules/puppeteer-core";
const puppeteer = (
  await import(pathToFileURL(join(moduleRoot, "lib/esm/puppeteer/puppeteer-core.js")).href)
).default;

const DURATION_MS = 16000;
const FPS = 10;
const FRAME_COUNT = Math.round((DURATION_MS / 1000) * FPS);
const WIDTH = 780;
const HEIGHT = 440;

const svg = await readFile(svgPath, "utf8");
const frameDir = join(tmpdir(), `wtls-demo-frames-${process.pid}`);
await rm(frameDir, { recursive: true, force: true });
await mkdir(frameDir, { recursive: true });

const browser = await puppeteer.launch({
  executablePath: chrome,
  headless: true,
  args: [
    "--no-sandbox",
    "--disable-dev-shm-usage",
    `--window-size=${WIDTH},${HEIGHT}`,
    "--hide-scrollbars",
  ],
});

try {
  const page = await browser.newPage();
  await page.setViewport({ width: WIDTH, height: HEIGHT, deviceScaleFactor: 1 });
  await page.setContent(
    `<!doctype html>
<html>
<head>
<meta charset="utf-8" />
<style>
  html, body { margin: 0; width: ${WIDTH}px; height: ${HEIGHT}px; background: #05070a; overflow: hidden; }
  svg { display: block; }
</style>
</head>
<body>${svg}</body>
</html>`,
    { waitUntil: "load" },
  );
  await new Promise((r) => setTimeout(r, 250));
  console.log(`Capturing ${FRAME_COUNT} frames at ${FPS} fps...`);

  const start = Date.now();
  for (let i = 0; i < FRAME_COUNT; i++) {
    const target = start + (i * 1000) / FPS;
    const wait = target - Date.now();
    if (wait > 0) await new Promise((r) => setTimeout(r, wait));
    await page.screenshot({
      path: join(frameDir, `frame-${String(i).padStart(4, "0")}.png`),
    });
    if (i % 20 === 0) console.log(`  frame ${i}/${FRAME_COUNT}`);
  }
} finally {
  await browser.close();
}

console.log("Encoding GIF...");
await new Promise((resolve, reject) => {
  const ff = spawn(
    "ffmpeg",
    [
      "-y",
      "-framerate",
      String(FPS),
      "-i",
      join(frameDir, "frame-%04d.png"),
      "-vf",
      "fps=10,scale=780:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=160:stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3",
      outGif,
    ],
    { stdio: "inherit" },
  );
  ff.on("exit", (code) => (code === 0 ? resolve() : reject(new Error(`ffmpeg exited ${code}`))));
});

await rm(frameDir, { recursive: true, force: true });
console.log(`Wrote ${outGif}`);
