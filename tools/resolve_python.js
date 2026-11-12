#!/usr/bin/env node
/**
 * Resolve a working Python on PATH (avoid Windows Store python3 stub).
 * Mirrors scripts/resolve-python.sh for Node spawnSync callers.
 */
"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync, spawnSync } = require("child_process");

const IS_WIN =
  process.platform === "win32" ||
  process.env.OS === "Windows_NT" ||
  Boolean(process.env.MSYSTEM);

function windowsLocalAppData() {
  if (process.env.LOCALAPPDATA) return process.env.LOCALAPPDATA;
  const up = process.env.USERPROFILE || os.homedir();
  return path.join(up, "AppData", "Local");
}

function isWindowsAppsStub(bin) {
  return /WindowsApps/i.test(String(bin || ""));
}

function probe(bin) {
  if (!bin) return false;
  if (isWindowsAppsStub(bin)) return false;
  try {
    if (bin === "py") {
      execFileSync("py", ["-3", "-c", "print(1)"], { stdio: "ignore" });
      return true;
    }
    if (/[\\/]/.test(bin) && !fs.existsSync(bin)) return false;
    execFileSync(bin, ["-c", "print(1)"], { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function resolvePython() {
  if (process.env.PYTHON_BIN && probe(process.env.PYTHON_BIN)) {
    return process.env.PYTHON_BIN;
  }
  const candidates = [];
  for (const env of [process.env.PYTHON, process.env.PYTHON3]) {
    if (env) candidates.push(env);
  }
  if (IS_WIN) {
    const la = windowsLocalAppData();
    candidates.push(
      "C:\\Python314\\python.exe",
      "C:\\Python313\\python.exe",
      "C:\\Python312\\python.exe",
      path.join(la, "Programs", "Python", "Python314", "python.exe"),
      path.join(la, "Programs", "Python", "Python313", "python.exe"),
      "/c/Python314/python.exe",
      "/c/Python313/python.exe",
      "/c/Python312/python.exe",
      "py",
      "python",
      "python3"
    );
  } else {
    candidates.push("python3", "python");
  }
  for (const c of candidates) {
    if (probe(c)) return c;
  }
  return IS_WIN ? "py" : "python3";
}

/** @param {string} py from resolvePython() */
function spawnPythonArgs(py, scriptArgs) {
  if (py === "py") return { cmd: "py", args: ["-3", ...scriptArgs] };
  return { cmd: py, args: scriptArgs };
}

function runPythonScript(script, scriptArgs = [], opts = {}) {
  const py = resolvePython();
  const { cmd, args } = spawnPythonArgs(py, [script, ...scriptArgs]);
  return spawnSync(cmd, args, opts);
}

module.exports = { resolvePython, runPythonScript, spawnPythonArgs, probe, IS_WIN };
