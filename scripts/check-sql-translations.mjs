import { execFileSync } from "node:child_process";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const targets = ["qbx.sql", "qbcore.sql"];
const visibleColumns = { mdt_penal_codes:[1,6], mdt_cameras:[1], mdt_tags:[0], mdt_report_templates:[0,2], mdt_awards:[0,1,3], mdt_custom_licenses:[0,1], mdt_fto_phases:[2,3], mdt_fto_competencies:[2,3], mdt_sop_settings:[1,2], mdt_sop_categories:[2], mdt_sop_sections:[1,2] };
const reportTypeRepairs = new Map([
  ["Relatório de incidente", "Incident Report"],
  ["Relatório de tráfego", "Traffic Report"],
  ["Relatório de Investigação", "Investigation Report"],
  ["Relatório de prisão", "Arrest Report"],
  ["Relatório de evidências", "Evidence Report"],
]);
const internalReportTypes = [...reportTypeRepairs.values()];

function values(sql) {
  const result = [];
  const pattern = /INSERT(?:\s+IGNORE)?\s+INTO\s+`?([a-z0-9_]+)`?(?:\s*\([^;]*?\))?\s+VALUES\s*/gi;
  let match;
  while ((match = pattern.exec(sql))) {
    const columns = visibleColumns[match[1]];
    if (!columns) continue;
    let cursor = match.index + match[0].length, depth = 0, field = 0, start = -1, quoted = false;
    for (; cursor < sql.length; cursor += 1) {
      const char = sql[cursor];
      if (quoted) {
        if (char === "'" && sql[cursor + 1] === "'") cursor += 1;
        else if (char === "'") { if (columns.includes(field)) result.push(sql.slice(start, cursor).replaceAll("''", "'")); quoted = false; }
      } else if (char === "'") { quoted = true; start = cursor + 1; }
      else if (char === "(") { depth += 1; if (depth === 1) field = 0; }
      else if (char === ")") depth -= 1;
      else if (char === "," && depth === 1) field += 1;
      else if (char === ";" && depth === 0) { pattern.lastIndex = cursor + 1; break; }
    }
  }
  return result;
}

const tokens = (text, pattern) => (text.match(pattern) ?? []).sort().join("\u0000");
for (const target of targets) {
  const translatedSql = await readFile(resolve(root, "sql", target), "utf8");
  const original = values(execFileSync("git", ["-C", root, "show", `HEAD:sql/${target}`], { encoding:"utf8", maxBuffer:5*1024*1024 }).replaceAll("\\'", "''"));
  const translated = values(translatedSql);
  if (original.length !== translated.length) throw new Error(`${target}: seed value count changed`);
  for (let index = 0; index < original.length; index += 1) {
    if (tokens(original[index], /\[[^\]]+\]/g) !== tokens(translated[index], /\[[^\]]+\]/g)) throw new Error(`${target}: placeholder mismatch at value ${index + 1}`);
    if (tokens(original[index], /<\/?[a-z][^>]*>/gi) !== tokens(translated[index], /<\/?[a-z][^>]*>/gi)) {
      console.error("Original tags:", original[index].match(/<\/?[a-z][^>]*>/gi));
      console.error("Translated tags:", translated[index].match(/<\/?[a-z][^>]*>/gi));
      console.error("Original value:", original[index]);
      console.error("Translated value:", translated[index]);
      throw new Error(`${target}: HTML tag mismatch at value ${index + 1}`);
    }
  }
  const templateBlock = translatedSql.match(/INSERT IGNORE INTO `mdt_report_templates`[^;]+;/s)?.[0] ?? "";
  const templateTypes = [...templateBlock.matchAll(/^\('(?:[^']|'')*',\s*'([^']+)',/gm)].map((match) => match[1]);
  if (templateTypes.join("|") !== internalReportTypes.join("|")) {
    throw new Error(`${target}: report template type identifiers changed: ${templateTypes.join(", ")}`);
  }
  if (!translatedSql.includes("('SWAT', 'officer'") || translatedSql.includes("('GOLPE', 'officer'")) {
    throw new Error(`${target}: SWAT acronym was translated`);
  }
	for (const [jobType, reportTypes] of Object.entries({
		ems: ["Medical Report", "Trauma Report", "Overdose Report", "Psychiatric Report", "Mass Casualty Report"],
		doj: ["Court Filing", "Legal Brief", "Judicial Order", "Plea Agreement", "Sentencing Report"],
	})) {
		for (const reportType of reportTypes) {
			if (!translatedSql.includes(`'${reportType}'`) || !translatedSql.includes(`\`job_type\` = '${jobType}' AND \`type\` = '${reportType}'`)) {
				throw new Error(`${target}: missing isolated ${jobType.toUpperCase()} template for ${reportType}`);
			}
		}
	}
  console.log(`${target}: ${translated.length} visible values, placeholders and HTML preserved`);
}

const migration = await readFile(resolve(root, "sql/migrate_pt-BR.sql"), "utf8");
if (!migration.startsWith("-- ps-mdt pt-BR") || !migration.includes("START TRANSACTION;") || !migration.trimEnd().endsWith("COMMIT;")) throw new Error("Invalid pt-BR migration wrapper");
if (migration.includes("\\'")) throw new Error("Migration contains non-portable backslash apostrophe escapes");
for (const [translated, internal] of reportTypeRepairs) {
  const repair = `SET \`type\` = '${internal}' WHERE \`type\` = '${translated}'`;
  if (!migration.includes(repair)) throw new Error(`Migration is missing report type repair: ${internal}`);
}
console.log(`${(migration.match(/^UPDATE /gm) ?? []).length} guarded migration updates`);
