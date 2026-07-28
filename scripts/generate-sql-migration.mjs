import { execFileSync } from "node:child_process";
import { readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const oldSql = execFileSync("git", ["-C", root, "show", "HEAD:sql/qbx.sql"], { encoding: "utf8", maxBuffer: 5 * 1024 * 1024 }).replaceAll("\\'", "''");
const newSql = await readFile(resolve(root, "sql", "qbx.sql"), "utf8");

const tables = {
  mdt_penal_codes: { keys: [0], visible: [1, 6] },
  mdt_cameras: { keys: [0], visible: [1] },
  mdt_tags: { keys: [0, 1, 3], visible: [0] },
  mdt_report_templates: { keys: [0, 1], visible: [0, 2] },
  mdt_awards: { keys: [0], visible: [0, 1, 3] },
  mdt_custom_licenses: { keys: [0], visible: [0, 1] },
  mdt_fto_phases: { keys: [0, 1], visible: [2, 3] },
  mdt_fto_competencies: { keys: [0, 1], visible: [2, 3] },
  mdt_sop_settings: { keys: [0], visible: [1, 2] },
  mdt_sop_categories: { keys: [0, 1], visible: [2] },
  mdt_sop_sections: { keys: [0, 1], visible: [1, 2] },
};

function splitRows(values) {
  const rows = [];
  let row = [];
  let fieldStart = -1;
  let depth = 0;
  let inString = false;
  for (let i = 0; i < values.length; i += 1) {
    const char = values[i];
    if (inString) {
      if (char === "'" && values[i + 1] === "'") i += 1;
      else if (char === "'") inString = false;
      continue;
    }
    if (char === "'") inString = true;
    else if (char === "(") {
      depth += 1;
      if (depth === 1) fieldStart = i + 1;
    } else if (char === "," && depth === 1) {
      row.push(values.slice(fieldStart, i).trim());
      fieldStart = i + 1;
    } else if (char === ")") {
      if (depth === 1) {
        row.push(values.slice(fieldStart, i).trim());
        rows.push(row);
        row = [];
      }
      depth -= 1;
    } else if (char === ";" && depth === 0) break;
  }
  return rows;
}

function parse(sql) {
  const result = new Map();
  const pattern = /INSERT(?:\s+IGNORE)?\s+INTO\s+`?([a-z0-9_]+)`?\s*\(([^)]+)\)\s*VALUES\s*/gi;
  let match;
  while ((match = pattern.exec(sql))) {
    if (!tables[match[1]]) continue;
    const columns = match[2].split(",").map((column) => column.trim().replaceAll("`", ""));
    const rows = splitRows(sql.slice(match.index + match[0].length));
    const current = result.get(match[1]) ?? { columns, rows: [] };
    current.rows.push(...rows);
    result.set(match[1], current);
  }
  return result;
}

function literal(raw) {
  const value = raw.trim();
  if (/^NULL$/i.test(value)) return "NULL";
  if (value.startsWith("'") && value.endsWith("'")) return value;
  return value;
}

function predicate(column, raw) {
  return /^NULL$/i.test(raw.trim()) ? `\`${column}\` IS NULL` : `\`${column}\` = ${literal(raw)}`;
}

const oldData = parse(oldSql);
const newData = parse(newSql);
const output = [
  "-- ps-mdt pt-BR migration for existing installations",
  "-- Only untouched English defaults are updated; customized rows are preserved.",
  "START TRANSACTION;",
  "",
];
let updates = 0;

for (const [table, config] of Object.entries(tables)) {
  const oldTable = oldData.get(table);
  const newTable = newData.get(table);
  if (!oldTable || !newTable || oldTable.rows.length !== newTable.rows.length) {
    throw new Error(`Seed mismatch for ${table}`);
  }
  output.push(`-- ${table}`);
  for (let rowIndex = 0; rowIndex < oldTable.rows.length; rowIndex += 1) {
    const oldRow = oldTable.rows[rowIndex];
    const newRow = newTable.rows[rowIndex];
    const changed = config.visible.filter((index) => oldRow[index] !== newRow[index]);
    if (!changed.length) continue;
    const set = changed.map((index) => `\`${oldTable.columns[index]}\` = ${literal(newRow[index])}`).join(", ");
    const guards = [...new Set([...config.keys, ...config.visible])]
      .map((index) => predicate(oldTable.columns[index], oldRow[index])).join(" AND ");
    output.push(`UPDATE \`${table}\` SET ${set} WHERE ${guards};`);
    updates += 1;
  }
  output.push("");
}

const existingMigration = await readFile(resolve(root, "sql", "migrate_pt-BR.sql"), "utf8").catch(() => "");
const domainTemplateMigration = existingMigration.match(
  /-- Keep report templates isolated by MDT domain\.[\s\S]*?(?=-- Repair functional report type identifiers)/,
)?.[0]?.trim();
if (domainTemplateMigration) {
  output.push(domainTemplateMigration, "");
}

const reportTypeRepairs = [
  ["Relatório de incidente", "Incident Report"],
  ["Relatório de tráfego", "Traffic Report"],
  ["Relatório de Investigação", "Investigation Report"],
  ["Relatório de prisão", "Arrest Report"],
  ["Relatório de evidências", "Evidence Report"],
];
output.push("-- Repair functional report type identifiers translated by earlier pt-BR migrations");
for (const [translated, internal] of reportTypeRepairs) {
  output.push(`UPDATE \`mdt_report_templates\` SET \`type\` = '${internal}' WHERE \`type\` = '${translated}';`);
  updates += 1;
}
output.push("", "COMMIT;", "");
await writeFile(resolve(root, "sql", "migrate_pt-BR.sql"), output.join("\n"), "utf8");
console.log(`Generated sql/migrate_pt-BR.sql with ${updates} guarded updates`);
