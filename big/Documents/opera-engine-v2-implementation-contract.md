# Opera-Engine v2: authoritative specification and implementation contract

Version: 2.0 • Date: 2026-10-06 • Owner: Michael Andersen

Status: Design baseline for implementation. Not a claim that software exists, has passed tests, or is suitable for regulated or safety-critical deployment.

## 0. Start here

This document replaces the implementation instructions in the supplied Gemini conversation, `Pasted text(20261006-055703).txt`. The conversation remains background and a record of the product idea. Its code snippets, performance claims, dependency APIs, deployment commands, security claims, and statements that Release 1 is frozen are not authoritative.

The purpose is to let a coding model implement the system without having to rediscover its architecture or invent missing operational rules. This is one self-contained master contract. Sections can later become separate files, but must not be independently rewritten into conflicting specifications.

**Product:** A locally hosted application that helps an organization turn source material into reviewed procedures, execute a particular approved revision, record what happened, and propose improvements from operational feedback.

**First deliverable:** A working connected pilot of that complete workflow. Offline execution follows as a separately gated release. Neither release automatically claims regulatory compliance, physical presence verification, machine safety control, or legal non-repudiation.

### 0.1 How to read this document

| Reader/task | Required reading |
|---|---|
| Owner reviewing direction | Sections 1–4, 17–19 |
| Coding model starting work | Sections 0–5, then its work package in section 17 |
| Domain/database work | Sections 5–8 and 12 |
| UI/API work | Sections 6–10 and 14 |
| Offline work | Sections 6–10, 12 and all of section 11 |
| AI workflow work | Sections 5, 7, 13 |
| Release verification | Sections 15–18 |

### 0.2 Interpretation rules

1. MUST and MUST NOT are acceptance requirements. SHOULD is a preferred implementation that can be varied with a recorded reason.
2. Explicit owner instructions override this baseline. Within this baseline, state-transition rules and invariants take precedence over examples and presentation suggestions.
3. The absence of an implementation is not permission to replace a requirement with a stub. Mark unfinished work as unfinished.
4. Do not copy old illustrative code into production merely because it appears in the earlier conversation.
5. Do not add requirements from marketing promises. Marketing must reflect verified behavior.
6. Existing useful code must be inspected and retained where it satisfies this contract. Do not restart a functioning repository solely to obtain the folder layout shown here.
7. This document makes explicit design decisions. Dependency compatibility and measured performance still require implementation evidence.

## 1. What stays, changes, and is deferred

| Original approach | v2 decision | Concrete instruction |
|---|---|---|
| Local/on-premise product | KEEP | Production runtime must not require internet services. |
| Go application | KEEP | Go owns domain rules, authorization, persistence commands, jobs and rendering. |
| Templ + HTMX + Alpine.js | KEEP | Connected pages use server rendering; Alpine handles small local interactions. |
| Tailwind + DaisyUI | KEEP | Pin compatible versions; measure rendered accessibility. |
| SurrealDB | KEEP, VERIFY | Use a separately managed local server. Prove transactions and concurrency with the pinned engine/SDK/storage combination. |
| PocketFlow Go | KEEP, VERIFY | Use the user's `github.com/lalolv/PocketFlowGo`; compile against actual exported APIs. Do not silently substitute another PocketFlow project. |
| Local inference | KEEP | An adapter supports one verified provider first; another provider must pass the same contract before being advertised. |
| English first | KEEP | English UI/content; stable message IDs and locale fields now; translation later. |
| User-to-SOP execution edge | REPLACE | Add execution runs, immutable events, attempts and evidence. |
| Mutable SOP with version string | REPLACE | Separate procedure identity from approved revision content and lifecycle events. |
| Failed HTTP request replay | REPLACE | Explicit typed domain commands, idempotency, receipts and conflict resolution. |
| QR proves presence/work | REMOVE CLAIM | QR identifies an asset or reference; it is not proof that work occurred. |
| HMAC means immutable/non-repudiable | REPLACE | A tamper-evident, transactionally appended audit chain with stated trust limits. |
| Automatic self-healing SOP | REPLACE | Feedback creates a proposal; a qualified human approves publication. |
| Exactly three discovery questions | CHANGE | Up to three per round; repeat while material gaps remain. |
| LLM writes authoritative diagrams | CHANGE | Code derives diagrams from validated procedure structure. |
| Custom role map is sufficient | CHANGE | Central policy checks role, scope, assignment, qualification and resource state. |
| Every file has a manifest | SIMPLIFY | Requirements map to behavior and tests; exclude generated/vendor files from annotation rules. |
| Fixed 15-second/60-second claims | REMOVE AS PROMISES | Measure defined workloads and report model/hardware/input/output sizes. |
| Mac-only single-binary appliance | CLARIFY | Application binary plus database, inference, local assets and service configuration. |
| Full offline operation in first wave | STAGE | R1A connected pilot; R1B restricted offline continuation. |
| Enterprise integrations/compliance/multi-site | DEFER | Explicit future work, not hidden R1 obligations. |

## 2. Release scope and non-goals

### 2.1 R1A: connected operational pilot

R1A means client devices can reach the local appliance. Internet access is unnecessary. Required features:

- One organization and one site per installation, with departments and scoped users.
- Named-user sign-in, explicit device enrollment and shared-device locking.
- Asset registry with printable opaque QR identifiers.
- Text entry/import and extraction from text-bearing PDFs. Scanned PDFs produce an explicit OCR-required outcome; OCR and raw-audio transcription are deferred.
- Draft editor, source references, discovery rounds, local AI proposal generation and review.
- Linear, ordered procedures with explicit required evidence. Conditional branching, loops and parallel work within one run are deferred.
- Approval and publication, withdrawal, supersession and history export.
- Execution runs tied to an asset and one approved revision, with one assigned operator at a time.
- Completion, exception reporting, blocking, resolution, handoff, cancellation and completion summary.
- Supervisor dashboard and persistent alarms, updated through SSE and recoverable by snapshot refresh.
- Audit chain, backup/restore, controlled updates and documented recovery.
- Honest status displays and acceptance tests in section 18.

Use a non-safety-critical pilot procedure, for example receiving inspection or a routine visual inventory check. P1 blocking semantics may be tested with simulated data, but successful software tests do not validate a hazardous operating procedure.

### 2.2 R1B: restricted offline continuation

Only add after R1A passes its gates. R1B allows an already signed-in operator on an enrolled device to continue an already started and explicitly downloaded run, within a short-lived grant. Only P3/P4 steps explicitly approved as offline-eligible may be completed offline.

No offline start of a new run, sign-in, account switching, publication, handoff, override, P1/P2 completion, or supervisor resolution. A lock or expired grant ends offline execution; reconnect to unlock. Locally recording an issue remains possible while the operator session is still usable. A locally reported blocking issue immediately blocks further local completion.

These restrictions are intentional product boundaries. Removing them requires a separate design decision and new tests; the coding model must not quietly implement a broader promise.

### 2.3 Deferred beyond R1

Multi-site synchronization; cross-site transactions; ERP/CMMS connectors; SAML/OIDC; NFC/RFID hardware integration; offline user switching; multiple simultaneous operators per run; controlled numerical measurement forms; branching procedures; translated operational content; automatic OCR/transcription; WebGPU sales sandbox; training/courseware; regulatory validation packages; certified electronic signatures; licensing enforcement; automatic model downloads.

One installation can have many users and devices. Do not implement artificial seat restrictions. Commercial packaging is outside the execution engine and must never lock away historical records or interrupt an active procedure.

## 3. Architecture and authority boundaries

### 3.1 Components

| Component | Responsibility | Must not do |
|---|---|---|
| Go domain/service layer | Validate commands, transitions and authorization | Trust browser flags or generated AI text as authority |
| SurrealDB repository | Atomic persistence, uniqueness and version checks | Expose privileged database credentials to clients |
| HTTP/Templ layer | Pages, forms, JSON contracts, session/CSRF enforcement | Implement a second independent set of business rules |
| Execution client | Render run snapshot, capture typed commands, show sync status | Decide that a server-rejected action is accepted |
| Local AI worker | Draft proposals and identify gaps | Publish, alter approved content, grant access or resolve exceptions |
| SSE/outbox worker | Notify authorized clients about committed changes | Act as the only storage for an alarm |
| Audit verifier | Verify chain and export integrity evidence | Claim a shared-key record proves an individual's intent |

All mutations use application service commands. Both HTML form handlers and JSON endpoints invoke the same service layer. R1A executes in that layer; R1B contains a conservative client-side preview of permitted actions, with server reconciliation still authoritative.

### 3.2 Deployment topology

The appliance has three managed services: Go application, SurrealDB, and the chosen local inference runtime. Serve all production CSS, JS, fonts, icons and model resources locally. No CDN dependencies or analytics beacons.

Database and inference interfaces bind to loopback by default. Only the application HTTPS interface is exposed to the site network. Local TLS certificates must be trusted on the actual client devices. Browser camera/service-worker behavior must be tested on that hostname and certificate setup, not only on localhost.

Use `launchd` for macOS and `systemd` for a Linux target. Supply only service files for targets actually tested. A Mac build is not proof of a working Mac installer. A developer run target builds for the host; cross-compilation is a separate target.

### 3.3 Stack verification gate

Before feature development, record exact versions/commits and demonstrate:

1. Go/Templ/CSS compilation from a locked dependency set.
2. The actual `lalolv/PocketFlowGo` module path and API using a two-node, no-LLM executable test. If upstream moved, document the mapping and inspect the module declaration before choosing a compatible pin.
3. SurrealDB transaction rollback, concurrent update rejection, deterministic event identity and uniqueness under concurrent requests, on the selected persistent storage engine.
4. A local model request with timeout/cancellation, valid and malformed response handling.
5. A real client camera session through trusted local HTTPS.

Record results in `docs/DEPENDENCIES.md`. Do not invent version numbers in advance. Do not use `@latest`, global npm dependencies or an unpinned production model. If a core dependency fails its gate, record a blocked decision and a concrete alternative; do not silently change databases or relax transaction guarantees.

## 4. User journeys and screens

### 4.1 Main journey

An author imports source text, identifies its origin and creates a draft. The system asks targeted questions, records answers and produces a proposed procedure. The author edits it and requests review. A different authorized reviewer approves the exact content hash. Publication makes it available for new runs. An assigned operator scans an asset, starts the appropriate revision, and follows steps. If a problem occurs, the operator reports it. A supervisor acknowledges and separately resolves the issue; the operator resumes when allowed. Completed history is exportable. Feedback may create a new draft without changing the old run.

### 4.2 Screens

| Screen | Required content/actions |
|---|---|
| Sign-in/lock | Named identity, credential entry, lock state, online requirement for unlock |
| Operator home | Assigned runs, eligible procedures, scan asset, connection status |
| Procedure list/detail | Identity, revision, lifecycle state, approved date, source and history |
| Draft studio | Sources, editable steps, gaps, proposal diff, job status, submit for review |
| Review | Exact content and hash, unresolved gaps, change diff, approve/reject with reason |
| Execution | Asset, revision, operator, current step, evidence, accepted/pending state, report issue |
| Supervisor dashboard | Persistent alarms, acknowledgment state, blocked runs, assigned scope |
| Exception detail | Original report, evidence, acknowledgment, disposition, permitted resume |
| Run history | Events, attempts, actors, revisions, receipt times, issues and export |
| Administration | Users, roles, departments, assets, device enrollment, backup/service health |
| R1B sync center | Pending/accepted/quarantined/rejected events and recovery actions |

Empty states must explain the next action. Failure states must preserve entered work where possible. No production route may contain a simulated camera match, fake alarm, fabricated history or successful placeholder response. Demo data is isolated and visibly labeled.

## 5. Domain model and invariants

### 5.1 Conventions

Use opaque immutable application IDs generated with a standard UUID implementation. Human procedure codes are separate from IDs. Store UTC server timestamps and display the configured site timezone; preserve user-reported times as untrusted metadata. Use integer versions for optimistic concurrency. The server assigns event order, not device clocks.

Every site-owned record includes `organization_id` and `site_id`; department-scoped records also identify their department. R1 has one site but the scope is explicit. The server derives these fields from the authenticated context/resource; it does not trust client-supplied scope.

### 5.2 Required entities

| Entity | Minimum fields and purpose |
|---|---|
| Organization/Site/Department | Identity, name, site timezone; explicit scope |
| User | Identity, active flag, display name, scoped role assignments, authentication reference |
| Qualification | User, qualification code, issuer/reviewer, valid-from/to, revocation; append history |
| Device | Identity, enrollment state, credential reference, last contact, revoked-at |
| Asset | Identity, site/department, label, QR token, active flag |
| Procedure | Identity, unique site/code, owner department, title, current revision pointer |
| ProcedureRevision | ID, procedure ID, revision number, content schema version, content hash, content JSON, author, timestamps, row version |
| RevisionLifecycleEvent | Revision, action, actor, server time, reason; review/publication/withdrawal history |
| Approval | Revision ID/hash, reviewer, decision, meaning, reason, time |
| SourceDocument | ID, original name/type, content hash, immutable stored bytes/text, uploader, page/paragraph locators |
| DiscoverySession | Draft ID, rounds, questions, answers, unresolved gaps, status |
| AIJob | Inputs/hashes, stage, status, checkpoint, provider/model/prompt versions, attempts, lease, errors |
| ExecutionRun | ID, revision ID/hash, asset, operator, device ownership, state, version, start/end, assignment generation |
| StepAttempt | ID, run, stable step ID, attempt number, status, evidence refs; derived from accepted events |
| ExecutionEvent | Immutable event ID, command type, run, actor/device, step/attempt, payload, receipt sequence/time |
| Evidence | ID, run/step/attempt, type, actor, immutable value or blob hash, capture/receipt times |
| Exception | ID, run/step, severity/type, report, state, associated event, version |
| ExceptionDisposition | Exception, supervisor, decision/reason, required corrective action, time |
| CommandReceipt | Scope/event ID, canonical request digest, decision, resulting versions/event IDs, stable response |
| AuditEntry | Sequence, previous hash, canonical entry bytes, digest, HMAC/key ID, server time |
| OutboxEntry | Durable notification ID, resource/scope reference, event type, delivery state |
| OfflineGrant (R1B) | Grant/device/user/run IDs, revision hash, assignment generation, validity, permitted steps/actions, signature |

Implement relational/document facts first. Optional graph projections may be derived for navigation; they must not be the only source of execution history.

### 5.3 Procedure content contract

Content includes title, purpose, applicability, prerequisites, ordered steps, source references and a change summary. Each step includes a stable `step_id`, position, title, instruction, priority enum, required qualification codes, evidence requirements, source references and `offline_eligible` (default false).

R1 evidence types are `ATTESTATION`, `ASSET_QR` and `TEXT_NOTE`. A step may require more than one. An attestation is an explicit operator statement, not sensor proof. QR evidence records the decoded opaque asset token and its server match. Reject unknown evidence types; do not silently skip required evidence. Photo and measured-value evidence require a later contract.

Priority values: `P1_CRITICAL`, `P2_HIGH`, `P3_STANDARD`, `P4_LOW`. Priority is not itself a complete hazard assessment. P1/P2 are always online-only in R1B. Offline eligibility of P3/P4 is approved as part of the revision; authors and AI cannot toggle it after publication.

Published steps have unique IDs and contiguous positions. R1 has no step skipping or branching. A procedure requiring alternatives must be split into separate procedures before publication. Optional diagrams must reflect this actual structure rather than invent decision branches.

### 5.4 Hard invariants

- INV-01: Content approved or published for execution is never edited in place. A change creates a new revision.
- INV-02: Every run references one revision ID and content hash for its lifetime.
- INV-03: Every accepted execution command has exactly one durable receipt and its state, event, audit and outbox writes are atomic.
- INV-04: Duplicate commands cannot repeat a domain effect. Reusing an ID with different semantic content is rejected.
- INV-05: Server authorization is applied to every command, including direct HTTP calls and replay.
- INV-06: Only one operator/device assignment controls a run at a time; handoff is an explicit online event.
- INV-07: A run cannot advance past an unresolved blocking exception or an incomplete required earlier step.
- INV-08: Administrators receive no automatic operational execution or approval authority.
- INV-09: Client time, a QR scan, an AI output, or a disabled button never substitutes for domain validation.
- INV-10: History is append-only through application interfaces. Corrections link to the original event and preserve it.
- INV-11: SSE loss cannot lose an alarm or committed result.
- INV-12: Missing source facts remain visible gaps; generated guesses cannot silently become approved technical limits.

## 6. State transitions

### 6.1 Revision lifecycle

| From | Action | To | Guard/effect |
|---|---|---|---|
| DRAFT | Edit | DRAFT | Author scope; expected version matches; invalidate previous review material |
| DRAFT | Submit | IN_REVIEW | Schema valid; blocking gaps answered; record submitted hash |
| IN_REVIEW | Reject | DRAFT | Reviewer reason required |
| IN_REVIEW | Approve | APPROVED | Different qualified reviewer; exact submitted hash; no open blocking gaps |
| APPROVED | Publish | PUBLISHED | Supervisor in scope; hash matches approval; transaction updates current pointer |
| APPROVED | Revise | New DRAFT | Copy content into new revision; keep approval history |
| PUBLISHED | Publish successor | SUPERSEDED | New runs use successor; existing runs remain pinned |
| PUBLISHED/SUPERSEDED | Withdraw | WITHDRAWN | Reason required; block active affected runs and revoke grants |

Drafts in review must first be returned to DRAFT before editing. R1 requires a different human reviewer; no hidden self-approval exception for single-user installations. Seed a second real reviewer for pilot use. APPROVED is not executable until PUBLISHED.

Lifecycle state may be a mutable projection, but approved content and lifecycle events remain immutable. Historical revisions remain readable. Withdrawing a revision cannot instantly reach a disconnected device; R1B reconciliation addresses that limitation explicitly.

### 6.2 Run lifecycle

States: `IN_PROGRESS`, `BLOCKED`, `COMPLETED`, `CANCELLED`. Start creates an IN_PROGRESS run. No draft execution runs.

- Start: online only; published current revision, active asset, eligible operator, valid assignment and enrolled device.
- Complete step: IN_PROGRESS; assigned actor/device, current step, all evidence and qualifications satisfied. Final step completion moves run to COMPLETED in the same transaction.
- Blocking exception: IN_PROGRESS becomes BLOCKED. P1/P2 exceptions always block; P3/P4 block when the operator selects stop-work. Uncertainty may always be reported as stop-work.
- Resolve exception: supervisor disposition closes that exception. Run resumes only if no other blocker remains and the revision remains executable for existing runs. Withdrawal cannot be overridden by closing an exception.
- Handoff: online only, no pending device commands, both users identified, receiving user eligible, reason recorded. Increment assignment generation and revoke old grant; preserve run state and history.
- Cancel: supervisor, reason required; terminal. No silently deleting an interrupted run.
- COMPLETED/CANCELLED: no new completion events. Corrections or late reports are appended without reopening history.

A normal supersession does not invalidate an existing run. Withdrawal does. A withdrawn run is cancelled or investigated; starting a replacement run requires a new run ID and link to the prior run. Do not migrate its completed steps automatically.

At start, the assigned operator must hold every qualification required by the revision; each completion rechecks that step's qualifications. A supervisor resolving a blocked step must hold the qualifications required for that step as well as the scoped Supervisor grant. Nonblocking P3/P4 issues may remain open after run completion, but must be listed in its completion summary. Any unresolved blocking issue prevents completion.

### 6.3 Attempts and exceptions

An attempt can be OPEN, PASSED or FAILED. A failed attempt remains visible. After authorized resolution, retry creates a new attempt number; it never overwrites the failed attempt. A successfully passed step cannot be repeated inside R1; a rework procedure is a separate linked run.

Exception state: OPEN → ACKNOWLEDGED → RESOLVED. Resolution may also follow OPEN directly if acknowledgment and resolution are separately recorded within the same command. Acknowledgment means somebody has taken notice; it never authorizes continuation. Resolution requires a reason and either retry permission or cancellation. There is no “skip critical step” action.

## 7. Authorization and authentication

### 7.1 Roles are scoped grants

Users may have multiple explicit role grants. Administrative identity management is distinct from operational competence.

| Action | Operator | Author | Supervisor | Administrator |
|---|---|---|---|---|
| Read assigned/published procedures | Assigned/scope | Author scope | Supervisor scope | Metadata/admin scope only unless separately granted |
| Execute | Assigned + qualified | No inherent permission | Only with Operator grant + qualification | Only with Operator grant + qualification |
| Create/edit drafts | No | Within scope | Within scope | No inherent permission |
| Review/approve/publish | No | No | Within scope, not own authored revision | No inherent permission |
| Report exception | Assigned run | No | Within operational scope | No inherent permission |
| Acknowledge/resolve/handoff/cancel | No | No | Within scope, appropriate qualification | No inherent permission |
| Manage identities/devices | No | No | No | Yes, audited |
| Audit/export | Own run view | Revision scope | Supervisor scope | Explicit audit-export grant |

Policy function concept: `Authorize(actor, action, resource, currentState) -> allow/deny + reasonCode`. This is a behavioral contract, not a mandatory Go signature. It must check active identity, site/department, role grant, assignment, qualifications and lifecycle constraints as applicable.

Do not use a globally exported mutable role map. A small custom policy package is acceptable for this fixed policy if thoroughly tested; replacing it with a library does not remove the need for these checks. No nanosecond performance claims are requirements.

### 7.2 R1 credentials and sessions

- Named account selection plus password/passphrase is the R1 baseline. Four-digit PIN-only login is removed. Optional badge/PIN flows are future work.
- Use an established password-hashing implementation with per-user salt and versioned parameters; benchmark the chosen configuration on deployment hardware.
- Secure, HttpOnly session cookies; CSRF protection on browser mutations, including JSON; request-origin checks as appropriate. Never put session tokens in localStorage.
- Session maximum 12 hours, idle lock after 5 minutes. Online reauthentication is required after locking in both R1A and R1B.
- Rate-limit failed authentication by account and device/network context; configurable lock/backoff with audited administrative recovery. Do not log credentials.
- Disabled users and revoked devices fail new commands immediately when connected.
- Switching users clears displayed private state and rotates the session. It must not relabel queued events as the new user.
- Administrative enrollment and credential resets are audited. Do not seed production `root/root` or default shared passwords.

## 8. Command processing and persistence

### 8.1 Common mutation envelope

Every state-changing operational request contains a unique `command_id`, supported `schema_version`, action-specific data, and expected resource version where applicable. The authenticated session establishes the online actor. Never accept a client actor ID as proof.

Canonical semantic request content excludes transport credentials and retry timestamps, but includes action, resource, expected version, captured evidence and all values that affect meaning. Compute its digest using one versioned canonical serialization implementation.

### 8.2 Transaction algorithm

1. Authenticate and check that the requester may submit for the scope.
2. Validate body limits, schema version and command shape.
3. Look up the scoped command receipt. Same ID and same digest returns the recorded result, provided the caller may access that receipt. Different digest returns `IDEMPOTENCY_CONFLICT`.
4. Begin a database transaction. Recheck receipt identity within the transaction to handle concurrent retries.
5. Read authoritative state; enforce expected version, authorization and transition guards. Ensure relevant concurrency dependencies are protected by the chosen transaction/update mechanism.
6. Write domain changes, immutable event/evidence references, receipt, audit entry and outbox notification atomically. Increment resource versions.
7. Commit. Only then return accepted or publish notifications.
8. On transaction conflict, retry the whole unit a bounded number of times, preserving command ID; never return success before commit. If exhausted, return retryable error.

Never perform a model call, browser round trip, file download or slow external operation inside this transaction. R1 execution evidence is small structured data; future blob evidence needs a staged upload and orphan cleanup design.

Use deterministic database record identity for receipt/event IDs as well as appropriate unique constraints. Passing one sequential test is insufficient: verify concurrent duplicates against the actual database engine. Mutable projections must be rebuildable from events or reconciled by a defined repair tool.

### 8.3 Required constraints and indexes

- Unique procedure code within site; revision number within procedure.
- Unique command receipt identity within installation; immutable request digest.
- Unique execution event identity; unique `(run_id, server_sequence)`.
- Unique `(run_id, step_id, attempt_number)`.
- One current published revision pointer per procedure.
- Versions/serialization prevent two devices from advancing the same run concurrently.
- Indexed run state, assigned user, asset, revision, and open exceptions by scope.
- Audit sequence unique; a guarded chain-head update serializes concurrent append operations.

The schema migration must enforce supported constraints. Application tests must cover any invariant that cannot be expressed directly in schema. Do not infer transactional enforcement from an ORM method name.

## 9. HTTP and error contract

### 9.1 Endpoint groups

Paths are normative at the resource-group level; do not preserve the old ambiguous SOP-only completion route. All routes under `/api/v1` return JSON. HTML page/form routes are separate and call the same services.

| Endpoint | Purpose |
|---|---|
| POST `/api/v1/sources` | Import validated text/PDF source |
| POST `/api/v1/procedures` | Create procedure identity and draft |
| PATCH `/api/v1/revisions/{id}` | Edit draft with expected version |
| POST `/api/v1/revisions/{id}/submit` | Request review |
| POST `/api/v1/revisions/{id}/reviews` | Approve or reject exact content hash |
| POST `/api/v1/revisions/{id}/publish` | Publish approved revision |
| POST `/api/v1/revisions/{id}/withdraw` | Withdraw and block affected runs |
| POST `/api/v1/jobs` | Start a persisted AI job |
| GET `/api/v1/jobs/{id}` | Job state, stage and result reference |
| POST `/api/v1/discovery/{id}/answers` | Persist answers and resume processing |
| POST `/api/v1/runs` | Start online run |
| GET `/api/v1/runs/{id}` | Authoritative snapshot and version |
| POST `/api/v1/runs/{id}/commands` | Complete step, report issue, handoff or cancel |
| POST `/api/v1/exceptions/{id}/acknowledge` | Record acknowledgment |
| POST `/api/v1/exceptions/{id}/resolve` | Record disposition |
| GET `/api/v1/runs/{id}/export` | Versioned JSON and printable history options |
| GET `/api/v1/events` | Authorized SSE stream |
| POST `/api/v1/runs/{id}/offline-grant` | R1B only: issue restricted download/grant |
| POST `/api/v1/sync/events` | R1B only: per-event reconciliation |

Each implementation must add request/response schemas with required fields, limits and error codes to an API contract file before its handler is declared complete. Unsupported fields are rejected where ignoring them would change meaning.

### 9.2 Errors

Stable body: `code`, safe `message`, `retryable`, `correlation_id`, and optional `current_version`/field errors. Statuses: 400 malformed input, 401 sign-in required, 403 disallowed action, 404 absent or concealed out-of-scope resource, 409 version/state/idempotency conflict, 422 valid shape but invalid domain data, 429 rate limit, 503 unavailable dependency.

Required domain codes include `VERSION_CONFLICT`, `IDEMPOTENCY_CONFLICT`, `REVISION_WITHDRAWN`, `RUN_BLOCKED`, `STEP_OUT_OF_ORDER`, `EVIDENCE_REQUIRED`, `QUALIFICATION_REQUIRED`, `DEVICE_REVOKED`, `GRANT_EXPIRED`, `ASSIGNMENT_CHANGED`, `DEPENDENCY_UNRESOLVED` and `UNSUPPORTED_SCHEMA`.

AI job submission returns 202 and job ID after durable creation. It does not hold an HTTP request open until inference finishes. Error pages and HTMX fragments must preserve form data and show actionable messages without leaking database credentials or stack traces.

### 9.3 Execution command shapes

Use a discriminated action enum, not free-form verbs. R1A run commands have this envelope; the identifiers below are illustrative values, not seed data:

```json
{
  "schema_version": 1,
  "command_id": "<uuid>",
  "expected_run_version": 7,
  "action": "COMPLETE_STEP",
  "payload": {
    "step_id": "<stable-step-id>",
    "attempt_id": "<server-issued-attempt-id>",
    "evidence": [
      {"type": "ATTESTATION", "confirmed": true},
      {"type": "ASSET_QR", "asset_token": "<scanned-opaque-token>"}
    ]
  }
}
```

The server issues the first OPEN attempt when starting a run, the next step's attempt on accepted completion, and a retry attempt on authorized resolution. Run snapshots expose the current attempt. For an offline continuation, reserve attempt IDs for the permitted future steps when issuing the download, bound to that grant; they become real OPEN attempts only as predecessors are accepted. Unused reservations have no execution effect. Offline retries after failed attempts are not supported.

| Action | Required payload fields | Authority |
|---|---|---|
| COMPLETE_STEP | step_id, attempt_id, evidence array | Assigned Operator/device |
| REPORT_EXCEPTION | step_id, attempt_id, priority, type, comment, stop_work | Assigned Operator/device or scoped qualified Supervisor |
| HANDOFF | receiving_user_id, receiving_device_id, reason, receiver_acceptance_id | Supervisor; receiving user explicitly accepts online |
| CANCEL_RUN | reason | Supervisor |

Exception types in R1: MISSING_PART, UNCLEAR_DIRECTION, SAFETY_HAZARD, MACHINE_DEFECT, OTHER. OTHER requires a descriptive comment. A report cannot be lowered from P1/P2 to a nonblocking state by setting stop_work=false. Record failure of the current attempt when a blocking exception interrupts it; resolving for retry creates a new attempt. A report after a terminal run is supplemental history and never changes its accepted completion retrospectively.

Receiver acceptance is a short-lived, server-recorded action authenticated as the receiving user and bound to run, current version and receiving device. Handoff fails if any binding changed or the source device has a live offline grant. Before handoff, the source device synchronizes and relinquishes its grant; if it is unavailable, a supervisor must explicitly revoke it, record a forced-handoff reason, and accept that later old-device events will be quarantined. Never claim the server knows a disconnected device has no pending work.

Successful completion response includes command_id, decision=ACCEPTED, event_id, resulting_run_version, run_state, current_step_id, current_attempt_id and server_received_at. A duplicate returns the stored original result, with an optional transport-level duplicate indicator. The browser may then fetch the full snapshot.

Set explicit configurable input limits in the API schema. Initial defaults: 1 MiB command body, 4,000 characters per note/reason, 20 MiB source upload, and 100 steps per revision. Reject larger inputs clearly. AI context budgets are separate and must use token-aware chunking or reject oversize sources; truncating source material silently is prohibited.

## 10. Real-time updates and alarms

Write outbox entries in the same transaction as their source event. A worker publishes only committed entries. Outbox delivery may repeat; clients deduplicate notification IDs. A database live-query subscription may wake the worker, but must not be the only durable event source.

SSE authenticates and filters each client's site/department access. Do not broadcast all records and hide unauthorized ones in the UI. On connect/reconnect, send or fetch a scoped authoritative snapshot. Support cursor replay where retained; if cursor is stale, signal `RESYNC_REQUIRED` and reload snapshot. Heartbeats and bounded buffers prevent slow clients from exhausting memory.

Alarm persistence and acknowledgment survive browser closure and application restart. P1/P2 alerts created offline reach supervisors only after reconnection; the UI and product documentation must say so. No promise of immediate remote alarms without connectivity.

## 11. R1B offline protocol

### 11.1 Download and grant

Online, the assigned operator explicitly downloads a run. Server supplies revision content/hash, accepted run snapshot/version, evidence rules, assignment generation and a signed grant limited to that user/device/run and enumerated eligible steps. Default grant duration: 30 minutes or session expiry, whichever is earlier. This is a configurable pilot policy, not a compliance standard.

The grant authorizes later reconciliation only under the rules below. It is not proof of physical identity or work. Its secret signing key never enters the client. The client conservatively tracks elapsed time using monotonic time during the current app session; after app restart offline, allow reading but require reconnection before further execution. Device-clock changes must not extend the grant.

The server must receive an event before grant expiry for automatic acceptance. Late events are quarantined, even if their client timestamp claims earlier execution. This deliberately avoids trusting a disconnected client clock.

### 11.2 Local storage and capture

Use explicit IndexedDB stores for downloaded run snapshots, grants, outgoing events, receipts and quarantine metadata. No arbitrary HTTP interception/replay. Use a reviewed promise wrapper or properly wrap native request events. Finish an IndexedDB transaction before starting network work; use a fresh transaction to store each result.

Persist an event successfully before displaying “recorded on this device.” Quota/storage errors must leave the step unrecorded with an obvious warning. Do not claim IndexedDB is a guaranteed permanent archive. Never show pending work as server accepted.

Minimum queued event fields:

| Field | Rule |
|---|---|
| `event_id`, `schema_version` | Immutable identity, supported schema |
| `grant_id`, `run_id`, `revision_id`, `revision_hash` | Exact downloaded authority/content |
| `actor_id`, `device_id`, `assignment_generation` | Bound to grant; never rebound at sync |
| `local_sequence`, `predecessor_event_id` | Per-run order and causal predecessor; null for first local event |
| `base_run_version` | Accepted server version when offline chain began |
| `action`, `step_id`, `attempt_id`, `payload` | Typed command and evidence |
| `client_occurred_at` | Informational, explicitly untrusted |
| `request_digest` | Stable canonical semantic digest |

Local actor binding is a continuity mechanism, not strong offline identity proof. R1B is not intended for adversarially controlled devices or regulated electronic signatures.

### 11.3 Synchronization

Sync uses enrolled-device credentials scoped solely to submission/status of that device's original grant-bound events. Those credentials do not permit general API access or acting as the currently signed-in user. Device transport identity and original human actor remain separate. A revoked device cannot submit; its local queue remains available for controlled recovery.

Triggers: application open while connected, appliance heartbeat success, explicit retry, and browser online hint. `navigator.onLine` alone is not evidence that the appliance is reachable. Background sync is an optimization, not a dependency.

Process one ordered event at a time per run; bounded parallelism across independent runs. For the first event, base version must match current server state. For subsequent events, the predecessor must be accepted and its resulting version must match current state. A conflicting intervening server change quarantines the chain; no automatic rebasing.

Server checks grant signature/expiry, original user/device eligibility, current qualifications, assignment generation, revision status, action permission, event digest, prerequisite events and required evidence. Recheck current authority; historical grant possession is not sufficient after revocation.

### 11.4 Per-event results

| Result | Meaning | Client behavior |
|---|---|---|
| ACCEPTED | Committed effect | Store receipt; show server accepted |
| DUPLICATE | Same event/digest already processed | Use original receipt; no second effect |
| RETRYABLE | Dependency temporarily unavailable | Keep event; bounded exponential backoff |
| QUARANTINED | Genuine capture requires human disposition | Preserve payload; block dependents; show issue |
| REJECTED | Invalid/forbidden/tampered semantic request | Preserve diagnostic; block dependents; do not silently drop |

Mixed batches return one result per event, never only “batch succeeded.” Persist a terminal receipt for quarantined/rejected authenticated events so repeat submissions are consistent. RETRYABLE is not terminal. Existing receipt retrieval remains scoped and must not leak another user's records.

Quarantine cases include withdrawn revision, expired grant, changed assignment, revoked qualification, and conflicting run changes. A supervisor reviews the captured evidence online and may append a disposition or create a corrective run. Do not convert the old event into an ordinary accepted completion or erase the original reason. New corrective actions have new IDs and current authorization.

### 11.5 Client security and update behavior

After idle lock, hide execution details and disable actions; upload of already recorded events may continue under the narrowly scoped device transport credential. Switching users online preserves old queued events under their original identity and excludes them from the new user's view. Do not purge pending events on logout. Offer an administrative recovery path on the same enrolled device.

Service-worker updates must not activate destructively during active work. Version the cache and IndexedDB schema; test upgrades with pending events. Retain backward-compatible sync decoding for the prior supported client schema during an upgrade window. Warn before clearing browser storage. A lost device or deleted browser profile can lose unsubmitted events; documentation must state this limitation.

## 12. Audit integrity and records

### 12.1 Scope and construction

Audit successful operational mutations, publication/review, identity/qualification changes, grant issuance/revocation, administrative exports and corrective dispositions. Record authentication/security failures in a bounded separate security log so unauthenticated traffic cannot exhaust the operational audit chain.

Each operational audit entry contains a schema version, sequence, prior entry digest, server timestamp, actor, device when applicable, action, resource IDs, command/event ID, exact canonical semantic payload or immutable payload reference/hash, and signing-key ID. Avoid ambiguous delimiter-concatenated strings.

Define a versioned canonical JSON representation restricted to supported scalar types; compare golden test vectors. Calculate a digest over canonical entry bytes including the prior digest. Calculate an HMAC over those bytes with an appliance key. Store bytes so verification does not depend on a later serializer reconstructing them differently.

Append and update the chain head atomically with the domain command. Serialize audit-head updates with a database-supported guarded write; verify contention behavior with concurrent real-database tests. Bounded retry is acceptable for the single-site pilot.

### 12.2 Honest trust boundary

The chain detects certain changes, removals and reordering when checked against a trusted head/checkpoint. A party controlling both the database and HMAC key can forge replacement history. Truncation cannot be detected reliably without a separately retained checkpoint. This is tamper evidence under stated assumptions, not absolute immutability or individual non-repudiation.

Export daily chain-head checkpoints and backup manifests for retention outside the appliance. Specify who retains them. Key rotation records the old/new key IDs and retains secure verification access to historical keys; never put keys in exports, logs or source control. Lost verification keys must be reported as a limitation, not a passing verification result.

### 12.3 Export and correction

Export a run as versioned JSON plus a printable human-readable view containing revision content/hash, asset, actors, step attempts/evidence, server acceptance times, client times labeled as reported, exceptions, dispositions and relevant audit references. Clearly distinguish accepted, quarantined and corrected evidence.

No delete/edit endpoint for accepted history. A correction states the original reference, corrected assertion, authorizing actor and reason. R1 uses no automatic history purge. Retention policy and storage sizing must be documented before a customer deployment; adding purge requires a separate controlled design.

## 13. AI pipeline, source grounding and diagrams

### 13.1 Persisted job lifecycle

States: QUEUED, RUNNING, WAITING_FOR_INPUT, SUCCEEDED, FAILED, CANCELLED. Each stage stores validated output and input hashes. Use a worker lease with expiry; restart recovers abandoned work from the last valid checkpoint. Idempotent stage result IDs prevent duplicate drafts after retry. Cancellation stops further stages and never publishes partial output.

Default inference concurrency is one per appliance. Increase only after measurements. Each job has its own context; no concurrently mutated global map. Limit source size, prompt size, output tokens and retry count. Proposed defaults: 2 transient retries per stage and 1 structured-output repair attempt; then fail visibly. Persist errors and allow an explicit new retry action.

PocketFlow orchestrates stage functions behind the application job service. It is not assumed to provide durable jobs, human wait states or distributed transactions. If its API cannot directly support a wait, end that invocation at the persisted checkpoint and create a new invocation after answers arrive.

### 13.2 Stages and contracts

| Stage | Input | Output and guard |
|---|---|---|
| Extract | Source bytes/text | Text and page/paragraph locators; unsupported/scanned PDF outcome explicit |
| Analyze gaps | Sources + draft context | Gaps with severity and source context; up to 3 questions per round |
| Wait/answer | Questions + human answers | Persisted answers, unresolved blocking gaps |
| Propose | Sources + answers + terminology | Schema-valid proposed revision; no publication rights |
| Validate | Proposal | Deterministic structural and source-reference checks |
| Critique | Valid proposal | Advisory concerns, not independent certification |
| Render diagrams | Approved structure of proposal | Deterministically generated Mermaid, safely rendered |
| Save result | Valid proposal + provenance | New draft/proposal reference, never overwrite approved content |

Every material generated instruction carries one or more source locators or an explicit `AUTHOR_SUPPLIED`/`UNVERIFIED_PROPOSAL` classification. Publication rejects unresolved unverified technical limits, safety requirements or blocking gaps. Human review records how each was resolved. General language improvement may be accepted by the author but must not masquerade as source quotation.

Treat source text as untrusted data. Instructions inside a PDF must not override system policy or authorize tools. Models have no arbitrary shell, database mutation or network permissions. Validate IDs, enums, evidence types and maximum lengths in code. Do not let a prompt silently change approved severity or source facts.

### 13.3 Terminology and prioritization

Replace “culture genome” with an explicit terminology profile: preferred term, equivalent term, scope and reviewer. It may influence wording. It cannot reduce evidence requirements, remove hold points, override qualification rules or invent technical values. Profiles have versions captured with each AI job.

AI priority assignments are suggestions reviewed by humans. The software cannot establish that a machine task is safe merely by producing P1/P2 labels.

### 13.4 Diagram contract

R1 generates a linear flowchart from ordered steps and exception blocks. A run state diagram derives from section 6; label it as execution state, not equipment state. Equipment state and cross-department sequence diagrams are deferred until their underlying structured data exists. Escape labels, disable unsafe links/HTML, and test representative unusual text. Diagrams are views; the structured revision is authoritative.

## 14. UI and accessibility contract

- Primary operator targets have at least 48 × 48 CSS pixels of active area with adequate spacing; verify actual rendered dimensions. Gloves still require compatible hardware and real-device testing.
- Critical information uses text/icons as well as color. Do not encode priority only by red/amber.
- Normal body text in execution views is at least 18 CSS pixels. Layout supports zoom and narrower tablet screens without hiding actions.
- Keyboard navigation, visible focus, labeled fields and readable error announcements are required for supported tasks.
- Explicit labels: Online, Appliance unreachable, Recorded on this device, Accepted by server, Needs review, Rejected. “Saved” alone is insufficient for pending offline work.
- Show operator, asset and revision throughout execution. Lock covers sensitive content. A user switch must visibly change identity before any new action.
- English message keys are centralized from the start. Locale fields default to `en`; no promise that future translation is a one-sprint change. Future translated revisions will need their own review and source linkage.
- No automatic page reload may discard a draft or pending queue. Unsaved changes and model job failures remain visible.

## 15. Packaging, maintenance and recovery

### 15.1 Reproducible build

Commit Go dependency files, local npm lockfile, pinned CLI versions, model manifest/hash, migrations and bundled frontend assets. Build on a connected development machine if needed; production installation must use a complete prepared bundle. Do not run package downloads on an air-gapped customer appliance.

Suggested targets: `generate`, `test-unit`, `test-integration`, `test-e2e`, `test-offline`, `verify-spec`, `build-host`, `build-darwin-arm64`, `package`, `restore-test`. Generated Templ code and vendor bundles are excluded from per-file annotations. Test targets must actually execute their claimed suites, including tools and browser tests.

### 15.2 Install and services

Dedicated least-privileged service identities; persistent data/config/log directories; restrictive file permissions; no database root credentials in process arguments or source. Supervise all three services with startup/restart policies. Readiness fails when critical persistence is unavailable; inference failure marks drafting unavailable while execution remains usable.

`/health/live` reports process liveness. `/health/ready` reports readiness without secrets. Administrative status distinguishes database, inference, disk, backup, outbox lag and last successful audit verification. Log rotation and disk-space alarms prevent silent exhaustion.

### 15.3 Backup/restore

Back up a consistent database snapshot, immutable source storage, configuration, schema/client versions, model manifest and necessary encrypted verification-key material. Keep recovery credentials separately. Never assume copying a running database directory is a valid snapshot.

Pilot operating target: daily backups, recovery point up to 24 hours, restore within 4 hours on available replacement hardware. These are proposed targets to measure; they become claims only after a drill. Unsubmitted client events are outside server backups.

A restore drill must reconstruct a known completed run and a blocked run, verify their audit chains, restart services, and prove a duplicate old command does not create another completion. Backup success without restore evidence is not an accepted release gate.

### 15.4 Updates and migrations

Version migrations; run once; detect incompatible schemas; take/verify a backup before destructive changes. Refuse startup on unsupported newer schema. Test upgrade from the preceding supported release and document roll-forward/restore recovery. Do not promise binary rollback after an irreversible schema migration.

Updates are manually imported, integrity-checked offline bundles. Never automatically download models or silently replace inference behavior. In R1B, reconcile or preserve all pending client queues before retiring a client schema.

## 16. Requirements and verification register

This register is the baseline RTM. Implement `requirements.yaml` or equivalent with these IDs, release, owning module and actual test/evidence references. A linked test is evidence only after it ran successfully against relevant behavior.

| ID | Release | Required behavior | Acceptance evidence |
|---|---|---|---|
| OP-001 | A | Pinned verified stack and no invented APIs | AT-01 |
| OP-002 | A | Immutable approved revision and pinned run | AT-02, AT-03 |
| OP-003 | A | Independent review and exact-hash approval | AT-04 |
| OP-004 | A | Server-enforced roles/scope/qualification | AT-05, AT-06 |
| OP-005 | A | Atomic idempotent execution commands | AT-07, AT-08, AT-09 |
| OP-006 | A | Ordered steps, evidence and attempts | AT-10 |
| OP-007 | A | Blocking exceptions and explicit resolution | AT-11 |
| OP-008 | A | Controlled handoff and terminal states | AT-12 |
| OP-009 | A | Safe job persistence, retries and restart | AT-13, AT-14 |
| OP-010 | A | Grounded proposals and bounded AI authority | AT-15 |
| OP-011 | A | Persistent scoped alarms and reconnect | AT-16 |
| OP-012 | A | Tamper-evident audit and full export | AT-17, AT-18 |
| OP-013 | A | Local-only runtime and trusted TLS | AT-19 |
| OP-014 | A | Real production UI and usable controls | AT-20 |
| OP-015 | A | Backup/restore and controlled migrations | AT-21, AT-22 |
| OP-016 | A | Lock, authentication and request protection | AT-23 |
| OP-017 | A | Defined workload measurements | AT-24 |
| OP-018 | B | Restricted download and offline actions | AT-25, AT-26 |
| OP-019 | B | Original actor binding and ordered replay | AT-27, AT-28 |
| OP-020 | B | Conflict/quarantine without lost evidence | AT-29, AT-30 |
| OP-021 | B | Queue durability and upgrade behavior | AT-31, AT-32 |
| OP-022 | B | Expiry/revocation/lock behavior | AT-33 |
| OP-023 | A/B | Honest release status and complete evidence | AT-34 |

The spec checker validates known IDs, referenced file/test existence and explicit status values. It must not claim semantic correctness from comments or make every deferred requirement fail the R1A build. Statuses: NOT_STARTED, IN_PROGRESS, VERIFIED, BLOCKED, DEFERRED. VERIFIED requires a recorded command/result; never infer it from a test filename.

## 17. Work packages for the coding model

Do these in order. Each package ends with a small reviewable change, tests and a progress handoff. Do not start all packages simultaneously. If the owner requests continuous execution, move automatically to the next package after the gate passes.

### WP-00 — Inspect and reconcile

Read this master and inspect the existing repository if one is supplied. Record what works, what conflicts and what is absent. Produce `docs/IMPLEMENTATION_STATUS.md`, `docs/DECISIONS.md`, `docs/DEPENDENCIES.md` and the RTM. Mark the old spec superseded in repository documentation without deleting its history. If there is no repository, establish the skeleton; do not pretend one was inspected.

Gate: each old subsystem is mapped to retain/change/defer; no unknown is reported as implemented. No feature rewrite in this package.

### WP-01 — Prove infrastructure

Read sections 3, 8 and 15. Pin toolchain and libraries; run stack probes; establish real persistent test database and local inference adapter. Create host build, actual-target service skeleton and local TLS development path. Produce a small database command/rollback/concurrency probe before domain implementation.

Gate: AT-01. A failure is a concrete blocker with logs and alternatives; no fake adapter success.

### WP-02 — Domain and persistence

Read sections 5–8 and 12. Implement domain structs, schema validation, migrations, revisions/runs/events/receipts, state transitions and transaction boundaries. Add a simple application service API used by tests; do not build a parallel business-rule layer in HTTP.

Gate: AT-02, AT-03, AT-07–AT-12 and core AT-17 behavior using a real database for persistence/concurrency claims.

### WP-03 — Identity and policy

Read section 7 and relevant command rules. Implement named-user authentication, enrollment, roles, qualifications, CSRF and locking. Integrate authorization into services, not only buttons/routes. Remove administrative bypasses.

Gate: AT-04–AT-06 and AT-23, including direct HTTP attempts. No unprotected feature is deployed while this work is incomplete.

### WP-04 — Complete manual workflow

Read sections 4, 6, 9, 10 and 14. Implement text/manual draft authoring, review/publication, asset scanning, execution, exceptions, handoff, history/export and dashboard through the real services. Add durable outbox/SSE. This proves value before AI complexity.

Gate: one browser journey creates, reviews, publishes, executes, blocks, resolves and completes a real run; AT-16, AT-18 and AT-20 pass. No simulated scanner or fake persistence in production UI.

### WP-05 — Add AI assistance

Read section 13. Implement source import/PDF limits, persisted discovery, one verified inference provider, proposals/diffs, deterministic validation, source linkage, checkpoint recovery and code-generated diagrams. Manual workflow remains usable when inference fails.

Gate: AT-13–AT-15. A live-model smoke test supplements deterministic mock/error tests; plausible sample text is not enough.

### WP-06 — Operational R1A release

Read sections 12, 15, 18 and 19. Complete audit verification, exports, service supervision, no-internet runtime, backup/restore, migrations and measured workload report. Produce operator/admin quick-start and known limitations.

Gate: all release-A requirements VERIFIED with evidence, or release explicitly labeled incomplete. Package as R1A connected pilot only. Do not announce offline support.

### WP-07 — Restricted R1B client

Read all of section 11 and dependencies it names. Implement download/grant, IndexedDB queue, pending-state UI, strict action restrictions and device-bound transport. Verify real target browser storage/HTTPS behavior. Keep R1B disabled until reconciliation is ready.

Gate: AT-25, AT-26, AT-31 and basic AT-33. Local success must not masquerade as committed server success.

### WP-08 — R1B reconciliation and release

Implement ordered per-event replay, stable receipts, conflict/quarantine UI, actor continuity, grant expiry/revocation, service-worker upgrade behavior and corrective workflows. Run full R1B scenarios plus R1A regression.

Gate: AT-27–AT-34 and unchanged R1A invariants. Document offline limitations prominently.

## 18. Acceptance scenarios

Tests should exercise behavior and failure modes, not mirror implementation functions. Real database tests are mandatory where database guarantees are claimed. Browser tests use the supported target browser and actual HTTPS configuration where relevant.

| Test | Setup/action | Required result |
|---|---|---|
| AT-01 Stack | Clean locked build; two-node PocketFlow probe; real DB concurrency/rollback; local model request | Reproducible output, verified APIs, captured versions; no unresolved critical probe failure |
| AT-02 Revision immutability | Publish revision 1, attempt direct update of its instructions | Denied; new revision required; original hash/content unchanged |
| AT-03 Revision continuity | Start run on v1, publish v2, then withdraw v1 | Run stays on v1 after supersession; withdrawal blocks it; new runs select v2 |
| AT-04 Approval | Author tries approving own draft; alter submitted content; publish without valid approval | All denied; different reviewer can approve exact hash |
| AT-05 Scope | User from department B requests/changes department A run directly | Denied or concealed; no record leak or mutation |
| AT-06 Privilege | Admin without Operator grant attempts P1 completion; expired qualification tested | Denied despite admin role; valid assigned qualified operator succeeds |
| AT-07 Lost response | Commit completion, drop HTTP response, retry identical command | One effect/event/audit append; original receipt returned |
| AT-08 Duplicate race | Send identical command concurrently; then same ID/different payload | Exactly one effect; duplicates stable; changed payload conflicts |
| AT-09 Atomic failure | Inject failure before commit while writing receipt/audit/outbox | No partial domain change; safe retry works |
| AT-10 Steps | Complete future step, omit required evidence, fail/retry current attempt | Invalid advances denied; failed attempt retained; new attempt numbered |
| AT-11 Exception | Report P1 issue; acknowledge; try advancing; resolve appropriately | Run blocks; acknowledgment alone does not resume; resolution guard applied |
| AT-12 Handoff | Transfer run; old actor attempts completion; cancel then retry new action | Old assignment denied; terminal run unchanged; handoff/history retained |
| AT-13 AI restart | Kill worker after checkpoint; restart | Resume/retry safely without duplicate draft or lost answers |
| AT-14 AI failure | Timeout, malformed JSON, excess output, cancellation | Bounded retries; clear persisted failure/cancel; no publication |
| AT-15 Grounding | Source contains injected instructions and missing technical limit | No tool/policy override; gap remains; publication blocked until resolved |
| AT-16 Alarms | Disconnect dashboard, create alarm, restart app, reconnect as scoped user | Alarm recovered; no cross-scope events; acknowledgment persists |
| AT-17 Audit | Alter payload, delete/reorder entry, truncate relative to retained checkpoint | Verifier detects relevant failures; normal chain passes; trust limits documented |
| AT-18 Export | Export completed run with failed attempt and correction | Original revision and all evidence/history represented consistently |
| AT-19 Local runtime | Block external egress, restart services, use real tablet via local TLS | Core flow/camera works; no required remote assets; inference stays local |
| AT-20 UI | Real scan, keyboard path, zoom/narrow viewport, glove-mode dimensions | No mock controls; status legible; required controls accessible |
| AT-21 Restore | Restore backup to clean target with known runs; retry old command | History and audit verify; services work; duplicate has no new effect |
| AT-22 Migration | Upgrade previous supported schema, simulate failure, attempt unsupported newer schema | Controlled recovery/refusal; no silent data loss |
| AT-23 Sessions | Idle timeout, user switch, login rate-limit, CSRF attempt | Locked actions denied; identity rotates; request protection works |
| AT-24 Measurements | Run declared representative workload on declared hardware | Measured p50/p95 and errors recorded; no fabricated guaranteed latency |
| AT-25 Offline eligibility | Disconnect on downloaded P3 run; attempt new run or P1/P2 completion | Eligible continuation recorded pending; forbidden actions unavailable and server-rejected if forged |
| AT-26 Offline boundary | Start offline with no grant/cache, or restart client offline | No new execution; clear read-only/reconnect explanation |
| AT-27 Ordered replay | Queue three completions, retry/reorder submissions | Each applied at most once in causal order; later unresolved dependency waits |
| AT-28 Identity | A queues event; switch online to B before upload | Event remains A's; B cannot view/claim it; transport remains device-scoped |
| AT-29 Withdrawal conflict | Withdraw revision while device disconnected; reconnect with queued event | Quarantine preserved; dependents blocked; no automatic accepted completion |
| AT-30 Mixed results | Replay batch containing accepted, expired and invalid events | Per-event outcomes; no dropped capture; supervisor disposition preserves original |
| AT-31 Storage failure | Force quota/write failure; close browser after successful queue commit | Failure never says recorded; committed pending event survives normal reopen |
| AT-32 Client upgrade | Update service worker/schema with queued events | Queue retained/readable and sync-compatible; no destructive reload |
| AT-33 Offline authority | Advance device clock/backdate event; expire grant; revoke user/device; idle-lock | No grant extension or actor substitution; expiry/revocation/lock rules enforced |
| AT-34 Release honesty | Inspect status, test commands, disabled deferred features and docs | Evidence matches claims; no placeholder passed tests or undisclosed stubs |

### 18.1 Measurement workload

Initial pilot profile: 10 simultaneously connected devices, 1,000 procedure revisions, 10,000 historical runs and one AI drafting job. Use documented fixtures and payload sizes. Measure non-AI command latency and errors, SSE update delay, database disk growth, restart recovery and AI throughput separately.

Suggested engineering targets: non-AI command p95 below 500 ms on site LAN, committed alarm visible within 2 seconds while connected, and no lost/duplicate accepted effects under retry tests. These are targets to validate and adjust openly, not properties established by this document. Record source length, generated token count, model/quantization and inference settings for AI timing. Remove original universal 15-second and ten-in-60-seconds promises.

## 19. Repository documents and coding-model handoff

### 19.1 Minimum maintained files

| File | Purpose |
|---|---|
| `docs/MASTER-CONTRACT.md` | This document, authoritative version |
| `docs/IMPLEMENTATION_STATUS.md` | Current package, verified behavior, blockers, next action |
| `docs/DECISIONS.md` | Dated decisions and explicit owner changes |
| `docs/DEPENDENCIES.md` | Pins, model manifests, compatibility probe evidence |
| `docs/requirements.yaml` | Requirement/test/status mapping |
| `docs/API-CONTRACT.md` | Implemented request/response schemas and error cases |
| `docs/OPERATIONS.md` | Installation, backup, restore, updates and limitations |
| `docs/ACCEPTANCE-RESULTS.md` | Commands, environment, results and unresolved failures |

If separate specifications are useful, extract sections into `01-domain.md`, `02-execution.md`, `03-security-audit.md`, `04-api-ui.md`, `05-ai.md`, `06-offline.md`, and `07-delivery-tests.md`. Keep IDs and authority intact; master retains scope and precedence. Splitting files is organization work, not an invitation to redesign.

### 19.2 Ready-to-paste coding-model instruction

```text
You are implementing Opera-Engine from docs/MASTER-CONTRACT.md, version 2.0.
The earlier Gemini conversation is background only and is superseded.

Read the master contract and current IMPLEMENTATION_STATUS before editing.
If no status file exists, begin WP-00. Do not assume any feature exists.
Preserve useful existing code. Do not rebuild the project for cosmetic reasons.

Implement the next work package in order. Read the sections it names.
Use exact supported library APIs verified against pinned dependencies.
Do not invent APIs, silently substitute libraries, or weaken invariants.

The application service layer owns authorization and state transitions.
UI disabling, QR scans and AI output are not authority.
Published content is immutable. Runs pin exact revisions.
Commands are idempotent and transactionally write state, receipts, audit and outbox.
Offline execution is R1B, with the explicit restrictions in section 11.

Write tests for the package's acceptance scenarios, including real database
tests for transaction/concurrency claims. Do not replace hard tests with mocks.
Mocks are appropriate for reproducible model errors and other external failures.
Never add production success stubs, simulated QR matches or fabricated records.

When a requirement is unfinished, mark it unfinished. Do not change its meaning
so an easier test passes. Do not claim compliance or readiness from compilation.

At each completed package, update status, RTM and acceptance results with:
1. Files and behavior changed.
2. Exact checks run and outcomes.
3. Known limitations or blockers.
4. The next package and first concrete action.
5. Any owner decision that is actually needed, with options and recommendation.

Continue through authorized packages when gates pass. Stop only for a real
blocker or a decision that would materially change the contract. Before asking,
complete all independent useful work and make the decision concrete.
```

### 19.3 Session-end status template

```text
Contract version:
Repository/commit:
Current release target: R1A or R1B
Work package:
Completed behavior:
Requirement IDs verified:
Tests run (commands/environment/results):
Not tested:
Known failures:
Decisions made and authority:
Files changed:
Next package:
First next action:
```

This handoff is mandatory even when a model runs out of context. A new model should be able to resume from the repository and these files without reconstructing the whole conversation.

## 20. Technical references and evidence limits

This is a design contract, not an implementation audit. No repository was supplied with the request, and no application or target hardware was tested while writing it. The original source conversation was reviewed; compatibility is deliberately a gate rather than a guessed fact.

References checked during preparation or the preceding review:

- SurrealDB transaction statement documentation: https://surrealdb.com/docs/reference/query-language/statements/begin — supports atomic grouping; actual isolation/concurrency behavior must be proved on the chosen pin/storage engine.
- PocketFlowGo published package documentation: https://pkg.go.dev/github.com/lalolv/PocketFlowGo — use the actual exported API; the older snippets are not a substitute for inspecting the selected version.
- MDN IndexedDB guide: https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API/Using_IndexedDB — request/transaction behavior and storage limitations.
- MDN service-worker guide: https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers — lifecycle and secure-context deployment considerations.
- NIST message authentication code overview: https://csrc.nist.gov/Projects/message-authentication-codes — shared-secret authentication basis, not a claim of individual non-repudiation.
- FDA Part 11 scope guidance: https://www.fda.gov/media/75414/download — compliance depends on applicable records and controls; this pilot does not assert compliance.

No account/model usage allowance is assumed by this document. Its small work packages and explicit handoffs are intended to reduce dependence on any one model or one long conversation.

## 21. Owner-facing decision summary

Proceed with the product and preserve its local Go-based direction. Replace speculative guarantees with explicit operational behavior. The first success criterion is one trustworthy end-to-end procedure lifecycle, including what happens when something goes wrong. Offline work, broader workflow semantics and enterprise capabilities are deliberate later increments with their own gates.

The immediate next action for the coding model is WP-00, followed by the dependency and transaction probes in WP-01. It must not begin by generating an entire application from the old conversation.
