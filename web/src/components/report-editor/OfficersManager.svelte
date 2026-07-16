<script lang="ts">
	import type { Officer } from "../../interfaces/IReportEditor";
	import PersonnelSection from "./PersonnelSection.svelte";
	import PersonnelCard from "./PersonnelCard.svelte";
	import { OFFICER_TYPES } from "../../constants";
	import { t } from "../../lib/i18n";

	interface Props {
		officers: Officer[];
		onAdd: () => void;
		onRemove: (id: string) => void;
		onUpdate: (officer: Officer) => void;
		title?: string;
	}

	let { officers, onAdd, onRemove, onUpdate, title = t("reportEditor.involved.officers") }: Props = $props();

	function updateOfficer(id: string, field: string, value: any) {
		const officer = officers.find((o) => o.id === id);
		if (officer) {
			const updated = { ...officer, [field]: value };
			onUpdate(updated);
		}
	}
</script>

<PersonnelSection {title} {onAdd}>
	{#each officers as officer}
		<PersonnelCard
			id={officer.id}
			fullName={officer.fullName}
			secondaryInfo={`${t("reportEditor.badge")}: ${officer.badgeId}`}
			notes={officer.notes}
			type={officer.type}
			typeOptions={OFFICER_TYPES}
			{onRemove}
			onUpdate={updateOfficer}
		/>
	{/each}
</PersonnelSection>
