import type { JobType } from "../interfaces/IUser";
import { t } from "../lib/i18n";

export interface DefaultReportTemplate {
	id: number;
	name: string;
	type: string;
	content: string;
	job_type: "leo" | "ems" | "doj";
}

const TEMPLATE_DEFINITIONS = {
	leo: [
		["Incident Report", "standardIncident"],
		["Traffic Report", "trafficStop"],
		["Investigation Report", "fullInvestigation"],
		["Arrest Report", "standardArrest"],
		["Evidence Report", "evidenceCollection"],
	],
	ems: [
		["Medical Report", "medicalAssessment"],
		["Trauma Report", "traumaResponse"],
		["Overdose Report", "overdoseResponse"],
		["Psychiatric Report", "psychiatricAssessment"],
		["Mass Casualty Report", "massCasualtyResponse"],
	],
	doj: [
		["Court Filing", "courtFiling"],
		["Legal Brief", "legalBrief"],
		["Judicial Order", "judicialOrder"],
		["Plea Agreement", "pleaAgreement"],
		["Sentencing Report", "sentencingReport"],
	],
} as const;

export function normalizeTemplateJobType(jobType: JobType): "leo" | "ems" | "doj" {
	if (jobType === "ems" || jobType === "doj") return jobType;
	return "leo";
}

export function getDefaultReportTemplates(jobType: JobType): DefaultReportTemplate[] {
	const normalized = normalizeTemplateJobType(jobType);
	return TEMPLATE_DEFINITIONS[normalized].map(([type, key], index) => ({
		id: -(index + 1),
		name: t(`management.templates.examples.${key}`),
		type,
		content: t(`management.templates.examples.${key}Content`),
		job_type: normalized,
	}));
}
