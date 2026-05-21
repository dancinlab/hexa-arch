# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`

**Created**: [DATE]

**Status**: Draft

**Input**: User description: "$ARGUMENTS"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: System MUST [specific capability, e.g., "allow users to create accounts"]
- **FR-002**: System MUST [specific capability, e.g., "validate email addresses"]
- **FR-003**: Users MUST be able to [key interaction, e.g., "reset their password"]
- **FR-004**: System MUST [data requirement, e.g., "persist user preferences"]
- **FR-005**: System MUST [behavior, e.g., "log all security events"]

*Example of marking unclear requirements:*

- **FR-006**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]
- **FR-007**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "Users can complete account creation in under 2 minutes"]
- **SC-002**: [Measurable metric, e.g., "System handles 1000 concurrent users without degradation"]
- **SC-003**: [User satisfaction metric, e.g., "90% of users successfully complete primary task on first attempt"]
- **SC-004**: [Business metric, e.g., "Reduce support tickets related to [X] by 50%"]

## Assumptions

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right assumptions based on reasonable defaults
  chosen when the feature description did not specify certain details.

  D111 IMPLICATIONS (see `.specify/README.md` + `.specify/memory/constitution.md` R2):
  - If feature adds/modifies a verb-cell (domain × verb), assume dispatch
    flows through `cellrun.hexa` + `domains/<id>.demi` manifest — NOT new
    `*Producer.swift` Swift code. Cite the D111 commitment if scope touches
    cell dispatch.
  - If feature is a new domain, ship `domains/<id>.demi` manifest (not a
    new Producer Swift class hierarchy).
  - If feature touches existing `*Producer.swift` classes, declare whether
    it's transitional-bridge maintenance (allowed for now) OR migration to
    cellrun (preferred per D111).

  D114 / D116 / R3 CODE-LOCATION IMPLICATIONS (see `.specify/README.md` 의
  "D114 / D116" + "🛑 실수 방지" sections + constitution R3 boundary table):
  - **algorithm code** (math · physics · validation · domain logic · kernels)
    MUST live in `~/core/hexa-lang/stdlib/<domain>/` ONLY. NEVER in
    sibling repos (`hexa-rtsc/` · `hexa-matter/` · `hexa-bio/` · `hexa-chem/`)
    — those are **docs only** per D116.
  - **sibling repos** carry domain narrative (`.md` · physics derivation ·
    citation index · spec) ONLY. NO code (`.hexa` · `.py` · `.swift`).
  - **cockpit/Sources/** allowed: typed Codable records · SwiftUI views ·
    thin dispatch wrappers · CLI presentation · `.demi` manifests. NOT
    allowed: algorithm code (>100 LOC non-dispatch logic) · `cockpit/scripts/`
    Python (D61 violator).
  - If the spec proposes placing code in `hexa-rtsc/<...>` · `hexa-matter/<...>`
    · `hexa-bio/<...>` · `hexa-chem/<...>` → STOP · redirect to `hexa-lang/
    stdlib/<domain>/`. (Past mistake pattern · see README "🛑 실수 방지" #1.)
-->

- [Assumption about target users, e.g., "Users have stable internet connectivity"]
- [Assumption about scope boundaries, e.g., "Mobile support is out of scope for v1"]
- [Assumption about data/environment, e.g., "Existing authentication system will be reused"]
- [Dependency on existing system/service, e.g., "Requires access to the existing user profile API"]
- **Cell dispatch (D111)**: [If verb-cell related — "Feature ships `.demi` manifest entry; no new `*Producer.swift`" OR "Out of scope (e.g. pure UI/cockpit feature)"]
- **Code location (D114/D116)**: [If feature adds code — explicitly cite which repo: `hexa-lang/stdlib/<domain>/` for algorithms · `demiurge/cockpit/Sources/` for typed records/UI/thin dispatch/CLI · NEVER sibling repos (hexa-rtsc/hexa-matter/hexa-bio/hexa-chem · docs only per D116). If feature touches `cockpit/Sources/` Swift, declare whether it's typed-record/UI/thin-dispatch (allowed) or algorithm-shaped (R3 violation · refactor).]
- **Governance gates**: [Cite applicable R-row from `memory/constitution.md` (R1 measured-oracle · R2 cellrun dispatch · R3 stdlib SSOT · R4 RTSC twin-error · etc.) and applicable D-block from `../design.md`]
