import { readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";

const root = resolve(import.meta.dirname, "..");
const targets = ["qbx.sql", "qbcore.sql"];
const protectedTranslations = new Map([
  ["SWAT", "SWAT"],
]);
const visibleColumns = {
  mdt_penal_codes: [1, 6],
  mdt_cameras: [1],
  mdt_tags: [0],
  // Template type is an internal identifier matched by the report editor.
  mdt_report_templates: [0, 2],
  mdt_awards: [0, 1, 3],
  mdt_custom_licenses: [0, 1],
  mdt_fto_phases: [2, 3],
  mdt_fto_competencies: [2, 3],
  mdt_sop_settings: [1, 2],
  mdt_sop_categories: [2],
  mdt_sop_sections: [1, 2],
};

const cache = new Map();
const cachePath = resolve(root, "scripts", ".translate-sql-cache-v2.json");
try {
  const saved = JSON.parse(await readFile(cachePath, "utf8"));
  for (const [source, translated] of Object.entries(saved)) cache.set(source, translated);
} catch {
  // The cache is optional on the first run.
}
try {
  const previous = JSON.parse(await readFile(resolve(root, "scripts", ".translate-sql-cache.json"), "utf8"));
  for (const [source, previousTranslation] of Object.entries(previous)) {
    if (cache.has(source)) continue;
    const restoreOrdinal = (translated, pattern) => {
      const originals = source.match(pattern) ?? [];
      let index = 0;
      return translated.replace(pattern, () => originals[index++] ?? "");
    };
    const withTags = restoreOrdinal(previousTranslation, /<\/?[a-z][^>]*>/gi);
    const repaired = restoreOrdinal(withTags, /\[[^\]]+\]/g);
    cache.set(source, repaired);
  }
} catch {
  // No previous cache is available.
}

function protect(text) {
  const tokens = [];
  const value = text.replace(/<[^>]+>|\[[^\]]+\]|\{[^{}]+\}/g, (token) => {
    const index = tokens.push(token) - 1;
    return `__PSMDT${index}__`;
  });
  return { value, tokens };
}

function restore(text, tokens) {
  return tokens.reduce((result, token, index) => result.replaceAll(`__PSMDT${index}__`, token), text);
}

async function translate(text) {
  if (protectedTranslations.has(text)) {
    const translated = protectedTranslations.get(text);
    cache.set(text, translated);
    return translated;
  }
  if (!/[A-Za-z]{3}/.test(text)) {
    cache.set(text, text);
    return text;
  }
  if (cache.has(text)) return cache.get(text);
  const { value, tokens } = protect(text);
  const body = new URLSearchParams({ client: "gtx", sl: "en", tl: "pt", dt: "t", q: value });
  let lastError;
  for (let attempt = 1; attempt <= 4; attempt += 1) {
    try {
      const response = await fetch("https://translate.googleapis.com/translate_a/single", {
        method: "POST",
        headers: { "content-type": "application/x-www-form-urlencoded;charset=UTF-8" },
        body,
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      const normalized = data[0].map((part) => part[0]).join("")
        .replace(/__\s*PSMDT\s*(\d+)\s*__/g, "__PSMDT$1__");
      const translated = restore(normalized, tokens);
      cache.set(text, translated);
      return translated;
    } catch (error) {
      lastError = error;
      await new Promise((resolveWait) => setTimeout(resolveWait, attempt * 750));
    }
  }
  throw new Error(`Translation failed: ${lastError?.message ?? "unknown error"}`);
}

function findSeedStrings(sql) {
  const found = [];
  const insertPattern = /INSERT(?:\s+IGNORE)?\s+INTO\s+`?([a-z0-9_]+)`?[\s\S]*?\bVALUES\s*/gi;
  let match;
  while ((match = insertPattern.exec(sql))) {
    const table = match[1];
    const columns = visibleColumns[table];
    if (!columns) continue;
    let cursor = match.index + match[0].length;
    let depth = 0;
    let field = 0;
    let inString = false;
    let stringStart = -1;
    while (cursor < sql.length) {
      const char = sql[cursor];
      if (inString) {
        if (char === "'" && sql[cursor + 1] === "'") {
          cursor += 2;
          continue;
        }
        if (char === "'") {
          if (columns.includes(field)) {
            found.push({ start: stringStart, end: cursor, text: sql.slice(stringStart, cursor).replaceAll("''", "'") });
          }
          inString = false;
        }
      } else if (char === "'") {
        inString = true;
        stringStart = cursor + 1;
      } else if (char === "(") {
        depth += 1;
        if (depth === 1) field = 0;
      } else if (char === ")") {
        depth -= 1;
      } else if (char === "," && depth === 1) {
        field += 1;
      } else if (char === ";" && depth === 0) {
        insertPattern.lastIndex = cursor + 1;
        break;
      }
      cursor += 1;
    }
  }
  return found;
}

const sourceSql = execFileSync("git", ["-C", root, "show", `HEAD:sql/${targets[0]}`], { encoding: "utf8", maxBuffer: 5 * 1024 * 1024 }).replaceAll("\\'", "''");
if (!sourceSql.includes("'Simple Assault'")) {
  throw new Error("SQL seeds do not appear to be the original en-US defaults; refusing to translate them again.");
}
const sourceEntries = findSeedStrings(sourceSql);
const uniqueTexts = [...new Set(sourceEntries.map((entry) => entry.text))];
let completed = 0;
for (let offset = 0; offset < uniqueTexts.length; offset += 1) {
  await translate(uniqueTexts[offset]);
  await writeFile(cachePath, JSON.stringify(Object.fromEntries(cache), null, 2), "utf8");
  completed += 1;
  process.stdout.write(`\rTranslated ${completed}/${uniqueTexts.length}`);
  if (!cache.has(uniqueTexts[offset + 1])) await new Promise((resolveWait) => setTimeout(resolveWait, 300));
}
process.stdout.write("\n");

for (const target of targets) {
  const path = resolve(root, "sql", target);
  let sql = execFileSync("git", ["-C", root, "show", `HEAD:sql/${target}`], { encoding: "utf8", maxBuffer: 5 * 1024 * 1024 }).replaceAll("\\'", "''");
  const entries = findSeedStrings(sql);
  for (const entry of entries.reverse()) {
    const translated = cache.get(entry.text);
    if (!translated) throw new Error(`Missing cached translation for ${entry.text.slice(0, 80)}`);
    const escaped = translated.replaceAll("'", "''");
    sql = `${sql.slice(0, entry.start)}${escaped}${sql.slice(entry.end)}`;
  }
  await writeFile(path, sql, "utf8");
  console.log(`Updated sql/${target}: ${entries.length} visible values`);
}
