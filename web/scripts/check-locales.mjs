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

const hardcoded = [];
const patterns = [/\bLoading\.\.\./g, /\bSave\b/g, /\bCancel\b/g, /\bDelete\b/g, /\bCreate\b/g, /\bUpdate\b/g, /\bSearch\b/g];
for (const file of files) {
	const text = fs.readFileSync(file, "utf8")
		.replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi, "")
		.replace(/<!--([\s\S]*?)-->/g, "")
		.replace(/\/\*([\s\S]*?)\*\//g, "")
		.replace(/^\s*\/\/.*$/gm, "")
		.replace(/console\.(?:log|warn|error)\([^;]*\);?/g, "");
	for (const pattern of patterns) {
		if (pattern.test(text) && !file.includes(`${path.sep}locales${path.sep}`)) {
			hardcoded.push(file);
			break;
		}
	}
}

console.log(JSON.stringify({ missing, extra, hardcoded }, null, 2));
if (missing.length || extra.length) process.exitCode = 1;
