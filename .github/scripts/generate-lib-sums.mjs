#!/usr/bin/env node

const REPO = "pola-rs/r-polars";
const BASE_URL = `https://github.com/${REPO}/releases/download`;
const TAG_PREFIX = "lib-v";

async function getLatestLibRelease() {
  const response = await fetch(`https://api.github.com/repos/${REPO}/releases`);
  const releases = await response.json();

  const libReleases = releases.filter((r) => r.tag_name.startsWith(TAG_PREFIX));

  if (libReleases.length === 0) {
    throw new Error("No lib-v releases found");
  }

  return libReleases[0].tag_name;
}

async function generateLibSumsTsv(tag) {
  const url = `${BASE_URL}/${tag}/sha256sums.txt`;
  console.log(`Downloading ${url}`);

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(
      `Failed to download: ${response.status} ${response.statusText}`
    );
  }

  const text = await response.text();

  const lines = text
    .trim()
    .split("\n")
    .map((line) => {
      const [hash, filename] = line.trim().split(/\s+/);
      return `${BASE_URL}/${tag}/${filename}\t${hash}`;
    })
    .sort();

  return "url\tsha256sum\n" + lines.join("\n") + "\n";
}

async function main() {
  try {
    const latestTag = await getLatestLibRelease();
    const version = latestTag.replace(TAG_PREFIX, "");

    console.log(`Latest lib version: ${version}`);

    const tsvContent = await generateLibSumsTsv(latestTag);

    const fs = await import("node:fs/promises");
    await fs.writeFile("tools/lib-sums.tsv", tsvContent, "utf-8");

    console.log("✓ Generated tools/lib-sums.tsv");
  } catch (error) {
    console.error("Error:", error.message);
    process.exit(1);
  }
}

main();
