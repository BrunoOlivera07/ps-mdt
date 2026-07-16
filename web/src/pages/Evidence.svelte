<script lang="ts">
	import { onMount } from "svelte";
	import { formatDate, formatDateTime } from "../utils/datetime";
	import { createEvidenceService } from "../services/evidenceService.svelte";
	import { isEnvBrowser } from "../utils/misc";
	import type { createTabService } from "../services/tabService.svelte";
	import type { MDTTab } from "../constants";
	import Pagination from "../components/Pagination.svelte";
	import { t } from "../lib/i18n";

	let { tabService }: { tabService?: ReturnType<typeof createTabService> } = $props();

	function navigateTo(tab: MDTTab) {
		if (!tabService) return;
		tabService.setActiveTab(tab);
		const activeInstance = tabService.getActiveInstance();
		if (activeInstance) {
			tabService.setInstanceTab(activeInstance.id, tab);
		}
	}

	const evidenceService = createEvidenceService() as ReturnType<typeof createEvidenceService> & {
		getEvidenceItems: (...args: any[]) => Promise<any>;
		searchEvidenceItems: (...args: any[]) => Promise<any>;
		addEvidenceItem: (...args: any[]) => Promise<any>;
		updateEvidenceItem: (...args: any[]) => Promise<any>;
		deleteEvidenceItem: (...args: any[]) => Promise<any>;
		transferEvidenceItem: (...args: any[]) => Promise<any>;
		getEvidenceCustody: (...args: any[]) => Promise<any>;
		addEvidenceImage: (...args: any[]) => Promise<any>;
		removeEvidenceImage: (...args: any[]) => Promise<any>;
		linkEvidenceToCase: (...args: any[]) => Promise<any>;
		linkEvidenceToReport: (...args: any[]) => Promise<any>;
		createCaseFromEvidence: (...args: any[]) => Promise<any>;
		openEvidenceStash: (...args: any[]) => Promise<any>;
		logEvidenceViewed: (...args: any[]) => Promise<any>;
	};

	let searchQuery = $state("");
	let isLoading = $state(false);
	let showCreate = $state(false);
	let items = $state<any[]>([]);
	let total = $state(0);
	let page = $state(1);
	let limit = $state(20);

	let createForm = $state({
		caseId: "",
		reportId: "",
		title: "",
		type: "Physical",
		serial: "",
		description: "",
		location: "",
		stashId: "",
		stored: false,
		notes: "",
		plateNumber: "",
		quantity: "",
	});

	// Per-type field config
	const TYPE_FIELDS: Record<string, {
		serial?: boolean; serialLabel?: string; serialPlaceholder?: string;
		description?: boolean; descriptionPlaceholder?: string;
		stash?: boolean; stored?: boolean;
		plate?: boolean; quantity?: boolean;
	}> = {
		Physical:  { serial: true, description: true, descriptionPlaceholder: t("pages.evidence.placeholders.physicalDescription"), stash: true, stored: true },
		Digital:   { description: true, descriptionPlaceholder: t("pages.evidence.placeholders.digitalDescription") },
		Document:  { serial: true, serialLabel: t("pages.evidence.documentNumber"), serialPlaceholder: t("pages.evidence.placeholders.documentReference"), description: true, descriptionPlaceholder: t("pages.evidence.placeholders.documentDescription") },
		Weapon:    { serial: true, serialLabel: t("pages.evidence.serialNumber"), serialPlaceholder: t("pages.evidence.placeholders.weaponSerial"), stash: true, stored: true },
		Drug:      { description: true, descriptionPlaceholder: t("pages.evidence.placeholders.drugDescription"), quantity: true, stash: true, stored: true },
		Vehicle:   { plate: true, description: true, descriptionPlaceholder: t("pages.evidence.placeholders.vehicleDescription") },
		Other:     { serial: true, description: true, descriptionPlaceholder: t("pages.evidence.placeholders.otherDescription"), stash: true, stored: true },
	};

	let typeConfig = $derived(TYPE_FIELDS[createForm.type] || TYPE_FIELDS.Other);

	let selectedEvidenceId = $state<number | null>(null);
	let selectedEvidence = $state<any | null>(null);
	let custodyEntries = $state<any[]>([]);
	let transferCitizenId = $state("");
	let transferNotes = $state("");
	let evidenceError = $state("");
	let linkCaseId = $state("");
	let linkReportId = $state("");
	let statusMessage: { text: string; type: "success" | "error" } | null = $state(null);
	let lightboxUrl = $state<string | null>(null);
	let lightboxLabel = $state("");

	// ── Image URL modal (for create form) ──
	let createImageUrlModalOpen = $state(false);
	let createImageUrlInput = $state("");
	let createImageUrls = $state<{ url: string; label: string }[]>([]);

	// ── Image URL modal (for selected evidence sidebar) ──
	let sidebarImageUrlModalOpen = $state(false);
	let sidebarImageUrlInput = $state("");
	let sidebarImageLabelInput = $state("");
	let isSidebarUploading = $state(false);
	let uploadSuccess = $state("");

	function showStatus(text: string, type: "success" | "error" = "success") {
		statusMessage = { text, type };
		setTimeout(() => { statusMessage = null; }, 3000);
	}

	function openLightbox(url: string, label: string) {
		lightboxUrl = url;
		lightboxLabel = label;
	}

	function closeLightbox() {
		lightboxUrl = null;
		lightboxLabel = "";
	}

	async function openStash(stashId: string) {
		if (!stashId) return;
		await evidenceService.openEvidenceStash(stashId);
	}

	async function loadEvidence(pageNumber = 1) {
		isLoading = true;
		try {
			if (searchQuery.trim()) {
				const response = await evidenceService.searchEvidenceItems(
					searchQuery.trim(),
					pageNumber,
					limit,
				);
				items = response.data?.items || [];
				total = response.data?.total || 0;
			} else {
				const response = await evidenceService.getEvidenceItems(pageNumber, limit);
				items = response.data?.items || [];
				total = response.data?.total || 0;
			}
			
			page = pageNumber;
		} catch (error) {
			items = [];
			total = 0;
		} finally {
			isLoading = false;
		}
	}

	function resetCreateForm() {
		createForm = { caseId: "", reportId: "", title: "", type: "Physical", serial: "", description: "", location: "", stashId: "", stored: false, notes: "", plateNumber: "", quantity: "" };
		createImageUrls = [];
	}

	function buildNotes(): string {
		const parts: string[] = [];
		if (createForm.description.trim()) parts.push(createForm.description.trim());
		if (createForm.plateNumber.trim()) parts.push(`Plate: ${createForm.plateNumber.trim()}`);
		if (createForm.quantity.trim()) parts.push(`Qty: ${createForm.quantity.trim()}`);
		if (createForm.notes.trim()) parts.push(createForm.notes.trim());
		return parts.join(" | ");
	}

	async function handleCreateEvidence() {
		evidenceError = "";
		if (!createForm.title.trim()) {
			evidenceError = t("pages.evidence.messages.titleRequired");
			return;
		}

		if (isEnvBrowser()) {
			const newItem = {
				id: Date.now(),
				case_id: createForm.caseId ? Number(createForm.caseId) : null,
				title: createForm.title.trim(),
				type: createForm.type,
				serial: createForm.serial.trim() || `EVD-${String(items.length + 6).padStart(3, "0")}`,
				location: createForm.location.trim(),
				stash_id: createForm.stashId.trim(),
				stored: createForm.stored,
				notes: buildNotes(),
				created_at: new Date().toISOString(),
				updated_by: "You",
				images: createImageUrls.map((img, i) => ({ id: i + 1, url: img.url, label: img.label })),
			};
			items = [newItem, ...items];
			total = items.length;
			showCreate = false;
			resetCreateForm();
			showStatus(t("pages.evidence.messages.created"));
			return;
		}

		try {
			const payload = {
				caseId: createForm.caseId ? Number(createForm.caseId) : undefined,
				reportId: createForm.reportId && createForm.reportId.trim() !== "" 
					? Number(createForm.reportId) 
					: undefined,  // explizit undefined statt leerer String
				evidence: {
					title: createForm.title.trim(),
					type: createForm.type,
					serial: createForm.serial.trim() || (createForm.plateNumber.trim() ? createForm.plateNumber.trim() : ""),
					location: createForm.location.trim(),
					stashId: createForm.stashId.trim(),
					stored: createForm.stored,
					notes: buildNotes(),
				},
			};
			const stashToOpen = createForm.stashId.trim();
			const response = await evidenceService.addEvidenceItem(payload as any);

			if (response?.success) {
				const newId = response.id || response.data?.id;
				if (newId && createImageUrls.length > 0) {
					for (const img of createImageUrls) {
						await evidenceService.addEvidenceImage(newId, {
							data: img.url,
							filename: img.label || "image",
							contentType: "url",
							label: img.label,
						});
					}
				}
				showCreate = false;
				resetCreateForm();
				await loadEvidence(1);
				showStatus(t("pages.evidence.messages.created"));
				if (stashToOpen) {
					await openStash(stashToOpen);
				}
			} else {
				evidenceError = (response as any)?.error || t("pages.evidence.messages.createFailed");
			}
		} catch (err) {
			evidenceError = t("pages.evidence.messages.createError");
		}
	}

	async function selectEvidence(item: any) {
		selectedEvidenceId = item.id;
		selectedEvidence = items.find(i => i.id === item.id) || item;
		linkCaseId = item.case_id ? String(item.case_id) : "";
		linkReportId = item.report_id ? String(item.report_id) : "";
		evidenceService.logEvidenceViewed(item.id);
		custodyEntries = await evidenceService.getEvidenceCustody(item.id);
	}

	async function handleLinkEvidenceCase() {
		if (!selectedEvidenceId || !linkCaseId.trim()) {
			if (!linkCaseId.trim()) showStatus(t("pages.evidence.messages.enterCaseId"), "error");
			return;
		}
		try {
			const caseIdValue = /^\d+$/.test(linkCaseId.trim()) ? Number(linkCaseId.trim()) : linkCaseId.trim();
			const result = await evidenceService.linkEvidenceToCase(
				selectedEvidenceId,
				caseIdValue as any,
				selectedEvidence?.report_id ? Number(selectedEvidence.report_id) : undefined,
			);
			if (result?.success) {
				showStatus(t("pages.evidence.messages.linkedCase", { id: linkCaseId.trim() }));
				await loadEvidence(page);
			} else {
				showStatus((result as any)?.error || t("pages.evidence.messages.linkCaseFailed"), "error");
			}
		} catch {
			showStatus(t("pages.evidence.messages.linkCaseFailed"), "error");
		}
	}

	async function handleLinkEvidenceReport() {
		if (!selectedEvidenceId || !linkReportId.trim()) {
			if (!linkReportId.trim()) showStatus(t("pages.evidence.messages.enterReportId"), "error");
			return;
		}
		try {
			const reportIdNum = Number(linkReportId.trim());
			if (!reportIdNum) {
			showStatus(t("pages.evidence.messages.reportIdNumber"), "error");
				return;
			}
			const result = await evidenceService.linkEvidenceToReport(selectedEvidenceId, reportIdNum);
			if (result?.success) {
				showStatus(t("pages.evidence.messages.linkedReport", { id: linkReportId.trim() }));
				await loadEvidence(page);
			} else {
				showStatus((result as any)?.error || t("pages.evidence.messages.linkReportFailed"), "error");
			}
		} catch {
			showStatus(t("pages.evidence.messages.linkReportFailed"), "error");
		}
	}

	async function handleCreateCaseFromEvidence() {
		if (!selectedEvidenceId) return;
		if (isEnvBrowser()) {
			const newCaseId = Math.floor(Math.random() * 900) + 100;
			const idx = items.findIndex((i) => i.id === selectedEvidenceId);
			if (idx !== -1) {
				items[idx] = { ...items[idx], case_id: newCaseId };
				items = [...items];
				selectedEvidence = items[idx];
				linkCaseId = String(newCaseId);
			}
			showStatus(t("pages.evidence.messages.caseCreated", { id: newCaseId }));
			return;
		}
		try {
			const response = await evidenceService.createCaseFromEvidence(
				selectedEvidenceId,
				selectedEvidence?.report_id ? Number(selectedEvidence.report_id) : undefined,
			);
			if (response?.success) {
				showStatus(t("pages.evidence.messages.caseCreatedFromEvidence", { id: response.caseId || "" }));
				linkCaseId = response.caseId ? String(response.caseId) : linkCaseId;
				await loadEvidence(page);
			} else {
				showStatus((response as any)?.error || t("pages.evidence.messages.createCaseFailed"), "error");
			}
		} catch {
			showStatus(t("pages.evidence.messages.createCaseFailed"), "error");
		}
	}

	async function handleTransferEvidence() {
		if (!selectedEvidenceId || !transferCitizenId.trim()) return;
		await evidenceService.transferEvidenceItem(
			selectedEvidenceId,
			transferCitizenId.trim(),
			transferNotes.trim(),
		);
		custodyEntries = await evidenceService.getEvidenceCustody(selectedEvidenceId);
		transferCitizenId = "";
		transferNotes = "";
	}

	// ── Sidebar: add image via URL ──
	async function handleAddSidebarImageUrl() {
		const url = sidebarImageUrlInput.trim();
		if (!selectedEvidenceId || !url || isSidebarUploading) return;
		isSidebarUploading = true;

		if (isEnvBrowser()) {
			await new Promise((r) => setTimeout(r, 600));
			if (selectedEvidence) {
				if (!selectedEvidence.images) selectedEvidence.images = [];
				selectedEvidence.images = [...selectedEvidence.images, {
					id: Date.now(),
					url,
					label: sidebarImageLabelInput.trim() || "Evidence",
				}];
			}
			uploadSuccess = t("pages.evidence.messages.imageAdded");
			sidebarImageUrlInput = "";
			sidebarImageLabelInput = "";
			sidebarImageUrlModalOpen = false;
			isSidebarUploading = false;
			setTimeout(() => { uploadSuccess = ""; }, 3000);
			return;
		}

		try {
			const result = await evidenceService.addEvidenceImage(selectedEvidenceId, {
				data: url,
				filename: sidebarImageLabelInput.trim() || "image",
				contentType: "url",
				label: sidebarImageLabelInput.trim(),
			});
			if (result?.success && result.url) {
				if (selectedEvidence) {
					if (!selectedEvidence.images) selectedEvidence.images = [];
					selectedEvidence.images = [...selectedEvidence.images, {
						id: result.id || Date.now(),
						url: result.url,
						label: sidebarImageLabelInput.trim(),
					}];
				}
				uploadSuccess = t("pages.evidence.messages.imageAdded");
			} else {
				evidenceError = t("pages.evidence.messages.imageAddFailed");
			}
		} catch {
			evidenceError = t("pages.evidence.messages.imageAddFailed");
		}

		sidebarImageUrlInput = "";
		sidebarImageLabelInput = "";
		sidebarImageUrlModalOpen = false;
		isSidebarUploading = false;
		setTimeout(() => { uploadSuccess = ""; }, 3000);
	}

	async function handleRemoveImage(imageId: number) {
		if (!selectedEvidenceId) return;
		await evidenceService.removeEvidenceImage(imageId);
		if (selectedEvidence?.images) {
			selectedEvidence.images = selectedEvidence.images.filter((img: any) => img.id !== imageId);
		}
	}

	function formatStored(value: boolean | number | undefined) {
		return value ? t("pages.evidence.stored") : t("pages.evidence.inField");
	}

	onMount(async () => {
		if (isEnvBrowser()) {
			items = [
				{ id: 1, case_id: 101, title: 'Bloody Knife', type: 'Physical', serial: 'EVD-001', location: 'Vinewood Blvd Crime Scene', stash_id: 'LOCKER-A12', stored: true, notes: 'Found near victim, bagged and tagged', created_at: '2026-03-15T10:30:00Z', updated_by: 'Ofc. Smith' },
				{ id: 2, case_id: 101, title: 'Security Camera Footage', type: 'Digital', serial: 'EVD-002', location: 'Fleeca Bank - Hawick', stash_id: '', stored: false, notes: 'Footage from 03/14 showing suspect entering bank', created_at: '2026-03-15T11:00:00Z', updated_by: 'Det. Williams' },
				{ id: 3, case_id: 102, title: 'Shell Casings (x4)', type: 'Physical', serial: 'EVD-003', location: 'Route 68 Highway', stash_id: 'LOCKER-B03', stored: true, notes: '9mm casings recovered from scene', created_at: '2026-03-14T08:15:00Z', updated_by: 'Ofc. Johnson' },
				{ id: 4, case_id: 103, title: 'Suspect Phone Records', type: 'Digital', serial: 'EVD-004', location: 'LSPD Tech Lab', stash_id: 'DIGITAL-VAULT', stored: true, notes: 'Call logs subpoenaed from carrier', created_at: '2026-03-13T14:45:00Z', updated_by: 'Det. Chen' },
				{ id: 5, case_id: null, title: 'Damaged License Plate', type: 'Physical', serial: 'EVD-005', location: 'Del Perro Pier Parking', stash_id: '', stored: false, notes: 'Partial plate recovered from hit-and-run', created_at: '2026-03-12T16:20:00Z', updated_by: 'Ofc. Garcia' },
			];
			total = 5;
			return;
		}
		await loadEvidence(1);
	});
</script>

<!-- ── Sidebar Image URL Modal ── -->
{#if sidebarImageUrlModalOpen}
	<!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions -->
	<div class="modal-backdrop" onclick={(e) => { if (e.target === e.currentTarget) sidebarImageUrlModalOpen = false; }}>
		<div class="modal image-url-modal" role="dialog" aria-modal="true" onclick={(e) => e.stopPropagation()}>
			<div class="modal-header">
			<h3>{t("pages.evidence.addEvidenceImage")}</h3>
				<button class="close-btn" onclick={() => sidebarImageUrlModalOpen = false}>
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
				</button>
			</div>
			<div class="modal-body img-modal-body">
				<div class="img-form-group">
				<span class="img-label">{t("pages.evidence.imageUrl")}</span>
					<input
						class="img-input"
						type="url"
					placeholder={t("pages.evidence.placeholders.imageUrl")}
						bind:value={sidebarImageUrlInput}
						onkeydown={(e) => { if (e.key === 'Enter') handleAddSidebarImageUrl(); if (e.key === 'Escape') sidebarImageUrlModalOpen = false; }}
					/>
				</div>
				<div class="img-form-group">
				<span class="img-label">{t("pages.evidence.label")} <span class="img-label-optional">{t("pages.evidence.optional")}</span></span>
					<input
						class="img-input"
						type="text"
					placeholder={t("pages.evidence.placeholders.imageLabel")}
						bind:value={sidebarImageLabelInput}
						onkeydown={(e) => { if (e.key === 'Enter') handleAddSidebarImageUrl(); }}
					/>
				</div>
				<span class="url-hint">
					<svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
					{t("pages.evidence.fiveManagePrefix")} <a href="https://fivemanage.com" target="_blank" rel="noopener noreferrer">FiveManage</a> {t("pages.evidence.fiveManageSuffix")}
				</span>
			</div>
			<div class="modal-footer">
				<button class="cancel-btn" onclick={() => sidebarImageUrlModalOpen = false} disabled={isSidebarUploading}>{t("common.actions.cancel")}</button>
				<button class="save-btn" onclick={handleAddSidebarImageUrl} disabled={isSidebarUploading || !sidebarImageUrlInput.trim()}>
					{isSidebarUploading ? t("pages.evidence.adding") : t("pages.evidence.addImage")}
				</button>
			</div>
		</div>
	</div>
{/if}

<!-- ── Create Image URL Modal ── -->
{#if createImageUrlModalOpen}
	<!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions -->
	<div class="modal-backdrop" onclick={(e) => { if (e.target === e.currentTarget) createImageUrlModalOpen = false; }}>
		<div class="modal image-url-modal" role="dialog" aria-modal="true" onclick={(e) => e.stopPropagation()}>
			<div class="modal-header">
			<h3>{t("pages.evidence.addImageUrl")}</h3>
				<button class="close-btn" onclick={() => createImageUrlModalOpen = false}>
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
				</button>
			</div>
			<div class="modal-body img-modal-body">
				<div class="img-form-group">
				<span class="img-label">{t("pages.evidence.imageUrl")}</span>
					<input
						class="img-input"
						type="url"
					placeholder={t("pages.evidence.placeholders.imageUrl")}
						bind:value={createImageUrlInput}
						onkeydown={(e) => {
							if (e.key === 'Enter' && createImageUrlInput.trim()) {
								createImageUrls = [...createImageUrls, { url: createImageUrlInput.trim(), label: "" }];
								createImageUrlInput = "";
								createImageUrlModalOpen = false;
							}
							if (e.key === 'Escape') createImageUrlModalOpen = false;
						}}
					/>
				</div>
				<span class="url-hint">
					<svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
					{t("pages.evidence.fiveManagePrefix")} <a href="https://fivemanage.com" target="_blank" rel="noopener noreferrer">FiveManage</a> {t("pages.evidence.fiveManageSuffix")}
				</span>
			</div>
			<div class="modal-footer">
				<button class="cancel-btn" onclick={() => createImageUrlModalOpen = false}>{t("common.actions.cancel")}</button>
				<button class="save-btn" onclick={() => {
					if (createImageUrlInput.trim()) {
						createImageUrls = [...createImageUrls, { url: createImageUrlInput.trim(), label: "" }];
						createImageUrlInput = "";
						createImageUrlModalOpen = false;
					}
				}} disabled={!createImageUrlInput.trim()}>
					{t("pages.evidence.addUrl")}
				</button>
			</div>
		</div>
	</div>
{/if}

<div class="evidence-page">
	<!-- Topbar -->
	<div class="topbar">
		<div class="search-box">
			<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
			<input
				type="text"
				placeholder={t("pages.evidence.searchPlaceholder")}
				bind:value={searchQuery}
				onkeydown={(event) => {
					if (event.key === "Enter") loadEvidence(1);
				}}
			/>
		</div>
			<button class="action-btn" onclick={() => loadEvidence(1)}>{t("common.actions.search")}</button>
		<button class="create-btn" onclick={() => {
			resetCreateForm();
			const nextNum = total + 1;
			createForm.serial = `EVD-${String(nextNum).padStart(3, "0")}`;
			createForm.stashId = `LOCKER-${String(nextNum).padStart(3, "0")}`;
			const latestCaseId = items.reduce((max, item) => {
				const id = item.case_id ? Number(item.case_id) : 0;
				return id > max ? id : max;
			}, 0);
			if (latestCaseId > 0) createForm.caseId = String(latestCaseId);
			showCreate = true;
		}}>
			{t("pages.evidence.newEvidence")}
		</button>
	</div>

	<!-- Status Toast -->
	{#if statusMessage}
		<div class="status-toast {statusMessage.type}">
			{statusMessage.text}
		</div>
	{/if}

	<!-- Main 2-column grid -->
	<div class="main-grid">
		<!-- Evidence List (left) -->
		<div class="list-panel">
			{#if isLoading}
			<div class="empty-state">{t("pages.evidence.loading")}</div>
			{:else if items.length === 0}
			<div class="empty-state">{t("pages.evidence.noneFound")}</div>
			{:else}
				<div class="table-header">
				<span class="col-title">{t("pages.evidence.title")}</span>
				<span class="col-type">{t("pages.evidence.type")}</span>
				<span class="col-serial">{t("pages.evidence.serial")}</span>
				<span class="col-case">{t("pages.evidence.case")}</span>
				<span class="col-report">{t("pages.evidence.report")}</span>
				<span class="col-location">{t("pages.evidence.location")}</span>
				<span class="col-stored">{t("pages.evidence.status")}</span>
				<span class="col-date">{t("pages.evidence.date")}</span>
				</div>
				{#each items as item}
					<button class="table-row" class:selected={selectedEvidenceId === item.id} onclick={() => selectEvidence(item)}>
						<span class="col-title">{item.title}</span>
						<span class="col-type"><span class="type-badge">{item.type}</span></span>
						<span class="col-serial">{item.serial || "---"}</span>
						<span class="col-case">
							{#if item.case_id}
								<!-- svelte-ignore a11y_click_events_have_key_events -->
								<span class="nav-link" role="button" tabindex="-1" onclick={(e) => { e.stopPropagation(); navigateTo("Cases"); }}>#{item.case_id}</span>
							{:else}
								---
							{/if}
						</span>
						<span class="col-report">
							{#if item.report_id}
								<!-- svelte-ignore a11y_click_events_have_key_events -->
								<span class="nav-link" role="button" tabindex="-1" onclick={(e) => { e.stopPropagation(); navigateTo("Reports"); }}>#{item.report_id}</span>
							{:else}
								---
							{/if}
						</span>
						<span class="col-location">{item.location || "---"}</span>
						<span class="col-stored"><span class="stored-dot" class:stored={item.stored}></span>{formatStored(item.stored)}</span>
						<span class="col-date">{item.created_at ? formatDate(item.created_at) : "---"}</span>
					</button>
				{/each}
			{/if}
			<Pagination
				currentPage={page}
				totalItems={total}
				perPage={limit}
				perPageOptions={[10, 20, 50, 100]}
				onPageChange={(p) => loadEvidence(p)}
				onPerPageChange={(pp) => { limit = pp; loadEvidence(1); }}
			/>
		</div>

		<!-- Detail Sidebar (right) -->
		<div class="detail-sidebar">
			{#if selectedEvidenceId}
				<!-- Link Evidence + Custody -->
				<div class="section">
				<div class="section-title">{t("pages.evidence.linkEvidence")}</div>
					<div class="section-actions">
					<input class="form-input" placeholder={t("pages.evidence.placeholders.caseId")} bind:value={linkCaseId} />
					<button class="action-btn" onclick={handleLinkEvidenceCase}>{t("pages.evidence.linkToCase")}</button>
					<button class="action-btn" onclick={handleCreateCaseFromEvidence}>{t("pages.evidence.createCase")}</button>
					</div>
					<div class="section-actions">
					<input class="form-input" placeholder={t("pages.evidence.reportId")} bind:value={linkReportId} />
					<button class="action-btn" onclick={handleLinkEvidenceReport}>{t("pages.evidence.linkToReport")}</button>
					</div>
				<div class="section-title" style="margin-top: 8px;">{t("pages.evidence.custodyLog")}</div>
					{#if custodyEntries.length === 0}
					<p class="muted-text">{t("pages.evidence.noCustodyUpdates")}</p>
					{:else}
						<div class="custody-list">
							{#each custodyEntries as entry}
								<div class="custody-item">
									<span class="custody-action {entry.action}">{entry.action}</span>
									<span class="custody-detail">
										{#if entry.action === "viewed"}
											{entry.to_citizenid || "Unknown"}
										{:else if entry.action === "transferred"}
											{entry.from_citizenid || "?"} &rarr; {entry.to_citizenid || "?"}
										{:else}
											{entry.to_citizenid || entry.from_citizenid || ""}
										{/if}
									</span>
									<span class="custody-time">
										{entry.created_at ? formatDateTime(entry.created_at) : ""}
									</span>
									{#if entry.notes}
										<span class="custody-notes">{entry.notes}</span>
									{/if}
								</div>
							{/each}
						</div>
					{/if}
				</div>

				<!-- Transfer Evidence -->
				<div class="section">
				<div class="section-title">{t("pages.evidence.transferEvidence")}</div>
					<div class="transfer-row">
					<input class="form-input" placeholder={t("pages.evidence.citizenId")} bind:value={transferCitizenId} />
					<input class="form-input" placeholder={t("pages.evidence.transferNotes")} bind:value={transferNotes} />
					<button class="action-btn" onclick={handleTransferEvidence}>{t("pages.evidence.transfer")}</button>
					</div>
				</div>

				<!-- Add Image via URL -->
				<div class="section">
				<div class="section-title">{t("pages.evidence.evidenceImages")}</div>
					<button class="add-image-url-btn" onclick={() => {
						sidebarImageUrlInput = "";
						sidebarImageLabelInput = "";
						sidebarImageUrlModalOpen = true;
					}}>
						<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
						Add Image URL
					</button>
					{#if uploadSuccess}
						<p class="upload-success">{uploadSuccess}</p>
					{/if}
					{#if selectedEvidence?.images && selectedEvidence.images.length > 0}
						<div class="image-gallery" style="margin-top: 8px;">
							{#each selectedEvidence.images as img}
								<div class="image-item">
									<button class="image-btn" onclick={() => openLightbox(img.url, img.label || 'Evidence')}>
										<img src={img.url} alt={img.label || 'Evidence'} class="evidence-thumb" />
									</button>
									<div class="image-info">
										<span class="image-label">{img.label || 'No label'}</span>
										<button class="remove-image-btn" onclick={() => handleRemoveImage(img.id)}>
											<span class="material-icons" style="font-size:14px;">close</span>
										</button>
									</div>
								</div>
							{/each}
						</div>
					{/if}
				</div>

				<!-- Open Stash -->
				{#if selectedEvidence?.stash_id}
					<div class="section">
				<div class="section-title">{t("pages.evidence.evidenceStash")}</div>
						<div class="stash-row">
							<span class="stash-id">{selectedEvidence.stash_id}</span>
							<button class="action-btn" onclick={() => openStash(selectedEvidence.stash_id)}>
								<span class="material-icons" style="font-size:14px; margin-right:4px;">inventory_2</span>
								Open Stash
							</button>
						</div>
					</div>
				{/if}
			{:else}
				<div class="empty-detail">
					<svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="opacity:0.25; margin-bottom:10px;"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
			<p>{t("pages.evidence.selectHint")}</p>
				</div>
			{/if}
		</div>
	</div>
</div>

<!-- ── Create Evidence Modal ── -->
{#if showCreate}
	<!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions a11y_no_noninteractive_element_interactions a11y_role_has_required_aria_props -->
	<div class="modal-backdrop" role="button" tabindex="-1" onclick={() => (showCreate = false)}>
		<!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
		<div class="modal" role="dialog" aria-modal="true" onclick={(event) => event.stopPropagation()}>
			<div class="modal-header">
			<h3>{t("pages.evidence.newEvidence")}</h3>
				<button class="close-btn" onclick={() => (showCreate = false)}>
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
				</button>
			</div>
			<div class="modal-body">
				<!-- Row 1: IDs + Title + Type -->
				<div class="form-grid form-grid-4">
					<div class="form-group">
					<span class="form-label">{t("pages.evidence.caseId")}</span>
					<input bind:value={createForm.caseId} placeholder={t("pages.evidence.placeholders.numericCaseId")} class="form-input" />
					</div>
					<div class="form-group">
					<span class="form-label">{t("pages.evidence.reportId")}</span>
					<input bind:value={createForm.reportId} placeholder={t("pages.evidence.reportId")} class="form-input" />
					</div>
					<div class="form-group">
					<span class="form-label">{t("pages.evidence.title")}</span>
					<input bind:value={createForm.title} placeholder={t("pages.evidence.placeholders.title")} class="form-input" />
					</div>
					<div class="form-group">
					<span class="form-label">{t("pages.evidence.type")}</span>
						<select bind:value={createForm.type} class="form-input">
						<option value="Physical">{t("pages.evidence.types.physical")}</option>
						<option value="Digital">{t("pages.evidence.types.digital")}</option>
						<option value="Document">{t("pages.evidence.types.document")}</option>
						<option value="Weapon">{t("pages.evidence.types.weapon")}</option>
						<option value="Drug">{t("pages.evidence.types.drug")}</option>
						<option value="Vehicle">{t("pages.evidence.types.vehicle")}</option>
						<option value="Other">{t("pages.evidence.types.other")}</option>
						</select>
					</div>
				</div>

				<!-- Row 2: Dynamic fields -->
				<div class="form-grid">
					{#if typeConfig.description}
						<div class="form-group" style="grid-column: span 2;">
					<span class="form-label">{t("pages.evidence.description")}</span>
							<input bind:value={createForm.description} placeholder={typeConfig.descriptionPlaceholder || "Describe the evidence"} class="form-input" />
						</div>
					{/if}
					{#if typeConfig.serial}
						<div class="form-group">
							<span class="form-label">{typeConfig.serialLabel || "Serial #"}</span>
							<input bind:value={createForm.serial} placeholder={typeConfig.serialPlaceholder || "Serial number"} class="form-input" />
						</div>
					{/if}
					{#if typeConfig.plate}
						<div class="form-group">
					<span class="form-label">{t("pages.evidence.plateNumber")}</span>
					<input bind:value={createForm.plateNumber} placeholder={t("pages.evidence.placeholders.licensePlate")} class="form-input" />
						</div>
					{/if}
					{#if typeConfig.quantity}
						<div class="form-group">
					<span class="form-label">{t("pages.evidence.quantity")}</span>
					<input bind:value={createForm.quantity} placeholder={t("pages.evidence.placeholders.quantity")} class="form-input" />
						</div>
					{/if}
				</div>

				<!-- Row 3: Location + Stash -->
				<div class="form-grid">
					<div class="form-group" style={typeConfig.stash ? "" : "grid-column: span 3;"}>
					<span class="form-label">{t("pages.evidence.location")}</span>
					<input bind:value={createForm.location} placeholder={t("pages.evidence.placeholders.location")} class="form-input" />
					</div>
					{#if typeConfig.stash}
						<div class="form-group">
					<span class="form-label">{t("pages.evidence.stashId")}</span>
							<input bind:value={createForm.stashId} placeholder="LOCKER-001" class="form-input mono-input" />
						</div>
					{/if}
				</div>

				{#if typeConfig.stored}
					<label class="checkbox-label">
						<input type="checkbox" bind:checked={createForm.stored} />
						<span>{t("pages.evidence.storedSecured")}</span>
					</label>
				{/if}

				<div class="form-group">
					<span class="form-label">{t("pages.evidence.notes")}</span>
					<textarea rows="4" bind:value={createForm.notes} placeholder={t("pages.evidence.placeholders.notes")} class="form-input"></textarea>
				</div>

			</div>
			{#if evidenceError}
				<p class="error-text">{evidenceError}</p>
			{/if}
			<div class="modal-footer">
				<button class="cancel-btn" onclick={() => (showCreate = false)}>{t("common.actions.cancel")}</button>
				<button class="save-btn" onclick={handleCreateEvidence}>{t("pages.evidence.createEvidence")}</button>
			</div>
		</div>
	</div>
{/if}

<!-- Lightbox -->
{#if lightboxUrl}
	<!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions a11y_no_noninteractive_element_interactions -->
	<div class="lightbox-overlay" onclick={closeLightbox} onkeydown={(e) => { if (e.key === 'Escape') closeLightbox(); }}>
		<div class="lightbox-content" onclick={(e) => e.stopPropagation()}>
			<div class="lightbox-header">
				<span class="lightbox-label">{lightboxLabel}</span>
				<button class="close-btn" onclick={closeLightbox}>
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
				</button>
			</div>
			<img src={lightboxUrl} alt={lightboxLabel} class="lightbox-image" />
		</div>
	</div>
{/if}

<style>
	/* ── Page ── */
	.evidence-page {
		height: 100%;
		display: flex;
		flex-direction: column;
		background: var(--card-dark-bg);
		color: rgba(255, 255, 255, 0.9);
		overflow: hidden;
	}

	/* ── Topbar ── */
	.topbar {
		display: flex;
		align-items: center;
		gap: 10px;
		padding: 0 16px;
		height: 42px;
		flex-shrink: 0;
		border-bottom: 1px solid rgba(255, 255, 255, 0.06);
	}

	.search-box {
		display: flex;
		align-items: center;
		gap: 8px;
		background: transparent;
		border: none;
		padding: 0;
		flex: 1;
		max-width: 400px;
		color: rgba(255, 255, 255, 0.2);
	}

	.search-box input {
		background: transparent;
		border: none;
		color: rgba(255, 255, 255, 0.8);
		font-size: 12px;
		padding: 0;
		width: 100%;
		outline: none;
	}

	.search-box input::placeholder { color: rgba(255, 255, 255, 0.2); }

	/* ── Main Grid ── */
	.main-grid {
		display: grid;
		grid-template-columns: 2fr 1fr;
		gap: 0;
		flex: 1;
		min-height: 0;
	}

	/* ── List Panel ── */
	.list-panel {
		background: transparent;
		border-right: 1px solid rgba(255, 255, 255, 0.04);
		display: flex;
		flex-direction: column;
		overflow: hidden;
	}

	.table-header {
		display: grid;
		grid-template-columns: 2fr 0.7fr 1fr 0.6fr 0.6fr 1.3fr 0.9fr 0.9fr;
		gap: 8px;
		padding: 8px 16px;
		border-bottom: 1px solid rgba(255, 255, 255, 0.06);
		font-size: 9px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.6px;
		color: rgba(255, 255, 255, 0.35);
		flex-shrink: 0;
	}

	.table-row {
		display: grid;
		grid-template-columns: 2fr 0.7fr 1fr 0.6fr 0.6fr 1.3fr 0.9fr 0.9fr;
		gap: 8px;
		padding: 7px 16px;
		border: none;
		border-bottom: 1px solid rgba(255, 255, 255, 0.03);
		background: transparent;
		color: rgba(255, 255, 255, 0.85);
		font-size: 11px;
		text-align: left;
		cursor: pointer;
		transition: background 0.1s;
		align-items: center;
		width: 100%;
	}

	.table-row:hover { background: rgba(255, 255, 255, 0.02); }
	.table-row.selected {
		background: rgba(var(--accent-rgb), 0.04);
		border-left: 2px solid rgba(var(--accent-rgb), 0.4);
	}

	.table-row .col-title { font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
	.table-row .col-location { color: rgba(255, 255, 255, 0.35); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
	.table-row .col-serial,
	.table-row .col-case,
	.table-row .col-report,
	.table-row .col-date { color: rgba(255, 255, 255, 0.35); }

	.nav-link { color: rgba(var(--accent-rgb), 0.6); cursor: pointer; transition: all 0.1s; }
	.nav-link:hover { color: rgba(var(--accent-rgb), 0.9); text-decoration: underline; }

	.type-badge {
		display: inline-block;
		font-size: 9px;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: rgba(255, 255, 255, 0.35);
		border: 1px solid rgba(255, 255, 255, 0.06);
		padding: 1px 5px;
		border-radius: 3px;
		background: rgba(255, 255, 255, 0.02);
	}

	.col-stored { display: flex; align-items: center; gap: 5px; font-size: 10px; color: rgba(255, 255, 255, 0.35); }
	.stored-dot { width: 5px; height: 5px; border-radius: 50%; background: rgba(239, 68, 68, 0.5); flex-shrink: 0; }
	.stored-dot.stored { background: rgba(16, 185, 129, 0.6); }

	.empty-state {
		display: flex;
		align-items: center;
		justify-content: center;
		padding: 40px;
		color: rgba(255, 255, 255, 0.35);
		font-size: 11px;
		flex: 1;
	}

	/* ── Detail Sidebar ── */
	.detail-sidebar { display: flex; flex-direction: column; gap: 0; overflow-y: auto; }

	.section {
		background: transparent;
		border-bottom: 1px solid rgba(255, 255, 255, 0.04);
		padding: 12px 16px;
	}
	.section:last-child { border-bottom: none; }

	.section-title {
		color: rgba(255, 255, 255, 0.35);
		font-size: 9px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.6px;
		margin-bottom: 8px;
	}

	.section-actions {
		display: flex;
		gap: 6px;
		align-items: center;
		flex-wrap: wrap;
		margin-bottom: 8px;
	}
	.section-actions .form-input { flex: 1; min-width: 70px; }

	.empty-detail {
		padding: 40px 16px;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		text-align: center;
		color: rgba(255, 255, 255, 0.35);
		font-size: 11px;
		flex: 1;
	}
	.empty-detail p { margin: 0; }

	/* ── Custody ── */
	.custody-list { display: flex; flex-direction: column; gap: 0; }
	.custody-item {
		display: grid;
		grid-template-columns: 70px 1fr auto;
		gap: 4px 6px;
		font-size: 10px;
		padding: 5px 0;
		border-bottom: 1px solid rgba(255, 255, 255, 0.03);
		align-items: center;
	}

	.custody-action { color: rgba(255, 255, 255, 0.5); font-weight: 600; text-transform: uppercase; font-size: 9px; letter-spacing: 0.5px; }
	.custody-action.viewed { color: rgba(var(--accent-rgb), 0.6); }
	.custody-action.collected { color: rgba(16, 185, 129, 0.6); }
	.custody-action.transferred { color: rgba(251, 191, 36, 0.6); }
	.custody-detail { color: rgba(255, 255, 255, 0.4); font-family: monospace; font-size: 10px; }
	.custody-time { color: rgba(255, 255, 255, 0.2); font-size: 9px; white-space: nowrap; }
	.custody-notes { grid-column: 1 / -1; color: rgba(255, 255, 255, 0.35); font-size: 10px; }

	/* ── Transfer Row ── */
	.transfer-row { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
	.transfer-row .form-input { flex: 1; min-width: 80px; }

	/* ── Add Image URL button ── */
	.add-image-url-btn {
		display: inline-flex;
		align-items: center;
		gap: 5px;
		background: rgba(255, 255, 255, 0.03);
		color: rgba(255, 255, 255, 0.4);
		border: 1px solid rgba(255, 255, 255, 0.07);
		padding: 5px 10px;
		border-radius: 3px;
		font-size: 10px;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.1s;
		white-space: nowrap;
	}
	.add-image-url-btn:hover {
		background: rgba(255, 255, 255, 0.05);
		color: rgba(255, 255, 255, 0.7);
		border-color: rgba(255, 255, 255, 0.12);
	}

	.muted-text { color: rgba(255, 255, 255, 0.35); font-size: 11px; margin: 0; }
	.upload-success { color: rgba(110, 231, 183, 0.8); font-size: 10px; margin: 4px 0 0 0; }

	.image-gallery { display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 6px; }
	.image-item { background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.04); border-radius: 3px; overflow: hidden; }
	.evidence-thumb { width: 100%; height: 70px; object-fit: cover; display: block; cursor: pointer; }
	.image-info { display: flex; align-items: center; justify-content: space-between; padding: 3px 5px; }
	.image-label { font-size: 9px; color: rgba(255, 255, 255, 0.4); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1; }
	.remove-image-btn { background: none; border: none; color: rgba(255, 255, 255, 0.2); cursor: pointer; padding: 2px; display: flex; align-items: center; transition: color 0.1s; }
	.remove-image-btn:hover { color: rgba(239, 68, 68, 0.7); }
	.image-btn { background: none; border: none; padding: 0; cursor: pointer; display: block; width: 100%; }

	/* ── Stash ── */
	.stash-row { display: flex; align-items: center; gap: 8px; }
	.stash-id { font-size: 11px; font-family: monospace; color: rgba(255, 255, 255, 0.5); background: rgba(255, 255, 255, 0.02); padding: 4px 8px; border-radius: 3px; border: 1px solid rgba(255, 255, 255, 0.04); flex: 1; }

	/* ── Lightbox ── */
	.lightbox-overlay { position: fixed; inset: 0; background: rgba(0, 0, 0, 0.88); backdrop-filter: blur(8px); display: flex; align-items: center; justify-content: center; z-index: 200; }
	.lightbox-content { max-width: 90vw; max-height: 90vh; display: flex; flex-direction: column; background: var(--card-dark-bg); border: 1px solid rgba(255, 255, 255, 0.06); border-radius: 6px; overflow: hidden; }
	.lightbox-header { display: flex; justify-content: space-between; align-items: center; padding: 8px 12px; border-bottom: 1px solid rgba(255, 255, 255, 0.06); }
	.lightbox-label { font-size: 11px; color: rgba(255, 255, 255, 0.6); font-weight: 500; }
	.lightbox-image { max-width: 85vw; max-height: 80vh; object-fit: contain; display: block; }

	/* ── Create Image list ── */
	.create-image-list { display: flex; flex-direction: column; gap: 2px; margin-top: 6px; }
	.create-image-item { display: flex; align-items: center; gap: 6px; padding: 4px 6px; background: transparent; border-bottom: 1px solid rgba(255, 255, 255, 0.03); }
	.create-image-thumb { width: 28px; height: 28px; object-fit: cover; border-radius: 2px; border: 1px solid rgba(255, 255, 255, 0.06); flex-shrink: 0; }
	.create-image-name { font-size: 10px; color: rgba(255, 255, 255, 0.4); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1; font-family: monospace; }

	/* ── Status Toast ── */
	.status-toast { padding: 5px 12px; border-radius: 3px; font-size: 10px; font-weight: 500; flex-shrink: 0; margin: 0 16px; }
	.status-toast.success { background: rgba(16, 185, 129, 0.06); color: rgba(110, 231, 183, 0.8); border: 1px solid rgba(16, 185, 129, 0.1); }
	.status-toast.error { background: rgba(239, 68, 68, 0.06); color: rgba(252, 165, 165, 0.8); border: 1px solid rgba(239, 68, 68, 0.1); }

	/* ── Buttons ── */
	.action-btn {
		display: inline-flex;
		align-items: center;
		gap: 5px;
		background: rgba(var(--accent-rgb), 0.06);
		color: rgba(var(--accent-text-rgb), 0.7);
		border: 1px solid rgba(var(--accent-rgb), 0.1);
		padding: 4px 10px;
		border-radius: 3px;
		font-size: 10px;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.1s;
		white-space: nowrap;
	}
	.action-btn:hover { background: rgba(var(--accent-rgb), 0.12); color: rgba(var(--accent-text-rgb), 0.9); }

	.create-btn {
		display: inline-flex;
		align-items: center;
		gap: 5px;
		background: rgba(16, 185, 129, 0.06);
		color: rgba(52, 211, 153, 0.7);
		border: 1px solid rgba(16, 185, 129, 0.1);
		padding: 4px 10px;
		border-radius: 3px;
		font-size: 10px;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.1s;
		white-space: nowrap;
	}
	.create-btn:hover { background: rgba(16, 185, 129, 0.12); color: rgba(110, 231, 183, 0.9); }

	/* ── Form Inputs ── */
	.form-input {
		background: rgba(255, 255, 255, 0.03);
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 3px;
		padding: 5px 8px;
		color: rgba(255, 255, 255, 0.8);
		font-size: 11px;
		outline: none;
		transition: border-color 0.1s;
	}
	.form-input:focus { border-color: rgba(255, 255, 255, 0.1); }
	.form-input::placeholder { color: rgba(255, 255, 255, 0.2); }
	textarea.form-input { resize: vertical; min-height: 60px; font-family: inherit; }

	/* ── Image URL Modal ── */
	.image-url-modal { max-width: 380px; }

	.img-modal-body {
		padding: 14px 16px;
		display: flex;
		flex-direction: column;
		gap: 10px;
	}

	.img-form-group { display: flex; flex-direction: column; gap: 4px; }

	.img-label {
		font-size: 9px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.6px;
		color: rgba(255, 255, 255, 0.35);
	}
	.img-label-optional { font-weight: 400; text-transform: none; letter-spacing: 0; color: rgba(255, 255, 255, 0.2); }

	.img-input {
		background: rgba(255, 255, 255, 0.03);
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 3px;
		padding: 6px 8px;
		color: rgba(255, 255, 255, 0.8);
		font-size: 11px;
		outline: none;
		transition: border-color 0.1s;
		font-family: inherit;
		width: 100%;
		box-sizing: border-box;
	}
	.img-input:focus { border-color: rgba(255, 255, 255, 0.12); }
	.img-input::placeholder { color: rgba(255, 255, 255, 0.2); }

	.url-hint {
		display: flex;
		align-items: center;
		gap: 5px;
		font-size: 10px;
		color: rgba(255, 255, 255, 0.25);
		line-height: 1.4;
	}
	.url-hint svg { flex-shrink: 0; opacity: 0.45; }
	.url-hint a { color: rgba(var(--accent-text-rgb), 0.5); text-decoration: none; transition: color 0.1s; }
	.url-hint a:hover { color: rgba(var(--accent-text-rgb), 0.85); text-decoration: underline; }

	/* ── Modal shared ── */
	.modal-backdrop {
		position: fixed;
		inset: 0;
		background: rgba(0, 0, 0, 0.7);
		backdrop-filter: blur(4px);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 100;
	}

	.modal {
		background: var(--card-dark-bg);
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 6px;
		box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
		width: 100%;
		max-width: 700px;
		display: flex;
		flex-direction: column;
	}

	.modal-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 10px 16px;
		border-bottom: 1px solid rgba(255, 255, 255, 0.06);
	}
	.modal-header h3 { margin: 0; font-size: 13px; font-weight: 600; color: rgba(255, 255, 255, 0.85); }

	.close-btn {
		background: transparent;
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 3px;
		padding: 4px;
		color: rgba(255, 255, 255, 0.3);
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: all 0.1s;
	}
	.close-btn:hover { color: rgba(255, 255, 255, 0.7); border-color: rgba(255, 255, 255, 0.1); }

	.modal-body {
		padding: 14px 16px;
		display: flex;
		flex-direction: column;
		gap: 12px;
	}

	.form-grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; }
	.form-grid-4 { grid-template-columns: 1fr 1fr 2fr 1fr; }
	.mono-input { font-family: monospace; letter-spacing: 0.5px; }

	.form-group { display: flex; flex-direction: column; gap: 3px; }
	.form-label { font-size: 9px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: rgba(255, 255, 255, 0.35); }

	.checkbox-label { display: flex; flex-direction: row; align-items: center; gap: 6px; cursor: pointer; font-size: 11px; color: rgba(255, 255, 255, 0.5); }
	.checkbox-label input[type="checkbox"] { accent-color: rgba(52, 211, 153, 0.8); width: 13px; height: 13px; }

	.modal-footer {
		display: flex;
		justify-content: flex-end;
		gap: 8px;
		padding: 10px 16px;
		border-top: 1px solid rgba(255, 255, 255, 0.06);
	}

	.cancel-btn {
		background: transparent;
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 3px;
		padding: 4px 10px;
		color: rgba(255, 255, 255, 0.4);
		font-size: 10px;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.1s;
	}
	.cancel-btn:hover:not(:disabled) { color: rgba(255, 255, 255, 0.7); border-color: rgba(255, 255, 255, 0.1); }
	.cancel-btn:disabled { opacity: 0.4; cursor: not-allowed; }

	.save-btn {
		display: inline-flex;
		align-items: center;
		gap: 5px;
		background: rgba(16, 185, 129, 0.06);
		color: rgba(52, 211, 153, 0.7);
		border: 1px solid rgba(16, 185, 129, 0.1);
		padding: 4px 12px;
		border-radius: 3px;
		font-size: 10px;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.1s;
	}
	.save-btn:hover:not(:disabled) { background: rgba(16, 185, 129, 0.12); color: rgba(110, 231, 183, 0.9); }
	.save-btn:disabled { opacity: 0.4; cursor: not-allowed; }

	.error-text { color: rgba(252, 165, 165, 0.8); font-size: 10px; padding: 0 16px; margin: 0; }

	/* ── Scrollbar ── */
	.detail-sidebar::-webkit-scrollbar { width: 4px; }
	.detail-sidebar::-webkit-scrollbar-track { background: transparent; }
	.detail-sidebar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.06); border-radius: 2px; }

	/* ── Responsive ── */
	@media (max-width: 1024px) {
		.main-grid { grid-template-columns: 1fr; }
		.list-panel { border-right: none; border-bottom: 1px solid rgba(255, 255, 255, 0.04); }
		.topbar { flex-wrap: wrap; }
		.search-box { max-width: 100%; }
	}
</style>
