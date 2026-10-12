#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const src = fs.readFileSync(path.join(__dirname, "daily_apply.js"), "utf8");
if (src.includes("candidate_opportunity/apply")) {
  console.error("daily_apply.js still references deprecated candidate_opportunity/apply");
  process.exit(1);
}
if (!src.includes("candidate_matching")) {
  console.error("daily_apply.js must use candidate_matching API");
  process.exit(1);
}
console.log("instahyre api_paths OK");
