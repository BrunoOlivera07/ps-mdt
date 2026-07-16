import { enUS } from "./en-US";
import { ptBR } from "./pt-BR";

export const locales = {
	"en-US": enUS,
	"pt-BR": ptBR,
} as const;

export type LocaleCode = keyof typeof locales;
export type LocalePath = string;

export function getLocaleDefault(): LocaleCode {
	return "pt-BR";
}
