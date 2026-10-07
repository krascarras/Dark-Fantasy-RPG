import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";

const root = process.cwd();
const indexPath = path.join(root, "index.html");

function fail(message) {
  console.error(`FAIL: ${message}`);
  process.exit(1);
}

if (!fs.existsSync(indexPath)) fail("index.html is missing.");

const html = fs.readFileSync(indexPath, "utf8");

const required = [
  "DFR_NATIVE_LANGUAGE_VERSION='0.5.0-relationship-continuity'",
  "function dfrNativeGenerate",
  "function callStoryAI",
  "function dfrConversationState",
  "function dfrRememberConversation",
  "function dfrRelevantContinuity",
  "function dfrRecordFact",
  "dfrNativeHistory",
  "*",
];

for (const marker of required) {
  if (!html.includes(marker)) fail(`required Native marker missing: ${marker}`);
}

const forbidden = [
  "litertlm",
  "gemma-4",
  "AndroidLocalAI",
  "LiteRT",
];

for (const marker of forbidden) {
  if (html.toLowerCase().includes(marker.toLowerCase())) {
    fail(`legacy external AI dependency marker found: ${marker}`);
  }
}

if (!html.includes("nativeEngine!==false")) {
  fail("Native engine is not the primary call path.");
}

if (!html.includes("dfrNativeGenerate(action)")) {
  fail("callStoryAI does not route to DFR Native.");
}

if (!/\*[^*\n]{1,200}\*/.test(html)) {
  fail("no asterisk-delimited action text was found.");
}

const scripts = [...html.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi)];
if (scripts.length === 0) fail("no JavaScript block found in index.html.");

const combined = scripts.map(m => m[1]).join("\n;\n");
const tempFile = path.join(os.tmpdir(), `dfr-native-${process.pid}.mjs`);
fs.writeFileSync(tempFile, combined, "utf8");

const syntax = spawnSync(process.execPath, ["--check", tempFile], {
  encoding: "utf8"
});

try {
  if (syntax.status !== 0) {
    console.error(syntax.stdout);
    console.error(syntax.stderr);
    fail("inline JavaScript syntax check failed.");
  }
} finally {
  try { fs.unlinkSync(tempFile); } catch {}
}

console.log("PASS: DFR Native single-file source checks");
console.log("PASS: Native engine markers present");
console.log("PASS: legacy external AI markers absent");
console.log("PASS: Native is the primary narrative path");
console.log("PASS: asterisk action formatting detected");
console.log("PASS: inline JavaScript syntax valid");
