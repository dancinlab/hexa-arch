// DomainGraph — algorithms over the DomainCatalog DAG (D82).
//
// DomainCatalog stores direct prerequisite edges only (D50
// g_ssot_single_source); this file computes the derived values —
// transitive closure, topological sort, facet filter, roots / leaves.
//
// cockpit and DemiurgeCLI both consume this; the cockpit `NewProject`
// wizard calls `transitiveClosure(start:)` to propose the full
// dependency chain to a user picking a single start domain.

import Foundation

public enum DomainGraph {

    /// All domains, indexed by id for O(1) lookup.
    public static var index: [String: Domain] {
        Dictionary(uniqueKeysWithValues: DomainCatalog.all.map { ($0.id, $0) })
    }

    /// Transitive closure (BFS over prerequisite edges, including the
    /// start node). Result is unordered set membership; for an ordered
    /// list, pass it through `topologicalSort`.
    public static func transitiveClosure(of start: String) -> [Domain] {
        let idx = index
        var visited: Set<String> = []
        var queue: [String] = [start]
        var collected: [Domain] = []
        while let id = queue.first {
            queue.removeFirst()
            if visited.contains(id) { continue }
            visited.insert(id)
            guard let d = idx[id] else { continue }
            collected.append(d)
            for p in d.prerequisites where !visited.contains(p) {
                queue.append(p)
            }
        }
        return collected
    }

    /// Topological sort — foundation (no prereq) first, integration
    /// apex last. Kahn's algorithm over the subgraph induced by the
    /// given domain ids. Stable secondary order by id (alphabetical).
    public static func topologicalSort(_ ids: [String]) -> [String] {
        let idx = index
        let set = Set(ids)
        // in-degree counts within the subgraph
        var inDegree: [String: Int] = [:]
        for id in ids { inDegree[id] = 0 }
        for id in ids {
            guard let d = idx[id] else { continue }
            for p in d.prerequisites where set.contains(p) {
                // edge p -> id (id depends on p), so id's in-degree++
                inDegree[id, default: 0] += 1
            }
        }
        var result: [String] = []
        var ready = inDegree.filter { $0.value == 0 }.map { $0.key }.sorted()
        var remaining = inDegree
        while let next = ready.first {
            ready.removeFirst()
            result.append(next)
            remaining.removeValue(forKey: next)
            // for each successor of `next` in the subgraph, decrement
            for id in ids {
                guard let d = idx[id],
                      remaining[id] != nil,
                      d.prerequisites.contains(next) else { continue }
                remaining[id, default: 1] -= 1
                if remaining[id] == 0 {
                    ready.append(id)
                    ready.sort()
                }
            }
        }
        // remaining nodes (if any) indicate a cycle; append in id order
        // (the DAG invariant should keep this empty)
        result.append(contentsOf: remaining.keys.sorted())
        return result
    }

    /// Filter by scale facet (D82 multi-tag — a domain qualifies if
    /// its facet matches).
    public static func byScale(_ scale: DomainScale) -> [Domain] {
        DomainCatalog.all.filter { $0.facets.scale == scale }
    }

    /// Filter by cluster facet (multi-tag — a domain qualifies if any
    /// of its clusters matches).
    public static func byCluster(_ cluster: DomainCluster) -> [Domain] {
        DomainCatalog.all.filter { $0.facets.clusters.contains(cluster) }
    }

    /// Foundation nodes — no prerequisites. The bottom of the DAG.
    public static func roots() -> [Domain] {
        DomainCatalog.all.filter { $0.prerequisites.isEmpty }
    }

    /// Integration apex nodes — no other domain lists this one as a
    /// prerequisite. The top of the DAG.
    public static func leaves() -> [Domain] {
        let referenced = Set(DomainCatalog.all.flatMap { $0.prerequisites })
        return DomainCatalog.all.filter { !referenced.contains($0.id) }
    }
}
