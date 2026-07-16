<script lang="ts">
	import { onMount } from "svelte";
	import { fetchNui } from "../../utils/fetchNui";
	import { formatDate, formatTime, formatDateTime, formatRelative, toDate } from "../../utils/datetime";
	import { isEnvBrowser } from "../../utils/misc";
	import { NUI_EVENTS } from "../../constants/nuiEvents";
	import { t } from "../../lib/i18n";
	import Pagination from "../Pagination.svelte";

	interface AuditLog {
		id: number;
		actor_name: string;
		action: string;
		entity_type: string;
		entity_id: string | null;
		details: string | null;
		created_at: string;
	}

	interface PaginatedResponse {
		items: AuditLog[];
		total: number;
		page: number;
		perPage: number;
	}

	const ACTION_LABELS: Record<string, string> = {
		// Authentication
		mdt_login:  t("management.activity.labels.loggedIn"),
		mdt_logout: t("management.activity.labels.loggedOut"),
		// Reports
		report_created: t("management.activity.labels.reportCreated"),
		report_updated: t("management.activity.labels.reportUpdated"),
		report_deleted: t("management.activity.labels.reportDeleted"),
		// Warrants
		warrant_issued: t("management.activity.labels.warrantIssued"),
		warrant_closed: t("management.activity.labels.warrantClosed"),
		// Cases
		case_created:              t("management.activity.labels.caseCreated"),
		case_updated:              t("management.activity.labels.caseUpdated"),
		case_deleted:              t("management.activity.labels.caseDeleted"),
		case_officer_assigned:     t("management.activity.labels.caseOfficerAssigned"),
		case_officer_removed:      t("management.activity.labels.caseOfficerRemoved"),
		case_attachment_added:     t("management.activity.labels.caseAttachmentAdded"),
		case_attachment_removed:   t("management.activity.labels.caseAttachmentRemoved"),
		case_attachment_uploaded:  t("management.activity.labels.caseAttachmentUploaded"),
		// Evidence
		evidence_added:            t("management.activity.labels.evidenceAdded"),
		evidence_updated:          t("management.activity.labels.evidenceUpdated"),
		evidence_deleted:          t("management.activity.labels.evidenceDeleted"),
		evidence_transferred:      t("management.activity.labels.evidenceTransferred"),
		evidence_image_added:      t("management.activity.labels.evidenceImageAdded"),
		evidence_image_removed:    t("management.activity.labels.evidenceImageRemoved"),
		evidence_linked_case:      t("management.activity.labels.evidenceLinkedCase"),
		case_created_from_evidence:t("management.activity.labels.caseCreatedFromEvidence"),
		// Weapons
		weapon_created: t("management.activity.labels.weaponCreated"),
		weapon_updated: t("management.activity.labels.weaponUpdated"),
		weapon_deleted: t("management.activity.labels.weaponDeleted"),
		// Vehicles
		vehicle_updated:    t("management.activity.labels.vehicleUpdated"),
		vehicle_impounded:  t("management.activity.labels.vehicleImpounded"),
		vehicle_released:   t("management.activity.labels.vehicleReleased"),
		vehicle_impound_fee_paid: t("management.activity.labels.vehicleImpoundFeePaid"),
		// Searches
		search_citizens: t("management.activity.labels.searchCitizens"),
		search_players:  t("management.activity.labels.searchPlayers"),
		search_officers: t("management.activity.labels.searchOfficers"),
		// Charges / Fines / Sentencing
		fine_processed:  t("management.activity.labels.fineProcessed"),
		charge_updated:  t("management.activity.labels.chargeUpdated"),
		arrest_logged:   t("management.activity.labels.arrestLogged"),
		sent_to_jail:    t("management.activity.labels.sentToJail"),
		// Officers / Dispatch
		callsign_changed:      t("management.activity.labels.callsignChanged"),
		signal100_activated:   t("management.activity.labels.signal100Activated"),
		signal100_deactivated: t("management.activity.labels.signal100Deactivated"),
		icu_deleted:           t("management.activity.labels.icuDeleted"),
		// Cameras / Bodycams
		camera_viewed:  t("management.activity.labels.cameraViewed"),
		bodycam_viewed: t("management.activity.labels.bodycamViewed"),
		// ── Patrols ──────────────────────────────────────────────────────────
		patrol_created:          t("management.activity.labels.patrolCreated"),
		patrol_deleted:          t("management.activity.labels.patrolDeleted"),
		patrol_renamed:          t("management.activity.labels.patrolRenamed"),
		patrol_zone_created:     t("management.activity.labels.patrolZoneCreated"),
		patrol_zone_updated:     t("management.activity.labels.patrolZoneUpdated"),
		patrol_zone_cleared:     t("management.activity.labels.patrolZoneCleared"),
		patrol_officer_assigned: t("management.activity.labels.patrolOfficerAssigned"),
		patrol_officer_removed:  t("management.activity.labels.patrolOfficerRemoved"),
		patrols_reordered:       t("management.activity.labels.patrolsReordered"),
		// ── Dispatch calls ───────────────────────────────────────────────────
		dispatch_create:         t("management.activity.labels.dispatchCreate"),
		dispatch_dismiss:        t("management.activity.labels.dispatchDismiss"),
		dispatch_note_add:       t("management.activity.labels.dispatchNoteAdd"),
		dispatch_note_edit:      t("management.activity.labels.dispatchNoteEdit"),
		dispatch_note_delete:    t("management.activity.labels.dispatchNoteDelete"),
		dispatch_attach_units:   t("management.activity.labels.dispatchAttachUnits"),
		dispatch_detach_units:   t("management.activity.labels.dispatchDetachUnits"),
	};

	const ACTION_ICONS: Record<string, { icon: string; color: string }> = {
		mdt_login:  { icon: "login",  color: "#3b82f6" },
		mdt_logout: { icon: "logout", color: "#6b7280" },
		report_created: { icon: "description", color: "#10b981" },
		report_updated: { icon: "edit_note",   color: "#f59e0b" },
		report_deleted: { icon: "delete",      color: "#ef4444" },
		warrant_issued: { icon: "gavel",       color: "#ef4444" },
		warrant_closed: { icon: "check_circle",color: "#10b981" },
		case_created:   { icon: "folder_open", color: "#3b82f6" },
		case_updated:   { icon: "folder",      color: "#f59e0b" },
		case_deleted:   { icon: "folder_delete",color: "#ef4444" },
		case_officer_assigned: { icon: "person_add",    color: "#10b981" },
		case_officer_removed:  { icon: "person_remove", color: "#ef4444" },
		evidence_added:     { icon: "inventory_2", color: "#8b5cf6" },
		evidence_updated:   { icon: "inventory_2", color: "#f59e0b" },
		evidence_deleted:   { icon: "delete",      color: "#ef4444" },
		evidence_transferred: { icon: "swap_horiz", color: "#8b5cf6" },
		weapon_created: { icon: "security",       color: "#10b981" },
		weapon_updated: { icon: "security",       color: "#f59e0b" },
		weapon_deleted: { icon: "no_encryption",  color: "#ef4444" },
		vehicle_updated:   { icon: "directions_car", color: "#f59e0b" },
		vehicle_impounded: { icon: "local_parking",  color: "#ef4444" },
		vehicle_impound_fee_paid: { icon: "payments", color: "#10b981" },
		vehicle_released:  { icon: "directions_car", color: "#10b981" },
		fine_processed:  { icon: "payments",     color: "#f59e0b" },
		charge_updated:  { icon: "gavel",        color: "#f59e0b" },
		arrest_logged:   { icon: "front_hand",   color: "#ef4444" },
		sent_to_jail:    { icon: "lock",         color: "#ef4444" },
		search_citizens: { icon: "person_search",color: "#6b7280" },
		search_players:  { icon: "manage_search",color: "#6b7280" },
		search_officers: { icon: "badge",        color: "#6b7280" },
		callsign_changed:      { icon: "badge",       color: "#3b82f6" },
		signal100_activated:   { icon: "crisis_alert", color: "#ef4444" },
		signal100_deactivated: { icon: "crisis_alert", color: "#6b7280" },
		camera_viewed:  { icon: "videocam",      color: "#6b7280" },
		bodycam_viewed: { icon: "camera_alt",    color: "#6b7280" },
		// Patrols
		patrol_created:          { icon: "groups",         color: "#38bdf8" },
		patrol_deleted:          { icon: "group_remove",   color: "#ef4444" },
		patrol_renamed:          { icon: "edit",           color: "#f59e0b" },
		patrol_zone_created:     { icon: "draw",           color: "#10b981" },
		patrol_zone_updated:     { icon: "draw",           color: "#f59e0b" },
		patrol_zone_cleared:     { icon: "clear",          color: "#ef4444" },
		patrol_officer_assigned: { icon: "person_add",     color: "#10b981" },
		patrol_officer_removed:  { icon: "person_remove",  color: "#ef4444" },
		patrols_reordered:       { icon: "swap_vert",      color: "#6b7280" },
		dispatch_create:         { icon: "add_alert",      color: "#10b981" },
		dispatch_dismiss:        { icon: "notifications_off", color: "#ef4444" },
		dispatch_note_add:       { icon: "note_add",       color: "#10b981" },
		dispatch_note_edit:      { icon: "edit_note",      color: "#f59e0b" },
		dispatch_note_delete:    { icon: "note_alt",       color: "#ef4444" },
		dispatch_attach_units:   { icon: "person_add",     color: "#10b981" },
		dispatch_detach_units:   { icon: "person_remove",  color: "#ef4444" },
	};

	let activities: AuditLog[] = $state([]);
	let isLoading    = $state(false);
	let searchQuery  = $state("");
	let currentPage  = $state(1);
	let totalItems   = $state(0);
	let perPage      = $state(25);
	let searchTimeout: ReturnType<typeof setTimeout> | null = null;

	let totalPages = $derived(Math.max(1, Math.ceil(totalItems / perPage)));

	function getActionLabel(action: string): string {
		return ACTION_LABELS[action] ?? action.replace(/_/g, " ");
	}

	function getActionIcon(action: string): { icon: string; color: string } {
		return ACTION_ICONS[action] ?? { icon: "info", color: "rgba(59, 130, 246, 0.6)" };
	}

	// Parse details JSON and extract the most useful human-readable string.
	function getDetailLine(log: AuditLog): string {
		if (!log.details) return "";
		let d: Record<string, unknown>;
		try { d = JSON.parse(log.details); } catch { return ""; }

		// Prefer the pre-built readable label from the server
		if (typeof d.action_label === "string") return d.action_label;

		// Patrol-specific fallbacks
		if (log.action === "patrol_renamed") {
			if (d.patrol_old_name && d.patrol_new_name)
				return `"${d.patrol_old_name}" → "${d.patrol_new_name}"`;
		}
		if (log.action === "patrol_officer_assigned") {
			if (d.assigned_name && d.patrol_name)
				return `${d.assigned_name} → ${d.patrol_name}`;
		}
		if (log.action === "patrol_officer_removed") {
			if (d.removed_from) return `Removed from "${d.removed_from}"`;
		}
		if (log.action === "patrol_zone_created" || log.action === "patrol_zone_updated") {
			if (d.patrol_name && d.point_count) return `${d.patrol_name} · ${d.point_count} pts`;
		}
		if (log.action === "patrol_zone_cleared") {
			if (d.patrol_name) return `${d.patrol_name}`;
		}
		if (log.action === "patrols_reordered") {
			if (typeof d.new_order === "string") return d.new_order;
		}
		if (log.action === "patrol_created") {
			if (d.patrol_name) return String(d.patrol_name);
		}
		if (log.action === "patrol_deleted") {
			if (d.patrol_name) return String(d.patrol_name);
		}
		return "";
	}

	function getEntityLabel(log: AuditLog): string {
		if (!log.entity_id) return "";
		const typeLabels: Record<string, string> = {
			profile:         "Profile",
			report:          "Report",
			warrant:         "Warrant",
			case:            "Case",
			evidence:        "Evidence",
			vehicle:         "Vehicle",
			weapon:          "Weapon",
			citizen:         "Citizen",
			search:          "",
			dispatch:        "Channel",
			fine:            "Fine",
			charge:          "Charge",
			arrest:          "Arrest",
			icu:             "ICU",
			case_attachment: "Attachment",
			evidence_image:  "Image",
			officer:         "Officer",
			mdt_patrol:      "Patrol",
		};
		const label = typeLabels[log.entity_type] ?? log.entity_type;
		// For patrol actions entity_id is the UUID or 'order' – skip the #prefix for UUIDs
		if (log.entity_type === "mdt_patrol") {
			return label;
		}
		// Dispatch calls: the readable action_label already names the call, so the
		// raw call id ("mdt-…" / a provider number) would just be noise here.
		if (log.entity_type === "dispatch") {
			return "";
		}
		return label ? `${label} #${log.entity_id}` : `#${log.entity_id}`;
	}

	function formatTimestamp(value: string): string {
		return formatRelative(value);
	}

	function formatFullTimestamp(value: string): string {
		return formatDateTime(value, value);
	}

	// Compact absolute stamp shown next to the relative time, e.g. "10-07-2026 | 15:34".
	function formatExactTimestamp(value: string): string {
		const d = toDate(value);
		if (!d) return "";
		return `${formatDate(d)} | ${formatTime(d)}`;
	}

	async function loadActivity(page = 1) {
		if (isEnvBrowser()) return;
		try {
			isLoading = true;
			const response = await fetchNui<PaginatedResponse>(
				NUI_EVENTS.AUDIT.GET_AUDIT_LOGS,
				{ limit: perPage, page, search: searchQuery.trim() || undefined },
				{ items: [], total: 0, page: 1, perPage: 25 },
			);
			if (response && response.items) {
				activities   = response.items;
				totalItems   = response.total || 0;
				currentPage  = response.page  || page;
			} else if (Array.isArray(response)) {
				activities  = response as unknown as AuditLog[];
				totalItems  = activities.length;
				currentPage = 1;
			} else {
				activities = [];
				totalItems = 0;
			}
		} catch (error) {
			console.error("Failed to load activity:", error);
			activities = [];
			totalItems = 0;
		} finally {
			isLoading = false;
		}
	}

	function handleSearch(e: Event) {
		const value = (e.target as HTMLInputElement).value;
		searchQuery = value;
		if (searchTimeout) clearTimeout(searchTimeout);
		searchTimeout = setTimeout(() => { currentPage = 1; loadActivity(1); }, 400);
	}

	onMount(() => {
		if (isEnvBrowser()) {
			activities = [
				{ id: 1, actor_name: "D2020 Sgt. J. Miller",  action: "patrol_created",          entity_type: "mdt_patrol", entity_id: "alpha-1", details: JSON.stringify({ patrol_name: "Alpha-1", patrol_color: "#38bdf8", action_label: 'Created patrol "Alpha-1"' }), created_at: new Date(Date.now() - 60000).toISOString() },
				{ id: 2, actor_name: "D2020 Det. R. Santos",   action: "patrol_officer_assigned",  entity_type: "mdt_patrol", entity_id: "alpha-1", details: JSON.stringify({ patrol_name: "Alpha-1", assigned_name: "J. Miller", action_label: 'Assigned J. Miller to patrol "Alpha-1"' }), created_at: new Date(Date.now() - 300000).toISOString() },
				{ id: 3, actor_name: "D2020 Ofc. K. Chen",     action: "patrol_zone_created",      entity_type: "mdt_patrol", entity_id: "alpha-1", details: JSON.stringify({ patrol_name: "Alpha-1", point_count: 6, action_label: 'Drew zone for patrol "Alpha-1" (6 points)' }), created_at: new Date(Date.now() - 3600000).toISOString() },
				{ id: 4, actor_name: "D2020 Lt. A. Brooks",    action: "patrol_renamed",           entity_type: "mdt_patrol", entity_id: "alpha-1", details: JSON.stringify({ patrol_old_name: "Alpha", patrol_new_name: "Alpha-1", action_label: 'Renamed patrol "Alpha" → "Alpha-1"' }), created_at: new Date(Date.now() - 7200000).toISOString() },
				{ id: 5, actor_name: "D2020 Ofc. M. Torres",   action: "report_created",           entity_type: "report",     entity_id: "RPT-042", details: null, created_at: new Date(Date.now() - 86400000).toISOString() },
			];
			totalItems = 5;
			return;
		}
		loadActivity(1);
	});
</script>

<div class="activity-panel">
	<div class="activity-topbar">
		<input
			type="text"
			placeholder={t("management.activity.searchPlaceholder")}
			value={searchQuery}
			oninput={handleSearch}
			class="search-input"
		/>
		<span class="result-count">{totalItems} {t("management.activity.entries")}</span>
	</div>

	{#if isLoading}
		<div class="empty-state">
			<div class="loading-spinner"></div>
			<p>{t("common.status.loading")}</p>
		</div>
	{:else}
		<div class="activity-list">
			{#each activities as log (log.id)}
				{@const iconData   = getActionIcon(log.action)}
				{@const detailLine = getDetailLine(log)}
				{@const entityLabel= getEntityLabel(log)}
				<div class="activity-row">
					<div class="activity-icon" style="background:{iconData.color}18;color:{iconData.color}">
						<span class="material-icons">{iconData.icon}</span>
					</div>
					<div class="activity-body">
						<div class="activity-top-row">
							<span class="activity-action">{getActionLabel(log.action)}</span>
							{#if entityLabel}
								<span class="activity-entity">{entityLabel}</span>
							{/if}
						</div>
						{#if detailLine}
							<span class="activity-detail">{detailLine}</span>
						{/if}
					</div>
					<div class="activity-meta">
						<span class="activity-officer">{log.actor_name || t("management.activity.unknown")}</span>
						<span class="activity-time" title={formatFullTimestamp(log.created_at)}>
							{formatTimestamp(log.created_at)}<span class="time-sep">●</span><span class="time-exact">{formatExactTimestamp(log.created_at)}</span>
						</span>
					</div>
				</div>
			{:else}
				<div class="empty-state">
					{searchQuery ? t("management.activity.noResults") : t("management.activity.noActivity")}
				</div>
			{/each}
		</div>

		<Pagination
			currentPage={currentPage}
			totalItems={totalItems}
			perPage={perPage}
			onPageChange={(p) => loadActivity(p)}
			onPerPageChange={(pp) => { perPage = pp; loadActivity(1); }}
		/>
	{/if}
</div>

<style>
	.activity-panel {
		display: flex;
		flex-direction: column;
		height: 100%;
		background: transparent;
		overflow: hidden;
	}

	.activity-topbar {
		display: flex;
		align-items: center;
		gap: 10px;
		padding: 0 16px;
		height: 36px;
		border-bottom: 1px solid rgba(255, 255, 255, 0.06);
		flex-shrink: 0;
	}

	.search-input {
		flex: 1;
		max-width: 360px;
		background: transparent;
		border: none;
		padding: 0;
		color: rgba(255, 255, 255, 0.8);
		font-size: 11px;
	}
	.search-input:focus { outline: none; }
	.search-input::placeholder { color: rgba(255, 255, 255, 0.2); }

	.result-count {
		color: rgba(255, 255, 255, 0.2);
		font-size: 10px;
		margin-left: auto;
	}

	.activity-list {
		flex: 1;
		min-height: 0;
		overflow-y: auto;
	}
	.activity-list::-webkit-scrollbar       { width: 4px; }
	.activity-list::-webkit-scrollbar-track { background: transparent; }
	.activity-list::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.06); border-radius: 2px; }

	.activity-row {
		display: flex;
		align-items: center;
		gap: 10px;
		padding: 7px 16px;
		border-bottom: 1px solid rgba(255, 255, 255, 0.03);
		transition: background 0.1s;
	}
	.activity-row:hover       { background: rgba(255, 255, 255, 0.02); }
	.activity-row:last-child  { border-bottom: none; }

	.activity-icon {
		width: 28px;
		height: 28px;
		min-width: 28px;
		border-radius: 5px;
		display: flex;
		align-items: center;
		justify-content: center;
	}
	.activity-icon .material-icons { font-size: 14px; }

	.activity-body {
		display: flex;
		flex-direction: column;
		gap: 2px;
		flex: 1;
		min-width: 0;
	}

	.activity-top-row {
		display: flex;
		align-items: center;
		gap: 6px;
	}

	.activity-action {
		color: rgba(255, 255, 255, 0.8);
		font-size: 11px;
		font-weight: 500;
	}

	.activity-entity {
		font-size: 10px;
		color: rgba(var(--accent-text-rgb), 0.7);
		font-weight: 500;
		background: rgba(var(--accent-rgb), 0.08);
		padding: 1px 5px;
		border-radius: 3px;
	}

	.activity-detail {
		font-size: 10px;
		color: rgba(255, 255, 255, 0.3);
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.activity-meta {
		display: flex;
		flex-direction: column;
		align-items: flex-end;
		gap: 1px;
		flex-shrink: 0;
	}
	.activity-officer {
		color: rgba(255, 255, 255, 0.35);
		font-size: 10px;
		white-space: nowrap;
	}
	.activity-time {
		color: rgba(255, 255, 255, 0.4);
		font-size: 10px;
		white-space: nowrap;
		display: inline-flex;
		align-items: center;
	}
	.time-sep {
		margin: 0 5px;
		font-size: 6px;
		color: rgba(255, 255, 255, 0.2);
		vertical-align: middle;
	}
	.time-exact {
		color: rgba(255, 255, 255, 0.25);
		font-variant-numeric: tabular-nums;
	}

	.empty-state {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		min-height: 200px;
		color: rgba(255, 255, 255, 0.35);
		font-size: 11px;
	}

	.loading-spinner {
		width: 24px;
		height: 24px;
		border: 2px solid rgba(255, 255, 255, 0.06);
		border-left: 2px solid rgba(var(--accent-rgb), 0.5);
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
		margin-bottom: 10px;
	}

	@keyframes spin {
		0%   { transform: rotate(0deg); }
		100% { transform: rotate(360deg); }
	}
</style>
