import { writable } from "svelte/store";
import { locales, type LocaleCode } from "../locales";

type Params = Record<string, string | number | boolean | null | undefined>;

export const locale = writable<LocaleCode>("pt-BR");
let currentLocale: LocaleCode = "pt-BR";

function getPath(obj: unknown, path: string): unknown {
	return path.split(".").reduce((acc: any, key) => (acc && typeof acc === "object" ? acc[key] : undefined), obj);
}

function format(template: string, params?: Params): string {
	if (!params) return template;
	return template.replace(/\{(\w+)\}/g, (_, key) => {
		const value = params[key];
		return value === null || value === undefined ? "" : String(value);
	});
}

export function setLocale(nextLocale: string): void {
	currentLocale = (nextLocale in locales ? nextLocale : "pt-BR") as LocaleCode;
	locale.set(currentLocale);
}

export function getLocale(): LocaleCode {
	return currentLocale;
}

export function t(path: string, params?: Params): string {
	const active = locales[currentLocale] ?? locales["pt-BR"];
	const fallback = locales["en-US"];
	const value = getPath(active, path) ?? getPath(fallback, path);
	if (typeof value === "string") return format(value, params);
	if (import.meta.env.DEV) console.warn(`[i18n] Missing key: ${path}`);
	return format(path, params);
}

export function tf(path: string, fallbackValue: string, params?: Params): string {
	const active = locales[currentLocale] ?? locales["pt-BR"];
	const fallback = locales["en-US"];
	const value = getPath(active, path) ?? getPath(fallback, path);
	return format(typeof value === "string" ? value : fallbackValue, params);
}
