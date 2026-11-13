"use strict";
/** Feed copy must not be classified as a LinkedIn security checkpoint. */
const assert = require("assert");
const { classifyLinkedInSession } = require("./wait_for_cdp_login");

const feedBody = [
  "Home",
  "My Network",
  "Jobs",
  "Messaging",
  "Start a post",
  "Take on your next challenge — Solutions Architect",
].join("\n");

const feed = classifyLinkedInSession("https://www.linkedin.com/feed/", feedBody);
assert.strictEqual(feed.ok, true, JSON.stringify(feed));
assert.strictEqual(feed.onChallenge, false);
assert.strictEqual(feed.reason, "live_cdp_linkedin_ok");

const checkpoint = classifyLinkedInSession(
  "https://www.linkedin.com/checkpoint/challenge/abc",
  "Let's do a quick security check\nHome"
);
assert.strictEqual(checkpoint.ok, false);
assert.strictEqual(checkpoint.onChallenge, true);
assert.strictEqual(checkpoint.reason, "linkedin_security_challenge");

const login = classifyLinkedInSession(
  "https://www.linkedin.com/login",
  "Sign in to LinkedIn\nJoin now"
);
assert.strictEqual(login.ok, false);
assert.strictEqual(login.onChallenge, false);
assert.strictEqual(login.reason, "linkedin_login_required");

console.log("linkedin cdp login classify tests OK");
