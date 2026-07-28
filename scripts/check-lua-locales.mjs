import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";

const root = resolve(import.meta.dirname, "..");

function localeKeys(source) {
  const keys = new Set();
  const localeStart = source.search(/MDTLocales\[['"][^'"]+['"]\]\s*=\s*\{/);
  if (localeStart === -1) throw new Error("Locale table not found");
  source = source.slice(localeStart);
  const tokens = [];
  for (let index = 0; index < source.length;) {
    const rest = source.slice(index);
    const whitespace = rest.match(/^\s+/);
    const comment = rest.match(/^--[^\n]*/);
    const quoted = rest.match(/^(['"])(?:\\.|\1\1|(?!\1)[\s\S])*?\1/);
    const identifier = rest.match(/^[a-zA-Z_][\w]*/);
    if (whitespace || comment || quoted || identifier) {
      const match = whitespace ?? comment ?? quoted ?? identifier;
      if (identifier) tokens.push(identifier[0]);
      else if (quoted) tokens.push("STRING");
      index += match[0].length;
    } else {
      tokens.push(source[index]);
      index += 1;
    }
  }
  let cursor = tokens.indexOf("{");
  const parseTable = (prefix) => {
    cursor += 1;
    while (cursor < tokens.length && tokens[cursor] !== "}") {
      if (/^[a-zA-Z_]/.test(tokens[cursor] ?? "") && tokens[cursor + 1] === "=") {
        const key = tokens[cursor];
        cursor += 2;
        if (tokens[cursor] === "{") parseTable([...prefix, key]);
        else {
          keys.add([...prefix, key].join("."));
          while (cursor < tokens.length && tokens[cursor] !== "," && tokens[cursor] !== "}") cursor += 1;
        }
      } else cursor += 1;
      if (tokens[cursor] === ",") cursor += 1;
    }
    cursor += 1;
  };
  parseTable([]);
  return keys;
}

const en = localeKeys(await readFile(resolve(root, "locales/en-US.lua"), "utf8"));
const pt = localeKeys(await readFile(resolve(root, "locales/pt-BR.lua"), "utf8"));
const files = execFileSync("git", ["-C", root, "ls-files", "*.lua"], { encoding: "utf8" })
  .trim().split(/\r?\n/).filter((file) => !file.startsWith("locales/") && !file.startsWith("shared/"));
const refs = new Set();
const hardcoded = [];
const visibleLiteralPatterns = [
  ["notification", /\bps\.notify\s*\(\s*['"]/],
  ["input dialog title", /\blib\.inputDialog\s*\(\s*['"]/],
  ["help notification", /\b(?:ShowCameraHelpNotification|ShowHelpNotification)\s*\(\s*['"]/],
  ["visible field", /\b(?:title|description|help)\s*=\s*['"][A-Za-z]/],
  ["visible placeholder", /\bplaceholder\s*=\s*['"][A-Za-z][^'"\r\n]*\s[^'"\r\n]*['"]/],
];
const forbiddenVisiblePhrases = /\b(?:Unknown Officer|Unknown Vehicle|Unknown Weapon|Unknown Owner|Active Warrant|Evidence Follow-up|Case created from evidence link|Draft Report|Report (?:updated|created|deleted) successfully|Content saved successfully|Vehicle Impound Unit|San Andreas Judicial System|Internal Affairs)\b/;
for (const file of files) {
  const source = await readFile(resolve(root, file), "utf8");
  for (const match of source.matchAll(/\bL\(\s*['\"]([^'\"]+)['\"]/g)) refs.add(match[1]);
  for (const [index, line] of source.split(/\r?\n/).entries()) {
    if (line.trimStart().startsWith("--")) continue;
    for (const [kind, pattern] of visibleLiteralPatterns) {
      if (kind === "visible placeholder" && line.includes("vector4(")) continue;
      if (pattern.test(line)) hardcoded.push(`${file}:${index + 1} (${kind})`);
    }
    if (forbiddenVisiblePhrases.test(line)) hardcoded.push(`${file}:${index + 1} (known visible phrase)`);
  }
}

const missingEn = [...refs].filter((key) => !en.has(key));
const missingPt = [...refs].filter((key) => !pt.has(key));
const onlyEn = [...en].filter((key) => !pt.has(key));
const onlyPt = [...pt].filter((key) => !en.has(key));
if (missingEn.length || missingPt.length || onlyEn.length || onlyPt.length || hardcoded.length) {
  for (const [label, values] of [["missing en-US", missingEn], ["missing pt-BR", missingPt], ["only en-US", onlyEn], ["only pt-BR", onlyPt]]) {
    if (values.length) console.error(`${label}: ${values.join(", ")}`);
  }
  if (hardcoded.length) console.error(`hardcoded Lua UI text: ${hardcoded.join(", ")}`);
  process.exit(1);
}
console.log(`Lua locales OK: ${refs.size} references, ${en.size} keys per locale`);
