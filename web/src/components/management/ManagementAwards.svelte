<script lang="ts">
	import { onMount } from "svelte";
	import { fetchNui } from "../../utils/fetchNui";
	import { isEnvBrowser } from "../../utils/misc";
	import { NUI_EVENTS } from "../../constants/nuiEvents";
	import { t } from "../../lib/i18n";

	interface AwardConfig {
		id: number;
		name: string;
		description: string;
		icon: string;
		category: string;
		goalType: string;
		goalAmount: number;
	}

	const GOAL_TYPES = [
		{ value: "reports", label: () => t("management.awards.goalTypes.reports") },
		{ value: "arrests", label: () => t("management.awards.goalTypes.arrests") },
		{ value: "cases", label: () => t("management.awards.goalTypes.cases") },
		{ value: "evidence", label: () => t("management.awards.goalTypes.evidence") },
		{ value: "bolos", label: () => t("management.awards.goalTypes.bolos") },
		{ value: "warrants", label: () => t("management.awards.goalTypes.warrants") },
		{ value: "totalFined", label: () => t("management.awards.goalTypes.totalFined") },
		{ value: "totalMonths", label: () => t("management.awards.goalTypes.totalMonths") },
		{ value: "citations", label: () => t("management.awards.goalTypes.citations") },
	];

	const ICONS = [
		"description", "local_police", "folder", "inventory_2",
		"notification_important", "gavel", "payments", "schedule",
		"receipt_long", "military_tech", "shield", "star",
		"workspace_premium", "verified", "emoji_events",
	];

	let awards: AwardConfig[] = $state([]);
	let isLoading = $state(false);
	let isSubmitting = $state(false);
	let statusMessage: { text: string; type: "success" | "error" } | null = $state(null);
	let editingId: number | null = $state(null);

	let formName = $state("");
	let formDesc = $state("");
	let formIcon = $state("description");
	let formCategory = $state("");
	let formGoalType = $state("reports");
	let formGoalAmount = $state(1);

	function showStatus(text: string, type: "success" | "error" = "success") {
		statusMessage = { text, type };
		setTimeout(() => { statusMessage = null; }, 3000);
	}

	function resetForm() {
		formName = "";
		formDesc = "";
		formIcon = "description";
		formCategory = "";
		formGoalType = "reports";
		formGoalAmount = 1;
		editingId = null;
	}

	function startEdit(award: AwardConfig) {
		editingId = award.id;
		formName = award.name;
		formDesc = award.description;
		formIcon = award.icon;
		formCategory = award.category;
		formGoalType = award.goalType;
		formGoalAmount = award.goalAmount;
	}

	async function handleSave() {
		const name = formName.trim();
		const desc = formDesc.trim();
		const category = formCategory.trim();
		if (!name || !desc || !category || formGoalAmount < 1) {
			showStatus(t("management.awards.fillAllFields"), "error");
			return;
		}

		const payload = {
			id: editingId,
			name, description: desc, icon: formIcon,
			category, goalType: formGoalType, goalAmount: formGoalAmount,
		};

		if (isEnvBrowser()) {
			if (editingId) {
				awards = awards.map(a => a.id === editingId ? { ...a, ...payload } as AwardConfig : a);
			} else {
				awards = [...awards, { ...payload, id: Date.now() } as AwardConfig];
			}
			resetForm();
			return;
		}

		try {
			isSubmitting = true;
			const result = await fetchNui<{ success: boolean; message?: string }>(
				NUI_EVENTS.AWARDS.SAVE_AWARD, payload, { success: false }
			);
			if (result?.success) {
				showStatus(editingId ? t("management.awards.updated") : t("management.awards.created"));
				resetForm();
				await loadAwards();
			} else {
				showStatus(result?.message || t("management.awards.failedSave"), "error");
			}
		} catch {
			showStatus(t("management.awards.failedSave"), "error");
		} finally {
			isSubmitting = false;
		}
	}

	async function handleDelete(award: AwardConfig) {
		if (isEnvBrowser()) {
			awards = awards.filter(a => a.id !== award.id);
			if (editingId === award.id) resetForm();
			return;
		}

		try {
			const result = await fetchNui<{ success: boolean }>(
				NUI_EVENTS.AWARDS.DELETE_AWARD, { id: award.id }, { success: false }
			);
			if (result?.success) {
				showStatus(t("management.awards.deleted"));
				if (editingId === award.id) resetForm();
				await loadAwards();
			} else {
				showStatus(t("management.awards.failedDelete"), "error");
			}
		} catch {
			showStatus(t("management.awards.failedDelete"), "error");
		}
	}

	async function loadAwards() {
		if (isEnvBrowser()) return;
		try {
			isLoading = true;
			const response = await fetchNui<AwardConfig[]>(NUI_EVENTS.AWARDS.GET_AWARD_CONFIGS, {}, []);
			awards = Array.isArray(response) ? response : [];
		} catch {
			awards = [];
		} finally {
			isLoading = false;
		}
	}

	function getGoalTypeLabel(type: string): string {
		return GOAL_TYPES.find((item) => item.value === type)?.label() || type;
	}

	onMount(() => {
		if (isEnvBrowser()) {
			awards = [
				{ id: 1, name: t("management.awards.samples.firstReport"), description: t("management.awards.samples.firstReportDesc"), icon: "description", category: t("management.awards.goalTypes.reports"), goalType: "reports", goalAmount: 1 },
				{ id: 2, name: t("management.awards.samples.fiftyReports"), description: t("management.awards.samples.fiftyReportsDesc"), icon: "description", category: t("management.awards.goalTypes.reports"), goalType: "reports", goalAmount: 50 },
				{ id: 3, name: t("management.awards.samples.oneHundredReports"), description: t("management.awards.samples.oneHundredReportsDesc"), icon: "description", category: t("management.awards.goalTypes.reports"), goalType: "reports", goalAmount: 100 },
				{ id: 4, name: t("management.awards.samples.firstArrest"), description: t("management.awards.samples.firstArrestDesc"), icon: "local_police", category: t("management.awards.goalTypes.arrests"), goalType: "arrests", goalAmount: 1 },
				{ id: 5, name: t("management.awards.samples.fiftyArrests"), description: t("management.awards.samples.fiftyArrestsDesc"), icon: "local_police", category: t("management.awards.goalTypes.arrests"), goalType: "arrests", goalAmount: 50 },
				{ id: 6, name: t("management.awards.samples.caseWorker"), description: t("management.awards.samples.caseWorkerDesc"), icon: "folder", category: t("management.awards.goalTypes.cases"), goalType: "cases", goalAmount: 25 },
				{ id: 7, name: t("management.awards.samples.hundredK"), description: t("management.awards.samples.hundredKDesc"), icon: "payments", category: t("management.awards.goalTypes.totalFined"), goalType: "totalFined", goalAmount: 100000 },
				{ id: 8, name: t("management.awards.samples.tenWarrants"), description: t("management.awards.samples.tenWarrantsDesc"), icon: "gavel", category: t("management.awards.goalTypes.warrants"), goalType: "warrants", goalAmount: 10 },
			];
			return;
		}
		loadAwards();
	});
</script>

<div class="awards-panel">
	{#if statusMessage}
		<div class="status-toast {statusMessage.type}">{statusMessage.text}</div>
	{/if}

	<div class="form-section">
		<div class="form-row">
			<input class="form-input name-input" type="text" placeholder={t("management.awards.placeholders.name")} bind:value={formName} maxlength="50" />
			<input class="form-input" type="text" placeholder={t("management.awards.placeholders.category")} bind:value={formCategory} maxlength="25" />
			<select class="form-select" bind:value={formGoalType}>
				{#each GOAL_TYPES as gt}
					<option value={gt.value}>{gt.label}</option>
				{/each}
			</select>
			<input class="form-input goal-input" type="number" min="1" bind:value={formGoalAmount} placeholder={t("management.awards.placeholders.goal")} />
		</div>
		<div class="form-row">
			<input class="form-input desc-input" type="text" placeholder={t("management.awards.placeholders.description")} bind:value={formDesc} maxlength="100" />
			<div class="icon-picker">
				{#each ICONS as icon}
					<button
						class="icon-btn"
						class:selected={formIcon === icon}
						onclick={() => (formIcon = icon)}
						title={icon}
					>
						<span class="material-icons">{icon}</span>
					</button>
				{/each}
			</div>
			<div class="form-actions">
				{#if editingId}
					<button class="btn-save" onclick={handleSave} disabled={isSubmitting}>{t("management.awards.labels.update")}</button>
					<button class="btn-cancel" onclick={resetForm}>{t("management.awards.labels.cancel")}</button>
				{:else}
					<button class="btn-create" onclick={handleSave} disabled={!formName.trim() || !formDesc.trim() || !formCategory.trim() || isSubmitting}>
						{isSubmitting ? t("common.status.saving") : t("management.awards.labels.add")}
					</button>
				{/if}
			</div>
		</div>
	</div>

	{#if isLoading}
		<div class="empty-state">
			<div class="loading-spinner"></div>
			<p>{t("management.awards.loading")}</p>
		</div>
	{:else}
		<div class="awards-list">
			{#each awards as award (award.id)}
				<div class="award-row" class:editing={editingId === award.id}>
					<span class="material-icons row-icon">{award.icon}</span>
					<div class="row-info">
						<span class="row-name">{award.name}</span>
						<span class="row-desc">{award.description}</span>
					</div>
					<span class="row-category">{award.category}</span>
					<span class="row-goal">{getGoalTypeLabel(award.goalType)}: {award.goalAmount.toLocaleString()}</span>
					<div class="row-actions">
						<button class="action-btn edit-btn" onclick={() => startEdit(award)} title={t("common.actions.edit")}>
							<span class="material-icons">edit</span>
						</button>
						<button class="action-btn delete-btn" onclick={() => handleDelete(award)} title={t("common.actions.delete")}>
							<span class="material-icons">delete</span>
						</button>
					</div>
				</div>
			{:else}
				<div class="empty-state">{t("management.awards.empty")}</div>
			{/each}
		</div>
	{/if}
</div>

<style>
	.awards-panel {
		display: flex;
		flex-direction: column;
		height: 100%;
		overflow: hidden;
	}

	.status-toast {
		padding: 6px 12px;
		font-size: 10px;
		font-weight: 500;
		flex-shrink: 0;
		margin: 8px 16px 0;
		border-radius: 3px;
	}

	.status-toast.success {
		background: rgba(16, 185, 129, 0.08);
		color: rgba(110, 231, 183, 0.8);
		border: 1px solid rgba(16, 185, 129, 0.1);
	}

	.status-toast.error {
		background: rgba(239, 68, 68, 0.08);
		color: rgba(252, 165, 165, 0.8);
		border: 1px solid rgba(239, 68, 68, 0.1);
	}

	.form-section {
		padding: 10px 16px;
		border-bottom: 1px solid rgba(255, 255, 255, 0.06);
		flex-shrink: 0;
		display: flex;
		flex-direction: column;
		gap: 6px;
	}

	.form-row {
		display: flex;
		align-items: center;
		gap: 6px;
	}

	.form-input {
		background: rgba(255, 255, 255, 0.03);
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 3px;
		padding: 5px 8px;
		color: rgba(255, 255, 255, 0.8);
		font-size: 11px;
		min-width: 0;
	}

	.form-input:focus { outline: none; border-color: rgba(255, 255, 255, 0.12); }
	.form-input::placeholder { color: rgba(255, 255, 255, 0.2); }

	.name-input { flex: 1.5; }
	.desc-input { flex: 1; }
	.goal-input { width: 80px; }

	.form-select {
		padding: 5px 22px 5px 8px;
		font-size: 10px;
		background: rgba(255, 255, 255, 0.03);
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 3px;
		color: rgba(255, 255, 255, 0.7);
		outline: none;
	}

	.icon-picker {
		display: flex;
		gap: 2px;
		flex-shrink: 0;
		flex-wrap: nowrap;
	}

	.icon-btn {
		width: 22px;
		height: 22px;
		display: flex;
		align-items: center;
		justify-content: center;
		border: 1px solid transparent;
		border-radius: 3px;
		background: transparent;
		cursor: pointer;
		padding: 0;
		color: rgba(255, 255, 255, 0.2);
		transition: all 0.1s;
	}

	.icon-btn:hover { color: rgba(255, 255, 255, 0.5); background: rgba(255, 255, 255, 0.03); }

	.icon-btn.selected {
		border-color: rgba(255, 255, 255, 0.15);
		color: rgba(255, 255, 255, 0.7);
		background: rgba(255, 255, 255, 0.05);
	}

	.icon-btn .material-icons { font-size: 13px; }

	.form-actions {
		display: flex;
		gap: 4px;
		flex-shrink: 0;
		margin-left: auto;
	}

	.btn-create, .btn-save {
		background: rgba(var(--accent-rgb), 0.06);
		border: 1px solid rgba(var(--accent-rgb), 0.1);
		border-radius: 3px;
		padding: 5px 16px;
		color: rgba(var(--accent-text-rgb), 0.7);
		font-size: 10px;
		font-weight: 600;
		cursor: pointer;
		white-space: nowrap;
	}

	.btn-create:hover:not(:disabled), .btn-save:hover:not(:disabled) {
		background: rgba(var(--accent-rgb), 0.12);
		color: rgba(var(--accent-text-rgb), 0.9);
	}

	.btn-create:disabled, .btn-save:disabled { opacity: 0.3; cursor: not-allowed; }

	.btn-cancel {
		background: transparent;
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 3px;
		padding: 5px 8px;
		color: rgba(255, 255, 255, 0.4);
		font-size: 10px;
		font-weight: 500;
		cursor: pointer;
	}

	.btn-cancel:hover { background: rgba(255, 255, 255, 0.04); color: rgba(255, 255, 255, 0.6); }

	.awards-list {
		flex: 1;
		min-height: 0;
		overflow-y: auto;
	}

	.awards-list::-webkit-scrollbar { width: 4px; }
	.awards-list::-webkit-scrollbar-track { background: transparent; }
	.awards-list::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.06); border-radius: 2px; }

	.award-row {
		display: flex;
		align-items: center;
		gap: 10px;
		padding: 7px 16px;
		border-bottom: 1px solid rgba(255, 255, 255, 0.03);
		transition: background 0.1s;
	}

	.award-row:hover { background: rgba(255, 255, 255, 0.02); }
	.award-row.editing { background: rgba(var(--accent-rgb), 0.03); }

	.row-icon {
		font-size: 16px;
		color: rgba(255, 255, 255, 0.25);
		flex-shrink: 0;
	}

	.row-info {
		flex: 1;
		min-width: 0;
		display: flex;
		flex-direction: column;
		gap: 1px;
	}

	.row-name {
		font-size: 11px;
		font-weight: 600;
		color: rgba(255, 255, 255, 0.75);
	}

	.row-desc {
		font-size: 10px;
		color: rgba(255, 255, 255, 0.25);
	}

	.row-category {
		font-size: 9px;
		font-weight: 600;
		color: rgba(255, 255, 255, 0.2);
		text-transform: uppercase;
		letter-spacing: 0.3px;
		padding: 2px 6px;
		background: rgba(255, 255, 255, 0.03);
		border-radius: 3px;
		flex-shrink: 0;
	}

	.row-goal {
		font-size: 10px;
		color: rgba(255, 255, 255, 0.25);
		flex-shrink: 0;
		white-space: nowrap;
	}

	.row-actions {
		display: flex;
		gap: 2px;
		opacity: 0;
		transition: opacity 0.1s;
		flex-shrink: 0;
	}

	.award-row:hover .row-actions { opacity: 1; }

	.action-btn {
		background: none;
		border: none;
		color: rgba(255, 255, 255, 0.35);
		cursor: pointer;
		padding: 3px;
		border-radius: 3px;
		display: flex;
		align-items: center;
		transition: all 0.1s;
	}

	.action-btn .material-icons { font-size: 13px; }

	.action-btn.edit-btn:hover { color: rgba(var(--accent-text-rgb), 0.7); background: rgba(var(--accent-rgb), 0.08); }
	.action-btn.delete-btn:hover { color: rgba(252, 165, 165, 0.7); background: rgba(239, 68, 68, 0.08); }

	.empty-state {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		min-height: 200px;
		color: rgba(255, 255, 255, 0.25);
		font-size: 11px;
	}

	.loading-spinner {
		width: 20px;
		height: 20px;
		border: 2px solid rgba(255, 255, 255, 0.06);
		border-left: 2px solid rgba(var(--accent-rgb), 0.4);
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
		margin-bottom: 8px;
	}

	@keyframes spin {
		0% { transform: rotate(0deg); }
		100% { transform: rotate(360deg); }
	}
</style>
