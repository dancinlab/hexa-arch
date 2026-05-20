// Domain — single source of truth for per-domain metadata (D82 graph).
//
// SSOT rule (AGENTS.tape g_ssot_single_source): the domain key list,
// display labels, canvas-mode mapping, prerequisite edges, facet tags,
// and free-text inference keywords all live HERE — cockpit and CLI
// both consume DomainCatalog rather than each carrying its own
// `switch` over domain strings.
//
// D82 (graph DAG + multi-facet tag, Option 3): each Domain carries
//   - prerequisites: [DomainID]   (direct edges; transitive closure
//                                  is computed by DomainGraph)
//   - facets: DomainFacets        (multi-tag, NOT a partition)
//
// DemiurgeCore stays pure Foundation (Package.swift contract).

import Foundation

/// Which ② work-zone canvas mode a domain renders in (rfc_011 §7).
/// The mapping is data; the cockpit turns a mode into a SwiftUI view.
public enum CanvasMode: String, Sendable, Codable {
    case chip, component, matter, cohort
}

/// Where in the abstraction hierarchy a domain sits — Molecular (atom
/// / molecule), Device (chip-class device), Component (mechanical /
/// PCB / mechatronic assembly), System (multi-component infrastructure
/// or integration apex). Facet tag, NOT a partition (D82).
public enum DomainScale: String, Sendable, Codable {
    case molecular, device, component, system
}

/// A cluster a domain belongs to. **Multi-tag**: a domain may belong
/// to several clusters (e.g., a pharmaceutical drug is both `bio` and
/// `chem`). D82 explicitly rejects partition semantics.
public enum DomainCluster: String, Sendable, Codable {
    case matter, bio, chem, physical, propulsion, sensing
    case engineering, life, system
}

/// Platform hostility — where the domain's substrate is reliably
/// runnable. `macosClean` means the cockpit can dispatch without
/// pool routing; the others narrow what the cockpit can do locally.
public enum DomainHostility: String, Sendable, Codable {
    case macosClean = "macos-clean"
    case macosPartial = "macos-partial"
    case macosBlocked = "macos-blocked"
    case linuxPool = "linux-pool"
}

/// Multi-tag facet container. Filter / search axis for the cockpit
/// "New Project" wizard.
public struct DomainFacets: Sendable, Codable, Equatable {
    public let scale: DomainScale
    public let clusters: [DomainCluster]
    public let hostility: DomainHostility

    public init(scale: DomainScale,
                clusters: [DomainCluster],
                hostility: DomainHostility) {
        self.scale = scale
        self.clusters = clusters
        self.hostility = hostility
    }
}

/// One demiurge domain's metadata.
public struct Domain: Identifiable, Sendable {
    /// Domain key — "chip", "component", … (matches Project.domain).
    public let id: String
    /// Plain-language display label (rfc_012 §4).
    public let label: String
    /// Canvas mode for the ② work zone (rfc_011 §7).
    public let canvasMode: CanvasMode
    /// Free-text inference hints (rfc_012 §3 / D44).
    public let keywords: [String]

    /// D82 — direct prerequisite domains (graph DAG edges). Transitive
    /// closure is computed by `DomainGraph`, NOT stored here
    /// (`g_ssot_single_source`). Empty array = foundation node.
    public let prerequisites: [String]

    /// D82 — multi-tag facets (scale, clusters, hostility). Filter axis,
    /// not partition.
    public let facets: DomainFacets

    /// Optional sibling-repo SSOT pointer (D17 precedent). For domains
    /// whose substrate lives outside `hexa-lang/stdlib/<id>/` (e.g.,
    /// `~/core/hexa-matter/`, `~/core/hexa-ufo/`, `~/core/hexa-bio/`).
    public let substrateSSOT: String?

    public init(id: String, label: String, canvasMode: CanvasMode,
                keywords: [String],
                prerequisites: [String] = [],
                facets: DomainFacets,
                substrateSSOT: String? = nil) {
        self.id = id
        self.label = label
        self.canvasMode = canvasMode
        self.keywords = keywords
        self.prerequisites = prerequisites
        self.facets = facets
        self.substrateSSOT = substrateSSOT
    }
}

/// The domain catalog — the one place domain metadata is defined
/// (D82 graph DAG + multi-facet tag).
public enum DomainCatalog {
    /// 19 domains — 16 original + 3 from D81 (chem · bio · ufo).
    /// `prerequisites` edges sourced from each `domains/<id>.md` §6
    /// cross-references + the explicit research scan recorded in PLAN
    /// κ-55 (rtsc-foundation chain discovery).
    public static let all: [Domain] = [
        // Device tier
        Domain(id: "chip", label: "칩 설계", canvasMode: .chip,
               keywords: ["칩", "반도체", "chip", "soc", "asic", "프로세서", "cpu", "gpu", "noc"],
               prerequisites: [],
               facets: DomainFacets(scale: .device,
                                    clusters: [.physical, .engineering],
                                    hostility: .macosClean)),
        Domain(id: "firmware", label: "펌웨어", canvasMode: .cohort,
               keywords: ["펌웨어", "firmware", "embedded", "mcu", "zephyr", "qemu"],
               prerequisites: ["chip"],
               facets: DomainFacets(scale: .device,
                                    clusters: [.engineering],
                                    hostility: .macosClean)),
        Domain(id: "sscb", label: "솔리드스테이트 차단기", canvasMode: .cohort,
               keywords: ["차단기", "sscb", "interrupter", "차단"],
               prerequisites: ["chip", "brain"],
               facets: DomainFacets(scale: .device,
                                    clusters: [.engineering, .physical],
                                    hostility: .macosClean)),
        Domain(id: "rtsc", label: "초전도 코일", canvasMode: .cohort,
               keywords: ["초전도", "rtsc", "코일", "권선", "rebco", "hts"],
               prerequisites: [],
               facets: DomainFacets(scale: .device,
                                    clusters: [.physical],
                                    hostility: .macosPartial),
               substrateSSOT: "~/core/hexa-rtsc/"),
        Domain(id: "brain", label: "뇌·신경", canvasMode: .cohort,
               keywords: ["뇌", "brain", "신경", "neuro", "인지", "bci", "전극"],
               prerequisites: ["bio"],
               facets: DomainFacets(scale: .device,
                                    clusters: [.life, .sensing],
                                    hostility: .macosClean),
               substrateSSOT: "~/core/hexa-brain/"),
        Domain(id: "aura", label: "청각 웨어러블 BCI", canvasMode: .cohort,
               keywords: ["청각", "귀", "이어", "aura", "eeg", "웨어러블", "보청", "bci"],
               prerequisites: ["rtsc", "chip", "brain", "bio", "firmware"],
               facets: DomainFacets(scale: .component,
                                    clusters: [.sensing, .life, .engineering],
                                    hostility: .macosPartial),
               substrateSSOT: "~/core/hexa-aura/"),

        // Component tier
        Domain(id: "component", label: "부품 설계", canvasMode: .component,
               keywords: ["부품", "component", "기구", "케이스", "enclosure", "패키지", "heatsink", "방열"],
               prerequisites: ["chip", "space"],
               facets: DomainFacets(scale: .component,
                                    clusters: [.engineering, .physical],
                                    hostility: .macosClean)),
        Domain(id: "bot", label: "로봇", canvasMode: .cohort,
               keywords: ["로봇", "robot", "bot", "매니퓰레이터", "구동", "actuator"],
               prerequisites: ["mobility"],
               facets: DomainFacets(scale: .component,
                                    clusters: [.engineering],
                                    hostility: .macosClean)),

        // Molecular tier — D81 신규 chem + bio + 기존 matter
        Domain(id: "matter", label: "물질·재료", canvasMode: .matter,
               keywords: ["물질", "재료", "material", "합금", "분자", "matter", "소재"],
               prerequisites: [],
               facets: DomainFacets(scale: .molecular,
                                    clusters: [.matter, .physical],
                                    hostility: .macosClean),
               substrateSSOT: "~/core/hexa-matter/"),
        Domain(id: "chem", label: "화학·반응", canvasMode: .cohort,
               keywords: ["화학", "chem", "반응", "촉매", "synthesis", "합성"],
               prerequisites: ["matter"],
               facets: DomainFacets(scale: .molecular,
                                    clusters: [.chem, .matter],
                                    hostility: .macosClean),
               substrateSSOT: "~/core/hexa-chem/"),
        Domain(id: "bio", label: "생물·분자", canvasMode: .cohort,
               keywords: ["생물", "bio", "단백질", "protein", "dna", "rna", "drug", "molecule"],
               prerequisites: ["chem", "matter"],
               facets: DomainFacets(scale: .molecular,
                                    clusters: [.bio, .chem, .life],
                                    hostility: .macosClean),
               substrateSSOT: "~/core/hexa-bio/"),

        // System tier
        Domain(id: "energy", label: "에너지", canvasMode: .cohort,
               keywords: ["에너지", "배터리", "energy", "태양", "solar", "전력", "발전", "원자로"],
               prerequisites: ["grid"],
               facets: DomainFacets(scale: .system,
                                    clusters: [.engineering, .physical],
                                    hostility: .macosClean)),
        Domain(id: "grid", label: "AI 데이터센터·전력망", canvasMode: .cohort,
               keywords: ["데이터센터", "grid", "데이터", "서버", "랙", "fabric"],
               prerequisites: ["cern", "rtsc"],
               facets: DomainFacets(scale: .system,
                                    clusters: [.engineering, .physical],
                                    hostility: .macosClean)),
        Domain(id: "mobility", label: "자율주행", canvasMode: .cohort,
               keywords: ["자율주행", "mobility", "자동차", "차량", "자율", "운전"],
               prerequisites: ["fusion"],
               facets: DomainFacets(scale: .system,
                                    clusters: [.engineering],
                                    hostility: .macosBlocked)),
        Domain(id: "scope", label: "망원경·광학", canvasMode: .cohort,
               keywords: ["망원경", "scope", "거울", "광학", "telescope"],
               prerequisites: ["space"],
               facets: DomainFacets(scale: .system,
                                    clusters: [.physical, .sensing],
                                    hostility: .macosClean)),
        Domain(id: "space", label: "우주·항공", canvasMode: .cohort,
               keywords: ["우주", "위성", "space", "로켓", "궤도", "satellite", "항공"],
               prerequisites: [],
               facets: DomainFacets(scale: .system,
                                    clusters: [.physical, .engineering],
                                    hostility: .macosClean),
               substrateSSOT: "~/core/hexa-space/"),
        Domain(id: "cern", label: "가속기·입자", canvasMode: .cohort,
               keywords: ["가속기", "cern", "입자", "빔", "beamline", "lattice"],
               prerequisites: ["chip"],
               facets: DomainFacets(scale: .system,
                                    clusters: [.physical],
                                    hostility: .macosClean),
               substrateSSOT: "~/core/hexa-cern/"),
        Domain(id: "antimatter", label: "반물질·트랩", canvasMode: .cohort,
               keywords: ["반물질", "antimatter", "positron", "penning", "트랩", "pet"],
               prerequisites: ["matter", "space"],
               facets: DomainFacets(scale: .system,
                                    clusters: [.physical],
                                    hostility: .macosClean),
               substrateSSOT: "~/core/hexa-antimatter/"),
        Domain(id: "fusion", label: "핵융합", canvasMode: .cohort,
               keywords: ["핵융합", "fusion", "플라즈마", "토카막", "plasma", "tokamak"],
               prerequisites: ["antimatter", "cern", "energy", "rtsc"],
               facets: DomainFacets(scale: .system,
                                    clusters: [.physical],
                                    hostility: .macosPartial),
               substrateSSOT: "~/core/hexa-fusion/"),

        // Integration apex — D81 ufo (HEXA-Disc)
        Domain(id: "ufo", label: "UFO·디스크 추진", canvasMode: .cohort,
               keywords: ["ufo", "uap", "디스크", "propulsion", "warp", "wormhole"],
               prerequisites: ["fusion", "antimatter", "rtsc"],
               facets: DomainFacets(scale: .system,
                                    clusters: [.physical, .propulsion],
                                    hostility: .macosClean),
               substrateSSOT: "~/core/hexa-ufo/"),
    ]

    /// Domain for a key — a synthetic "general" cohort domain when the
    /// key is not in the catalog (so callers never crash on an unknown
    /// domain; the user can correct it via the §3 confirm step).
    public static func domain(for key: String) -> Domain {
        if let known = all.first(where: { $0.id == key }) {
            return known
        }
        return Domain(
            id: key,
            label: key == "general" ? "일반 공학" : key,
            canvasMode: .cohort,
            keywords: [],
            prerequisites: [],
            facets: DomainFacets(scale: .system,
                                 clusters: [.engineering],
                                 hostility: .macosClean))
    }

    /// Free-text → best-effort domain key (rfc_012 §3, D44 option C).
    /// "general" when nothing matches — the confirm step lets the user
    /// correct it, so the AI infers but never finalizes (g3).
    public static func infer(from target: String) -> String {
        let t = target.lowercased()
        for domain in all where domain.keywords.contains(where: { t.contains($0) }) {
            return domain.id
        }
        return "general"
    }
}
