<script lang="ts">
	import { onMount } from "svelte";
	import { formatDate, formatDateTime } from "../../utils/datetime";
	import { fetchNui } from "../../utils/fetchNui";
	import { isEnvBrowser } from "../../utils/misc";
	import { NUI_EVENTS } from "../../constants/nuiEvents";
	import { globalNotifications } from "../../services/notificationService.svelte";
	import type { createTabService } from "../../services/tabService.svelte";
	import type { AuthService } from "../../services/authService.svelte";
	import { t, tf } from "../../lib/i18n";

	interface Props {
		tabService: ReturnType<typeof createTabService>;
		authService: AuthService;
	}

	let { tabService, authService }: Props = $props();

	type WarrantRequestStatus = "pending" | "approved" | "denied" | "closed";

	interface WarrantRequest {
		id: number;
		citizen_name: string;
		citizenid: string;
		charges: string[];
		requesting_officer: string;
		officer_name?: string;
		requesting_officer_badge?: string;
		linked_report_id?: number;
		reason: string;
		status: WarrantRequestStatus;
		review_reason?: string;
		reviewer_name?: string;
		reviewer_citizenid?: string;
		reviewed_by?: string;
		reviewed_at?: string;
		created_at: string;
	}

	let requests = $state<WarrantRequest[]>([]);
	let selectedRequest = $state<WarrantRequest | null>(null);
	let isLoading = $state(false);
	let searchQuery = $state("");
	let statusFilter = $state<string>("pending");
	let reviewReason = $state("");

	// Court hearing the DOJ can schedule AFTER a warrant request is approved.
	type WarrantHearing = { id: number; scheduled_at: string; hearing_type: string; status: string };
	let existingHearing = $state<WarrantHearing | null>(null);
	let hearingLoading = $state(false);
	let hearingDate = $state("");
	let hearingTime = $state("10:00");
	let hearingType = $state("arraignment");

	// Default the hearing date to two days out whenever a request is opened.
	function defaultHearingDate(): string {
		const d = new Date();
		d.setDate(d.getDate() + 2);
		return d.toISOString().slice(0, 10);
	}

	async function loadWarrantHearing(reportId: number | undefined) {
		existingHearing = null;
		if (!reportId || isEnvBrowser()) return;
		try {
			const res = await fetchNui<{ success: boolean; hearing?: WarrantHearing }>(
				NUI_EVENTS.DOJ.GET_WARRANT_HEARING,
				{ reportId },
				{ success: true },
			);
			existingHearing = res?.hearing ?? null;
		} catch {
			existingHearing = null;
		}
	}

	async function handleScheduleHearing() {
		if (!selectedRequest?.linked_report_id || !hearingDate || !hearingTime) return;
		hearingLoading = true;
		try {
			const res = await fetchNui<{ success: boolean; error?: string; scheduled_at?: string }>(
				NUI_EVENTS.DOJ.SCHEDULE_WARRANT_HEARING,
				{
					reportId: selectedRequest.linked_report_id,
					scheduled_at: `${hearingDate} ${hearingTime}`,
					hearing_type: hearingType,
				},
				{ success: true },
			);
			if (res.success) {
				globalNotifications.success(t("pages.doj.warrantReview.messages.hearingScheduled"));
				await loadWarrantHearing(selectedRequest.linked_report_id);
			} else {
				globalNotifications.error(res.error || t("pages.doj.warrantReview.messages.hearingScheduleFailed"));
			}
		} catch {
			globalNotifications.error(t("pages.doj.warrantReview.messages.hearingScheduleFailed"));
		}
		hearingLoading = false;
	}

	async function handleRemoveHearing() {
		if (!selectedRequest?.linked_report_id) return;
		hearingLoading = true;
		try {
			const res = await fetchNui<{ success: boolean; error?: string }>(
				NUI_EVENTS.DOJ.REMOVE_WARRANT_HEARING,
				{ reportId: selectedRequest.linked_report_id },
				{ success: true },
			);
			if (res.success) {
				globalNotifications.success(t("pages.doj.warrantReview.messages.hearingRemoved"));
				existingHearing = null;
			} else {
				globalNotifications.error(res.error || t("pages.doj.warrantReview.messages.hearingRemoveFailed"));
			}
		} catch {
			globalNotifications.error(t("pages.doj.warrantReview.messages.hearingRemoveFailed"));
		}
		hearingLoading = false;
	}

	let canApprove = $derived(authService?.hasPermission("warrants_approve") ?? false);
	let canClose = $derived(authService?.hasPermission("warrants_close") ?? false);

	// New document modal
	let showNewDocModal = $state(false);
	let newDocData = $state({ title: "", type: "brief" as string, content: "" });

	async function handleCreateDocument() {
		if (!newDocData.title.trim() || !selectedRequest) return;
		try {
			const result = await fetchNui<{ success: boolean; error?: string }>(
				NUI_EVENTS.DOJ.CREATE_LEGAL_DOCUMENT,
				{
					type: newDocData.type,
					title: newDocData.title.trim(),
					content: newDocData.content.trim(),
				},
				{ success: true },
			);
			if (result.success) {
				showNewDocModal = false;
				newDocData = { title: "", type: "brief", content: "" };
				globalNotifications.success(t("pages.doj.warrantReview.messages.documentCreated"));
			} else {
				globalNotifications.error(result.error || t("pages.doj.warrantReview.messages.documentCreateFailed"));
			}
		} catch {
			globalNotifications.error(t("pages.doj.warrantReview.messages.documentCreateFailed"));
		}
	}

	const statusOptions = ["pending", "approved", "closed", "denied", "all"];

	function getStatusPillClass(status: string): string {
		switch (status) {
			case "pending": return "pill-yellow";
			case "approved": return "pill-green";
			case "denied": return "pill-red";
			case "closed": return "pill-grey";
			default: return "pill-grey";
		}
	}

	function formatLabel(value: string): string {
		const fallback = value.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
		return tf(`pages.doj.warrantReview.labels.${value}`, fallback);
	}

	function formatDateValue(value: string | undefined): string {
		return formatDate(value, "-");
	}

	function formatDateTimeValue(value: string | undefined): string {
		return formatDateTime(value, "-");
	}

	let allFilteredRequests = $derived.by(() => {
		let filtered = requests;
		if (statusFilter !== "all") {
			filtered = filtered.filter((r) => r.status === statusFilter);
		}
		const query = searchQuery.trim().toLowerCase();
		if (query) {
			filtered = filtered.filter((r) =>
				[r.citizen_name, r.citizenid, r.requesting_officer, String(r.linked_report_id)]
					.filter(Boolean)
					.some((val) => String(val).toLowerCase().includes(query)),
			);
		}
		return filtered;
	});

	let mounted = false;

	$effect(() => {
		searchQuery;
		statusFilter;
		if (mounted && !isEnvBrowser()) loadRequests();
	});

	onMount(async () => {
		if (isEnvBrowser()) {
			requests = [
				{ id: 1, citizen_name: "Marcus Johnson", citizenid: "ABC123", charges: ["Armed Robbery", "Assault with Deadly Weapon"], requesting_officer: "Ofc. Williams", requesting_officer_badge: "1234", linked_report_id: 101, reason: "Suspect fled scene after armed robbery of Fleeca Bank. Multiple witnesses identified suspect.", status: "pending", created_at: "2026-03-20T10:00:00Z" },
				{ id: 2, citizen_name: "David Chen", citizenid: "DEF456", charges: ["Drug Trafficking", "Possession of Controlled Substance"], requesting_officer: "Det. Ramirez", requesting_officer_badge: "5678", linked_report_id: 102, reason: "Large quantity of narcotics found during traffic stop. Suspect has prior history.", status: "pending", created_at: "2026-03-19T14:30:00Z" },
				{ id: 3, citizen_name: "Tony Ramirez", citizenid: "GHI789", charges: ["Grand Theft Auto"], requesting_officer: "Sgt. Garcia", requesting_officer_badge: "9012", linked_report_id: 103, reason: "Suspect identified via CCTV stealing vehicle from dealership lot.", status: "approved", review_reason: "Sufficient probable cause established.", reviewed_by: "Hon. Patricia Wells", reviewed_at: "2026-03-18T16:00:00Z", created_at: "2026-03-17T08:00:00Z" },
				{ id: 4, citizen_name: "Lisa Park", citizenid: "JKL012", charges: ["Trespassing"], requesting_officer: "Ofc. Thompson", requesting_officer_badge: "3456", linked_report_id: 104, reason: "Suspect found on restricted property.", status: "denied", review_reason: "Insufficient evidence for warrant. Recommend further investigation.", reviewed_by: "Hon. Robert Kim", reviewed_at: "2026-03-16T11:00:00Z", created_at: "2026-03-15T09:00:00Z" },
				{ id: 5, citizen_name: "Frank Doyle", citizenid: "MNO345", charges: ["Burglary", "Resisting Arrest"], requesting_officer: "Det. Ramirez", requesting_officer_badge: "5678", linked_report_id: 105, reason: "Suspect apprehended; warrant served and case resolved.", status: "closed", review_reason: "Probable cause established.", reviewed_by: "Hon. Patricia Wells", reviewed_at: "2026-03-14T10:00:00Z", created_at: "2026-03-13T08:00:00Z" },
			];
			mounted = true;
			return;
		}
		await loadRequests();
		mounted = true;
	});

	let loadInFlight = false;
	let loadQueued = false;

	async function loadRequests() {
		// Never let two getWarrantRequests roundtrips run at once: concurrent
		// identical NUI callbacks can collide on the server response and leave one
		// fetch unresolved (10s timeout). If a load is requested mid-flight, run
		// exactly one more afterwards with the latest filters.
		if (loadInFlight) {
			loadQueued = true;
			return;
		}
		loadInFlight = true;
		isLoading = true;
		try {
			const data = await fetchNui<{ requests: WarrantRequest[] }>(
				NUI_EVENTS.DOJ.GET_WARRANT_REQUESTS,
				{ status: statusFilter === "all" ? "" : statusFilter, search: searchQuery.trim() || "" },
				{ requests: [] },
			);
			requests = (data.requests || []).map((r: any) => ({
				...r,
				charges: typeof r.charges === 'string' ? (() => { try { return JSON.parse(r.charges); } catch { return []; } })() : (r.charges || []),
			}));
		} catch {
			globalNotifications.error(t("pages.doj.warrantReview.messages.loadFailed"));
		}
		isLoading = false;
		loadInFlight = false;
		if (loadQueued) {
			loadQueued = false;
			loadRequests();
		}
	}

	function selectRequest(id: number) {
		selectedRequest = requests.find((r) => r.id === id) || null;
		reviewReason = "";
		hearingDate = defaultHearingDate();
		hearingTime = "10:00";
		hearingType = "arraignment";
		existingHearing = null;
		if (selectedRequest?.status === "approved") {
			loadWarrantHearing(selectedRequest.linked_report_id);
		}
	}

	function goBack() {
		selectedRequest = null;
		reviewReason = "";
		if (!isEnvBrowser()) loadRequests();
	}

	async function handleReview(action: "approved" | "denied") {
		if (!selectedRequest || !reviewReason.trim()) {
			globalNotifications.error(t("pages.doj.warrantReview.messages.reasonRequired"));
			return;
		}
		isLoading = true;
		try {
			const result = await fetchNui<{ success: boolean; error?: string }>(
				NUI_EVENTS.DOJ.REVIEW_WARRANT_REQUEST,
				{
					request_id: selectedRequest.id,
					decision: action,
					reason: reviewReason.trim(),
				},
				{ success: true },
			);
			if (result.success) {
				globalNotifications.success(`Warrant request ${action}`);
				selectedRequest = null;
				reviewReason = "";
				await loadRequests();
			} else {
				globalNotifications.error(result.error || t("pages.doj.warrantReview.messages.reviewFailed"));
			}
		} catch {
			globalNotifications.error(t("pages.doj.warrantReview.messages.reviewFailed"));
		}
		isLoading = false;
	}

	async function handleCloseWarrant() {
		if (!selectedRequest) return;
		isLoading = true;
		try {
			const result = await fetchNui<{ success: boolean; error?: string }>(
				NUI_EVENTS.DOJ.CLOSE_WARRANT_REQUEST,
				{ request_id: selectedRequest.id },
				{ success: true },
			);
			if (result.success) {
				globalNotifications.success(t("pages.doj.warrantReview.messages.closed"));
				selectedRequest = null;
				reviewReason = "";
				await loadRequests();
			} else {
				globalNotifications.error(result.error || t("pages.doj.warrantReview.messages.closeFailed"));
			}
		} catch {
			globalNotifications.error(t("pages.doj.warrantReview.messages.closeFailed"));
		}
		isLoading = false;
	}
</script>

<div class="page">
	{#if selectedRequest}
		<!-- DETAIL VIEW -->
		<div class="topbar">
			<button class="back-btn" onclick={goBack}>
				<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
				Back to Requests
			</button>
			<span class="topbar-case-number">{t("pages.doj.warrantReview.requestNumber", { id: selectedRequest.id })}</span>
			<span class="pill {getStatusPillClass(selectedRequest.status)}">{formatLabel(selectedRequest.status)}</span>
		</div>

		<div class="detail-scroll">
			<div class="detail-layout">
				<div class="detail-main">
					<div class="section">
					<div class="section-title">{t("pages.doj.warrantReview.requestInformation")}</div>
						<div class="field-row">
							<div class="field-group">
							<span class="field-label">{t("pages.doj.warrantReview.citizen")}</span>
								<span class="field-value">{selectedRequest.citizen_name}</span>
							</div>
							<div class="field-group">
							<span class="field-label">{t("pages.doj.warrantReview.citizenId")}</span>
								<span class="field-value mono">{selectedRequest.citizenid}</span>
							</div>
							<div class="field-group">
							<span class="field-label">{t("pages.doj.warrantReview.submitted")}</span>
								<span class="field-value">{formatDateTimeValue(selectedRequest.created_at)}</span>
							</div>
						</div>
					</div>

					<div class="section">
					<div class="section-title">{t("pages.doj.warrantReview.charges")}</div>
						<div class="charges-list">
							{#each selectedRequest.charges as charge}
								<span class="charge-chip">{charge}</span>
							{/each}
							{#if selectedRequest.charges.length === 0}
						<span class="muted-text">{t("pages.doj.warrantReview.noCharges")}</span>
							{/if}
						</div>
					</div>

					<div class="section">
					<div class="section-title">{t("pages.doj.warrantReview.requestingOfficer")}</div>
						<div class="field-row">
							<div class="field-group">
							<span class="field-label">{t("pages.doj.warrantReview.officer")}</span>
								<span class="field-value">{selectedRequest.officer_name || selectedRequest.requesting_officer}{selectedRequest.requesting_officer_badge ? ` (#${selectedRequest.requesting_officer_badge})` : ""}</span>
							</div>
							{#if selectedRequest.linked_report_id}
								<div class="field-group">
								<span class="field-label">{t("pages.doj.warrantReview.linkedReport")}</span>
									<span class="field-value link">#{selectedRequest.linked_report_id}</span>
								</div>
							{/if}
						</div>
					</div>

					<div class="section">
					<div class="section-title">{t("pages.doj.warrantReview.reasonJustification")}</div>
					<p class="summary-text">{selectedRequest.reason || t("pages.doj.warrantReview.noReason")}</p>
					</div>

					{#if selectedRequest.review_reason}
						<div class="section">
					<div class="section-title">{t("pages.doj.warrantReview.reviewDecision")}</div>
							<p class="summary-text">{selectedRequest.review_reason}</p>
							<div class="field-row">
								<div class="field-group">
							<span class="field-label">{t("pages.doj.warrantReview.reviewedBy")}</span>
									<span class="field-value">{selectedRequest.reviewer_name || selectedRequest.reviewed_by || "-"}</span>
								</div>
								<div class="field-group">
							<span class="field-label">{t("pages.doj.warrantReview.reviewedAt")}</span>
									<span class="field-value">{formatDateTimeValue(selectedRequest.reviewed_at)}</span>
								</div>
							</div>
						</div>
					{/if}
				</div>

				<div class="detail-side">
					{#if canApprove && selectedRequest.status === "pending"}
						<div class="section">
							<div class="section-title">{t("pages.doj.warrantReview.judicialReview")}</div>
							<div class="form-group">
								<label class="form-label">{t("pages.doj.warrantReview.reason")}</label>
								<textarea class="form-textarea" placeholder={t("pages.doj.warrantReview.reasonPlaceholder")} bind:value={reviewReason}></textarea>
							</div>
							<div class="review-actions">
								<button class="approve-btn" disabled={!reviewReason.trim() || isLoading} onclick={() => handleReview("approved")}>
									<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
									{t("pages.doj.warrantReview.approve")}
								</button>
								<button class="deny-btn" disabled={!reviewReason.trim() || isLoading} onclick={() => handleReview("denied")}>
									<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
									{t("pages.doj.warrantReview.deny")}
								</button>
							</div>
						</div>
					{:else if !canApprove && selectedRequest.status === "pending"}
						<div class="section">
							<div class="center-state" style="padding: 20px;">
								<p>{t("pages.doj.warrantReview.permissionRequired")}</p>
							</div>
						</div>
					{/if}
					{#if selectedRequest.status === "approved" && canClose}
						<div class="section">
							<div class="section-title">{t("pages.doj.warrantReview.activeWarrant")}</div>
							<p class="muted-text">
								{#if selectedRequest.linked_report_id}
									{t("pages.doj.warrantReview.activeLinked", { report: selectedRequest.linked_report_id })}
								{:else}
									{t("pages.doj.warrantReview.activeUnlinked")}
								{/if}
							</p>
							<div class="review-actions">
								<button class="close-warrant-btn" disabled={isLoading} onclick={handleCloseWarrant}>
									<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
									{t("pages.doj.warrantReview.closeWarrant")}
								</button>
							</div>
						</div>
					{/if}
					{#if selectedRequest.status === "approved" && selectedRequest.linked_report_id && canApprove}
						<div class="section">
							<div class="section-title">{t("pages.doj.warrantReview.courtHearing")}</div>
							{#if existingHearing}
								<div class="field-row">
									<span class="field-label">{t("pages.doj.warrantReview.scheduled")}</span>
									<span class="field-value">{formatDateTimeValue(existingHearing.scheduled_at)}</span>
								</div>
								<div class="field-row">
									<span class="field-label">{t("pages.doj.warrantReview.type")}</span>
									<span class="field-value">{formatLabel(existingHearing.hearing_type)}</span>
								</div>
								<p class="muted-text">{t("pages.doj.warrantReview.existingHearingInfo")}</p>
								<div class="review-actions">
									<button class="deny-btn" disabled={hearingLoading} onclick={handleRemoveHearing}>
										<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="m19 6-1 14H6L5 6"/></svg>
										{t("pages.doj.warrantReview.removeHearing")}
									</button>
								</div>
							{:else}
								<p class="muted-text">{t("pages.doj.warrantReview.scheduleHearingInfo")}</p>
								<div class="hearing-fields">
									<div class="hearing-field">
										<label class="form-label" for="h-date">{t("pages.doj.warrantReview.date")}</label>
										<input id="h-date" type="date" class="form-input" bind:value={hearingDate} />
									</div>
									<div class="hearing-field">
										<label class="form-label" for="h-time">{t("pages.doj.warrantReview.time")}</label>
										<input id="h-time" type="time" class="form-input" bind:value={hearingTime} />
									</div>
									<div class="hearing-field">
										<label class="form-label" for="h-type">{t("pages.doj.warrantReview.type")}</label>
										<select id="h-type" class="form-input" bind:value={hearingType}>
											<option value="arraignment">{formatLabel("arraignment")}</option>
											<option value="trial">{formatLabel("trial")}</option>
											<option value="sentencing">{formatLabel("sentencing")}</option>
											<option value="motion">{formatLabel("motion")}</option>
											<option value="appeal">{formatLabel("appeal")}</option>
											<option value="hearing">{formatLabel("hearing")}</option>
										</select>
									</div>
								</div>
								<div class="review-actions">
									<button class="approve-btn" disabled={hearingLoading || !hearingDate || !hearingTime} onclick={handleScheduleHearing}>
										<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4"/><path d="M8 2v4"/><path d="M3 10h18"/></svg>
										{t("pages.doj.warrantReview.scheduleHearing")}
									</button>
								</div>
							{/if}
						</div>
					{/if}
					<div class="section">
						<div class="section-header-row">
							<span class="section-title">{t("pages.doj.warrantReview.documents")}</span>
							<button class="add-btn" onclick={() => { newDocData = { title: t("pages.doj.warrantReview.documentDefaultTitle", { name: selectedRequest?.citizen_name || "" }), type: "ruling", content: "" }; showNewDocModal = true; }}>+ {t("common.actions.add")}</button>
						</div>
					</div>
				</div>
			</div>
		</div>
	{:else}
		<!-- LIST VIEW -->
		<div class="topbar">
			<div class="search-box">
				<input type="text" placeholder={t("pages.doj.warrantReview.searchPlaceholder")} bind:value={searchQuery} />
			</div>
			<div class="filter-pills">
				{#each statusOptions as opt}
					<button class="filter-pill" class:active={statusFilter === opt} onclick={() => (statusFilter = opt)}>
						{formatLabel(opt)}
					</button>
				{/each}
			</div>
			<div class="topbar-actions">
				<span class="result-count">{t(allFilteredRequests.length === 1 ? "pages.doj.warrantReview.countOne" : "pages.doj.warrantReview.countMany", { count: allFilteredRequests.length })}</span>
				<button class="action-btn" onclick={loadRequests} disabled={isLoading}>{isLoading ? t("common.status.loading") : t("pages.doj.warrantReview.refresh")}</button>
			</div>
		</div>

		<div class="list-panel">
			{#if isLoading && requests.length === 0}
				<div class="center-state">
					<div class="loading-spinner"></div>
					<p>{t("pages.doj.warrantReview.loading")}</p>
				</div>
			{:else if allFilteredRequests.length === 0}
				<div class="center-state">
					<h3>{t("pages.doj.warrantReview.noneFound")}</h3>
					<p>{searchQuery ? t("pages.doj.warrantReview.noMatches") : t("pages.doj.warrantReview.noneAvailable")}</p>
				</div>
			{:else}
				<div class="table-header">
					<span>{t("pages.doj.warrantReview.citizen")}</span>
					<span>{t("pages.doj.warrantReview.charges")}</span>
					<span>{t("pages.doj.warrantReview.requestingOfficer")}</span>
					<span>{t("pages.doj.warrantReview.report")}</span>
					<span>{t("pages.doj.warrantReview.status")}</span>
					<span>{t("pages.doj.warrantReview.date")}</span>
				</div>
				<div class="table-body">
					{#each allFilteredRequests as item}
						<button class="table-row" onclick={() => selectRequest(item.id)}>
							<span class="row-title">{item.citizen_name}</span>
							<span class="row-charges">{item.charges.slice(0, 2).join(", ")}{item.charges.length > 2 ? ` +${item.charges.length - 2}` : ""}</span>
							<span>{item.requesting_officer}</span>
							<span class="row-case">{item.linked_report_id ? `#${item.linked_report_id}` : "-"}</span>
							<span><span class="pill {getStatusPillClass(item.status)}">{formatLabel(item.status)}</span></span>
							<span>{formatDateValue(item.created_at)}</span>
						</button>
					{/each}
				</div>
			{/if}
		</div>
	{/if}
</div>

{#if showNewDocModal}
<div class="modal-backdrop" onclick={() => (showNewDocModal = false)} role="presentation">
	<div class="modal" onclick={(e) => e.stopPropagation()} role="dialog">
		<div class="modal-header">
				<span class="modal-title">{t("pages.doj.warrantReview.newDocument")}</span>
			<button class="modal-close" onclick={() => (showNewDocModal = false)}>
				<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
			</button>
		</div>
		<div class="modal-body">
			<div class="form-group">
					<label class="form-label">{t("pages.doj.warrantReview.title")}</label>
				<input type="text" class="form-input" bind:value={newDocData.title} />
			</div>
			<div class="form-group">
					<label class="form-label">{t("pages.doj.warrantReview.type")}</label>
				<select class="form-select" bind:value={newDocData.type}>
						<option value="brief">{formatLabel("brief")}</option>
						<option value="motion">{formatLabel("motion")}</option>
						<option value="ruling">{formatLabel("ruling")}</option>
						<option value="opinion">{formatLabel("opinion")}</option>
						<option value="plea_deal">{formatLabel("plea_deal")}</option>
						<option value="sentencing">{formatLabel("sentencing")}</option>
						<option value="other">{formatLabel("other")}</option>
				</select>
			</div>
			<div class="form-group">
					<label class="form-label">{t("pages.doj.warrantReview.content")}</label>
					<textarea class="form-textarea" rows="6" placeholder={t("pages.doj.warrantReview.contentPlaceholder")} bind:value={newDocData.content}></textarea>
			</div>
		</div>
		<div class="modal-footer">
				<button class="back-btn" onclick={() => (showNewDocModal = false)}>{t("common.actions.cancel")}</button>
				<button class="primary-btn" disabled={!newDocData.title.trim()} onclick={handleCreateDocument}>{t("pages.doj.warrantReview.createDocument")}</button>
		</div>
	</div>
</div>
{/if}

<style>
	.page {
		height: 100%;
		background: var(--card-dark-bg);
		color: rgba(255, 255, 255, 0.9);
		display: flex;
		flex-direction: column;
		overflow: hidden;
	}

	.topbar {
		display: flex;
		align-items: center;
		gap: 10px;
		padding: 0 16px;
		height: 42px;
		flex-shrink: 0;
		border-bottom: 1px solid rgba(255, 255, 255, 0.06);
	}

	.topbar-case-number {
		color: rgba(255, 255, 255, 0.3);
		font-size: 10px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.8px;
	}

	.topbar-actions {
		display: flex;
		align-items: center;
		gap: 8px;
		margin-left: auto;
	}

	.result-count {
		color: rgba(255, 255, 255, 0.2);
		font-size: 10px;
	}

	.search-box {
		display: flex;
		align-items: center;
		min-width: 200px;
	}

	.search-box input {
		background: transparent;
		border: none;
		color: rgba(255, 255, 255, 0.8);
		font-size: 12px;
		padding: 0;
		outline: none;
		width: 100%;
	}

	.search-box input::placeholder {
		color: rgba(255, 255, 255, 0.2);
	}

	.filter-pills {
		display: flex;
		align-items: center;
		gap: 4px;
		overflow-x: auto;
	}

	.filter-pill {
		background: transparent;
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 3px;
		padding: 3px 8px;
		color: rgba(255, 255, 255, 0.4);
		font-size: 10px;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.1s;
		white-space: nowrap;
	}

	.filter-pill:hover {
		color: rgba(255, 255, 255, 0.6);
		border-color: rgba(255, 255, 255, 0.1);
	}

	.filter-pill.active {
		background: rgba(var(--accent-rgb), 0.08);
		color: rgba(var(--accent-text-rgb), 0.8);
		border-color: rgba(var(--accent-rgb), 0.15);
	}

	.back-btn {
		display: inline-flex;
		align-items: center;
		gap: 5px;
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

	.back-btn:hover:not(:disabled) {
		color: rgba(255, 255, 255, 0.7);
		border-color: rgba(255, 255, 255, 0.1);
	}

	.action-btn {
		display: inline-flex;
		align-items: center;
		gap: 5px;
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

	.action-btn:hover:not(:disabled) {
		color: rgba(255, 255, 255, 0.7);
		border-color: rgba(255, 255, 255, 0.1);
	}

	.action-btn:disabled {
		opacity: 0.3;
		cursor: not-allowed;
	}

	.pill {
		padding: 1px 6px;
		border-radius: 3px;
		font-size: 10px;
		font-weight: 600;
		text-transform: capitalize;
		white-space: nowrap;
	}

	.pill-yellow {
		background: rgba(234, 179, 8, 0.08);
		color: rgba(250, 204, 21, 0.8);
		border: 1px solid rgba(234, 179, 8, 0.1);
	}

	.pill-green {
		background: rgba(16, 185, 129, 0.08);
		color: rgba(52, 211, 153, 0.8);
		border: 1px solid rgba(16, 185, 129, 0.1);
	}

	.pill-red {
		background: rgba(239, 68, 68, 0.08);
		color: rgba(248, 113, 113, 0.8);
		border: 1px solid rgba(239, 68, 68, 0.1);
	}

	.pill-grey {
		background: rgba(107, 114, 128, 0.08);
		color: rgba(156, 163, 175, 0.8);
		border: 1px solid rgba(107, 114, 128, 0.1);
	}

	.list-panel {
		background: transparent;
		border: none;
		border-radius: 0;
		flex: 1;
		min-height: 0;
		display: flex;
		flex-direction: column;
		overflow: hidden;
	}

	.table-header {
		display: grid;
		grid-template-columns: 1.2fr 2fr 1.2fr 0.6fr 0.7fr 0.8fr;
		gap: 8px;
		padding: 8px 16px;
		border-bottom: 1px solid rgba(255, 255, 255, 0.06);
	}

	.table-header span {
		color: rgba(255, 255, 255, 0.35);
		font-size: 9px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.6px;
	}

	.table-body {
		flex: 1;
		overflow-y: auto;
	}

	.table-row {
		display: grid;
		grid-template-columns: 1.2fr 2fr 1.2fr 0.6fr 0.7fr 0.8fr;
		gap: 8px;
		padding: 7px 16px;
		border: none;
		border-bottom: 1px solid rgba(255, 255, 255, 0.03);
		background: transparent;
		width: 100%;
		text-align: left;
		cursor: pointer;
		transition: background 0.1s;
		align-items: center;
	}

	.table-row:hover {
		background: rgba(255, 255, 255, 0.02);
	}

	.table-row span {
		font-size: 11px;
		color: rgba(255, 255, 255, 0.45);
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.row-title {
		color: rgba(255, 255, 255, 0.75) !important;
		font-weight: 500;
	}

	.row-case {
		color: rgba(96, 165, 250, 0.7) !important;
		font-weight: 500;
	}

	.row-charges {
		font-size: 10px !important;
		color: rgba(255, 255, 255, 0.35) !important;
	}

	.detail-layout {
		display: grid;
		grid-template-columns: 2fr 1fr;
		gap: 0;
	}

	.detail-main {
		display: flex;
		flex-direction: column;
		gap: 0;
		border-right: 1px solid rgba(255, 255, 255, 0.04);
	}

	.detail-side {
		display: flex;
		flex-direction: column;
		gap: 0;
	}

	.detail-scroll {
		flex: 1;
		min-height: 0;
		overflow-y: auto;
		display: flex;
		flex-direction: column;
		gap: 0;
		padding-bottom: 12px;
	}

	.section {
		background: transparent;
		border: none;
		border-bottom: 1px solid rgba(255, 255, 255, 0.04);
		border-radius: 0;
		padding: 12px 16px;
		display: flex;
		flex-direction: column;
		gap: 8px;
	}

	.section:last-child {
		border-bottom: none;
	}

	.section-title {
		color: rgba(255, 255, 255, 0.35);
		font-size: 9px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.6px;
		margin-bottom: 2px;
	}

	.field-row {
		display: flex;
		gap: 10px;
		align-items: flex-start;
		flex-wrap: wrap;
	}

	.field-group {
		display: flex;
		flex-direction: column;
		gap: 3px;
		min-width: 120px;
		flex: 1;
	}

	.field-label {
		color: rgba(255, 255, 255, 0.35);
		font-size: 9px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.field-value {
		color: rgba(255, 255, 255, 0.75);
		font-size: 11px;
	}

	.field-value.mono {
		font-family: monospace;
		font-size: 10px;
		color: rgba(255, 255, 255, 0.35);
	}

	.field-value.link {
		color: rgba(96, 165, 250, 0.7);
		font-weight: 500;
	}

	.summary-text {
		color: rgba(255, 255, 255, 0.5);
		font-size: 11px;
		margin: 0;
		line-height: 1.5;
		white-space: pre-wrap;
	}

	.muted-text {
		color: rgba(255, 255, 255, 0.35);
		font-size: 11px;
		margin: 0;
	}

	.charges-list {
		display: flex;
		flex-wrap: wrap;
		gap: 6px;
	}

	.charge-chip {
		background: rgba(239, 68, 68, 0.06);
		border: 1px solid rgba(239, 68, 68, 0.1);
		border-radius: 3px;
		padding: 2px 8px;
		color: rgba(248, 113, 113, 0.8);
		font-size: 10px;
		font-weight: 500;
	}

	.form-group {
		display: flex;
		flex-direction: column;
		gap: 4px;
	}

	.form-label {
		color: rgba(255, 255, 255, 0.35);
		font-size: 9px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.form-textarea {
		background: rgba(255, 255, 255, 0.03);
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 3px;
		padding: 5px 8px;
		color: rgba(255, 255, 255, 0.8);
		font-size: 11px;
		outline: none;
		resize: vertical;
		width: 100%;
		box-sizing: border-box;
		min-height: 80px;
	}

	.form-textarea:focus {
		border-color: rgba(255, 255, 255, 0.1);
	}

	.form-textarea::placeholder {
		color: rgba(255, 255, 255, 0.2);
	}

	.review-actions {
		display: flex;
		gap: 8px;
		margin-top: 4px;
	}

	.form-input {
		background: rgba(255, 255, 255, 0.03);
		border: 1px solid rgba(255, 255, 255, 0.06);
		border-radius: 3px;
		padding: 5px 8px;
		color: rgba(255, 255, 255, 0.85);
		font-size: 11px;
		outline: none;
		width: 100%;
		box-sizing: border-box;
		font-family: inherit;
	}

	.form-input:focus {
		border-color: rgba(255, 255, 255, 0.1);
	}

	.hearing-fields {
		display: grid;
		grid-template-columns: 1fr 1fr 1fr;
		gap: 8px;
	}

	.hearing-field {
		display: flex;
		flex-direction: column;
		gap: 3px;
	}

	.approve-btn {
		display: inline-flex;
		align-items: center;
		gap: 5px;
		background: rgba(16, 185, 129, 0.08);
		color: rgba(52, 211, 153, 0.8);
		border: 1px solid rgba(16, 185, 129, 0.12);
		border-radius: 3px;
		padding: 5px 12px;
		font-size: 10px;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.1s;
		flex: 1;
		justify-content: center;
	}

	.approve-btn:hover:not(:disabled) {
		background: rgba(16, 185, 129, 0.14);
	}

	.approve-btn:disabled {
		opacity: 0.3;
		cursor: not-allowed;
	}

	.deny-btn {
		display: inline-flex;
		align-items: center;
		gap: 5px;
		background: rgba(239, 68, 68, 0.08);
		color: rgba(248, 113, 113, 0.8);
		border: 1px solid rgba(239, 68, 68, 0.12);
		border-radius: 3px;
		padding: 5px 12px;
		font-size: 10px;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.1s;
		flex: 1;
		justify-content: center;
	}

	.deny-btn:hover:not(:disabled) {
		background: rgba(239, 68, 68, 0.14);
	}

	.deny-btn:disabled {
		opacity: 0.3;
		cursor: not-allowed;
	}

	.close-warrant-btn {
		display: inline-flex;
		align-items: center;
		gap: 5px;
		background: rgba(245, 158, 11, 0.08);
		color: rgba(251, 191, 36, 0.85);
		border: 1px solid rgba(245, 158, 11, 0.14);
		border-radius: 3px;
		padding: 5px 12px;
		font-size: 10px;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.1s;
		flex: 1;
		justify-content: center;
	}

	.close-warrant-btn:hover:not(:disabled) {
		background: rgba(245, 158, 11, 0.14);
	}

	.close-warrant-btn:disabled {
		opacity: 0.3;
		cursor: not-allowed;
	}

	.center-state {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		flex: 1;
		text-align: center;
		padding: 60px 20px;
	}

	.center-state h3 {
		color: rgba(255, 255, 255, 0.5);
		font-size: 14px;
		font-weight: 600;
		margin: 12px 0 4px;
	}

	.center-state p {
		color: rgba(255, 255, 255, 0.35);
		font-size: 11px;
		margin: 0 0 12px;
	}

	.loading-spinner {
		width: 24px;
		height: 24px;
		border: 2px solid rgba(255, 255, 255, 0.06);
		border-left: 2px solid rgba(var(--accent-rgb), 0.5);
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	@keyframes spin {
		to { transform: rotate(360deg); }
	}

	.table-body::-webkit-scrollbar {
		width: 4px;
	}

	.table-body::-webkit-scrollbar-track {
		background: transparent;
	}

	.table-body::-webkit-scrollbar-thumb {
		background: rgba(255, 255, 255, 0.06);
		border-radius: 2px;
	}

	.section-header-row { display: flex; justify-content: space-between; align-items: center; }
	.section-header-row .section-title { margin-bottom: 0; }
	.add-btn { background: transparent; border: none; color: rgba(255,255,255,0.35); cursor: pointer; font-size: 10px; font-weight: 500; padding: 2px 6px; transition: color 0.1s; }
	.add-btn:hover { color: rgba(255,255,255,0.5); }

	.modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 100; }
	.modal { background: var(--dark-bg); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; width: 480px; max-height: 80vh; display: flex; flex-direction: column; overflow: hidden; }
	.modal-header { display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-bottom: 1px solid rgba(255,255,255,0.06); }
	.modal-title { color: rgba(255,255,255,0.85); font-size: 13px; font-weight: 600; }
	.modal-close { background: transparent; border: none; color: rgba(255,255,255,0.3); cursor: pointer; padding: 4px; display: flex; transition: color 0.1s; }
	.modal-close:hover { color: rgba(255,255,255,0.7); }
	.modal-body { padding: 16px; display: flex; flex-direction: column; gap: 12px; overflow-y: auto; }
	.modal-footer { display: flex; justify-content: flex-end; gap: 8px; padding: 12px 16px; border-top: 1px solid rgba(255,255,255,0.06); }
</style>
