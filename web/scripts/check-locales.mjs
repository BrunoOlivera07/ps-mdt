import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";

const root = process.cwd();
function loadLocale(file, exportName) {
	const raw = fs.readFileSync(path.join(root, "src", "locales", file), "utf8");
	const match = raw.match(new RegExp(`export const ${exportName}(?:\\s*:[^=]+)?\\s*=\\s*(\\{[\\s\\S]*\\});`));
	if (!match) throw new Error(`Unable to parse ${file}`);
	return vm.runInNewContext(`(${match[1]})`);
}

const en = loadLocale("en-US.ts", "enUS");
const pt = loadLocale("pt-BR.ts", "ptBR");

function flatten(obj, prefix = "", out = []) {
	for (const [key, value] of Object.entries(obj || {})) {
		const full = prefix ? `${prefix}.${key}` : key;
		if (value && typeof value === "object" && !Array.isArray(value)) flatten(value, full, out);
		else out.push(full);
	}
	return out;
}

const enKeys = new Set(flatten(en));
const ptKeys = new Set(flatten(pt));
const missing = [...enKeys].filter((k) => !ptKeys.has(k));
const extra = [...ptKeys].filter((k) => !enKeys.has(k));

function flattenValues(obj, prefix = "", out = new Map()) {
	for (const [key, value] of Object.entries(obj || {})) {
		const full = prefix ? `${prefix}.${key}` : key;
		if (value && typeof value === "object" && !Array.isArray(value)) flattenValues(value, full, out);
		else out.set(full, value);
	}
	return out;
}

function placeholders(value) {
	return [...String(value ?? "").matchAll(/\{([\w_]+)\}/g)].map((match) => match[1]).sort();
}

const enValues = flattenValues(en);
const ptValues = flattenValues(pt);
const placeholderMismatches = [...enKeys].filter((key) =>
	ptKeys.has(key) && placeholders(enValues.get(key)).join("|") !== placeholders(ptValues.get(key)).join("|"),
);

const srcDir = path.join(root, "src");
const files = [];
function walk(dir) {
	for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
		const full = path.join(dir, entry.name);
		if (entry.isDirectory()) walk(full);
		else if (/\.(svelte|ts|js|mjs)$/.test(entry.name)) files.push(full);
	}
}
walk(srcDir);

const referencedKeys = new Set();
const quotedTranslationCall = /\b(?:t|tf)\(\s*(["'])([^"']+)\1/g;
const staticTemplateTranslationCall = /\b(?:t|tf)\(\s*`([^`${}]+)`/g;
for (const file of files) {
	const text = fs.readFileSync(file, "utf8");
	for (const match of text.matchAll(quotedTranslationCall)) referencedKeys.add(match[2]);
	for (const match of text.matchAll(staticTemplateTranslationCall)) referencedKeys.add(match[1]);
}
const referencedMissing = [...referencedKeys].filter((key) => !enKeys.has(key) || !ptKeys.has(key)).sort();

const hardcoded = [];
const patterns = [
	/\bLoading\.\.\./,
	/\bSave\b/,
	/\bCancel\b/,
	/\bDelete\b/,
	/\bCreate\b/,
	/\bUpdate\b/,
	/\bSearch\b/,
	/\bIn Vehicle\b/,
	/\bOn Foot\b/,
	/\bUnassigned\b/,
	/\bSelect a code\b/,
	/\byou are not authori[sz]ed\b/i,
	/\bInvalid Date\b/,
	/\bIncident Summary\b/,
	/\bArrest Summary\b/,
	/\bEvidence Report Summary\b/,
	/\bComponent not found\b/,
	/placeholder=["']Report ID["']/,
	/placeholder=["']Case ID["']/,
	/placeholder=["']e\.g\. AB-123456["']/,
	/>\s*STATE\s*</,
	/\bBack to FTO List\b/,
	/\bNew Assignment\b/,
	/>\s*(?:All|Refresh)\s*</,
	/\b(?:Complete Training|Daily Observation Reports|Meets advancement criteria|Not yet recommended|Training Completed|Training Failed|DORs this phase)\b/,
	/\bCategorias do Bulletin Board\b/,
];

const targetedPatterns = [
	{ file: "src/pages/Management.svelte", pattern: /\blabel:\s*["'][A-Za-z]/ },
	{ file: "src/components/management/ManagementTracking.svelte", pattern: /\b(?:label|description):\s*["'][A-Za-z]/ },
	{ file: "src/components/management/ManagementBulletins.svelte", pattern: /\bcontent:\s*["'][A-Za-z]/ },
	{ file: "src/components/management/ManagementAwards.svelte", pattern: /\{\s*gt\.label\s*\}/ },
	{ file: "src/components/management/ManagementTemplates.svelte", pattern: />\{\s*(?:rt|template\.type)\s*\}</ },
	{ file: "src/pages/CivilianView.svelte", pattern: /\{\s*report\.type\s*\}/ },
	{ file: "src/pages/Reports.svelte", pattern: /import\s*\{\s*REPORT_TYPES\s*\}/ },
	{ file: "src/pages/Reports.svelte", pattern: /\b(?:Armed Robbery at Fleeca Bank|Arrest Report - David Chen|Warrant Execution - Marcus Johnson)\b/ },
	{ file: "src/pages/ReportEditor.svelte", pattern: /\{\s*id:\s*1,\s*name:\s*t\("management\.templates\.examples\.standardIncident"\)/ },
];
for (const file of files) {
	const text = fs.readFileSync(file, "utf8")
		.replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi, "")
		.replace(/<!--([\s\S]*?)-->/g, "")
		.replace(/\/\*([\s\S]*?)\*\//g, "")
		.replace(/^\s*\/\/.*$/gm, "")
		.replace(/console\.(?:log|warn|error)\([^;]*\);?/g, "");
	const relativeFile = path.relative(root, file).replaceAll("\\", "/");
	if (targetedPatterns.some((entry) => entry.file === relativeFile && entry.pattern.test(text))) {
		hardcoded.push(file);
		continue;
	}
	for (const pattern of patterns) {
		if (pattern.test(text) && !file.includes(`${path.sep}locales${path.sep}`)) {
			hardcoded.push(file);
			break;
		}
	}
}

console.log(JSON.stringify({ missing, extra, placeholderMismatches, referencedMissing, hardcoded }, null, 2));
if (missing.length || extra.length || placeholderMismatches.length || referencedMissing.length || hardcoded.length) process.exitCode = 1;
