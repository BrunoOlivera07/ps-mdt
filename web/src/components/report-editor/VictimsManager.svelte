<script lang="ts">
	import type { Victim } from "../../interfaces/IReportEditor";
	import PersonnelSection from "./PersonnelSection.svelte";
	import PersonnelCard from "./PersonnelCard.svelte";
	import { VICTIM_TYPES } from "../../constants";
	import { t } from "../../lib/i18n";

	interface Props {
		victims: Victim[];
		onAdd: () => void;
		onRemove: (id: string) => void;
		onUpdate: (victim: Victim) => void;
		title?: string;
	}

	let { victims, onAdd, onRemove, onUpdate, title = t("reportEditor.involved.victims") }: Props = $props();

	function updateVictim(id: string, field: string, value: any) {
		const victim = victims.find((v) => v.id === id);
		if (victim) {
			const updated = { ...victim, [field]: value };
			onUpdate(updated);
		}
	}
</script>

<PersonnelSection {title} {onAdd}>
	{#each victims as victim}
		<PersonnelCard
			id={victim.id}
			fullName={victim.fullName}
			secondaryInfo={`${t("reportEditor.id")}: ${victim.citizenid}`}
			type={victim.type}
			typeOptions={VICTIM_TYPES}
			notes={victim.notes}
			{onRemove}
			onUpdate={updateVictim}
		/>
	{/each}
</PersonnelSection>
