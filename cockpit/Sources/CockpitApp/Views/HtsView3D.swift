// HtsView3D — minimal RealityKit 3D viewer for the HTS coil.
//
// Mirror of ComponentView3D's NSViewRepresentable shape, simplified to
// concentric cylinders (no exploded view, no presets — this is the
// κ-? test window).  The user-facing surface is a single SwiftUI
// view: orbit drag (yaw / pitch), scroll-zoom (ScrollableARView from
// ComponentView3D is reused), light/dark adaptive sky.
//
// HONEST (g3): the rendered geometry is `HtsCoilGeometry.htsSolenoidProxy`
// — procedural placeholder, not a measured coil.

import SwiftUI
import RealityKit
import AppKit
import DemiurgeCore

struct HtsScene: NSViewRepresentable {
    let geometry: HtsCoilGeometry
    let onScrollZoom: (CGFloat) -> Void
    var yaw: Float
    var pitch: Float

    func makeNSView(context: Context) -> ARView {
        let view = ScrollableARView(frame: .zero)
        view.environment.background = .color(.windowBackgroundColor)
        view.onScroll = onScrollZoom
        return view
    }

    func updateNSView(_ nsView: ARView, context: Context) {
        nsView.scene.anchors.removeAll()
        let anchor = AnchorEntity(world: .zero)
        let root = Entity()

        // RealityKit unit ≈ 1 m; convert mm.
        let mmToM: Float = 0.001
        let length = Float(geometry.lengthMM) * mmToM

        // Rings are drawn inner → outer so RealityKit's transparent
        // pass renders the cryostat last; the inner solid rings
        // become visible through the translucent shell + bore.
        // The HTS Coil ring is rendered translucent (forced to 0.40)
        // so the helix winding inside is visible.
        for ring in geometry.rings {
            let rOuter = Float(ring.outerRadiusMM) * mmToM
            let rInner = Float(ring.innerRadiusMM) * mmToM
            guard rOuter > rInner else { continue }
            // Real annular tube — no z-fight with the neighbouring
            // ring because the inner surface stops exactly at the
            // previous ring's outer surface.
            let mesh = MeshResource.generateAnnulus(
                height: length,
                innerRadius: rInner,
                outerRadius: rOuter,
                segments: 64)
            var material = PhysicallyBasedMaterial()
            let nsColor = NSColor(hexString: ring.colorHex)
            material.baseColor = .init(tint: nsColor)
            material.roughness = .init(floatLiteral: 0.35)
            let isMetal = ring.material.contains("copper")
                || ring.material.contains("stainless")
                || ring.material.contains("REBCO")
            material.metallic = .init(floatLiteral: isMetal ? 0.85 : 0.1)
            // The HTS Coil ring is forced translucent so the helix
            // winding inside it is visible.
            let isHTSCoil = ring.name == "HTS Coil"
            let effectiveOpacity: Double = isHTSCoil ? 0.40 : ring.opacity
            if effectiveOpacity < 0.999 {
                material.blending = .transparent(
                    opacity: .init(floatLiteral: Float(effectiveOpacity)))
            }
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.position = [0, 0, 0]
            // Lay solenoid on its side (axis along world X) so the
            // viewer sees the bore rather than the end-cap.
            entity.transform.rotation = simd_quatf(
                angle: .pi / 2, axis: [0, 0, 1])
            root.addChild(entity)

            // Render the helix winding inside the HTS Coil ring.
            if isHTSCoil {
                let pathRadius = 0.5 * (rOuter + rInner)
                let tubeRadius: Float = 0.002    // 2 mm REBCO-tape proxy
                let turns = Float(geometry.turns)
                let helixMesh = MeshResource.generateHelixTube(
                    pathRadius: pathRadius,
                    tubeRadius: tubeRadius,
                    height: length,
                    turns: turns,
                    pathSegments: max(48, Int(turns * 8)),
                    tubeSegments: 8)
                var helixMat = PhysicallyBasedMaterial()
                // Bright gold-copper — distinct from the translucent
                // HTS Coil sleeve so the wire reads as the actual
                // current path.
                helixMat.baseColor = .init(tint:
                    NSColor(hexString: "#F2C66B"))
                helixMat.metallic = .init(floatLiteral: 0.95)
                helixMat.roughness = .init(floatLiteral: 0.20)
                let helix = ModelEntity(
                    mesh: helixMesh, materials: [helixMat])
                helix.position = [0, 0, 0]
                helix.transform.rotation = simd_quatf(
                    angle: .pi / 2, axis: [0, 0, 1])
                root.addChild(helix)
            }
        }

        // Camera frame + orbit.
        root.transform.rotation = simd_quatf(angle: yaw, axis: [0, 1, 0])
            * simd_quatf(angle: pitch, axis: [1, 0, 0])
        anchor.addChild(root)

        // Pull the camera back enough to frame the full solenoid.
        let camera = PerspectiveCamera()
        camera.transform.translation = [0, 0, 0.5]
        camera.camera.fieldOfViewInDegrees = 50
        anchor.addChild(camera)

        // Soft directional light so the coil materials aren't flat.
        let light = DirectionalLight()
        light.light.intensity = 1800
        light.shadow = DirectionalLightComponent.Shadow(
            maximumDistance: 4, depthBias: 1.0)
        light.transform.rotation = simd_quatf(
            angle: -0.6, axis: [1, 0, 0])
        anchor.addChild(light)

        nsView.scene.anchors.append(anchor)
    }
}

struct HtsView3D: View {
    let geometry: HtsCoilGeometry
    @State private var yaw: Float = 0.6
    @State private var pitch: Float = 0.25
    @State private var zoom: Float = 1.0

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                HtsScene(geometry: geometry,
                          onScrollZoom: { dy in
                              zoom = max(0.25, min(3.0, zoom + Float(dy) * 0.01))
                          },
                          yaw: yaw, pitch: pitch)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { v in
                                yaw += Float(v.translation.width) * 0.005
                                pitch = max(-1.5, min(1.5,
                                    pitch + Float(v.translation.height) * 0.005))
                            }
                    )
                    .scaleEffect(CGFloat(zoom))
                    .background(Color(.windowBackgroundColor))
                VStack(alignment: .leading, spacing: 4) {
                    Text(geometry.displayName)
                        .font(.headline)
                    Text("L \(Int(geometry.lengthMM)) mm · "
                         + "turns \(geometry.turns) · "
                         + "\(geometry.rings.count) rings")
                        .font(.caption.monospaced())
                    Text("g3 · GATE_OPEN · procedural HTS proxy")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(10)
                .background(Color(.windowBackgroundColor).opacity(0.7))
                .cornerRadius(6)
                .padding(12)
            }
            Divider()
            List(geometry.rings) { ring in
                HStack {
                    Circle()
                        .fill(Color(NSColor(hexString: ring.colorHex)))
                        .frame(width: 12, height: 12)
                    VStack(alignment: .leading) {
                        Text(ring.name).font(.caption.bold())
                        Text("\(ring.plainName) · \(ring.material)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("r \(Int(ring.innerRadiusMM))–\(Int(ring.outerRadiusMM)) mm")
                        .font(.caption2.monospaced())
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            .frame(height: 180)
        }
    }
}

// MARK: - Annulus mesh

/// Build a hollow tube (annulus extruded along Y) with proper inner /
/// outer / cap normals so neighbouring rings don't z-fight and the
/// inner surface is visible through translucent outer shells.
///
/// `innerRadius == 0` collapses cleanly to a solid disk (the inner
/// strip degenerates to a line — the renderer drops zero-area
/// triangles).
private extension MeshResource {
    static func generateAnnulus(
        height: Float,
        innerRadius: Float,
        outerRadius: Float,
        segments: Int
    ) -> MeshResource {
        var positions: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        let halfH = height * 0.5
        let n = max(segments, 8)

        // ── outer side: outward normals
        let outerSideBase = UInt32(positions.count)
        for k in 0...n {
            let t = Float(k) / Float(n) * 2 * .pi
            let cx = cos(t), cz = sin(t)
            positions.append(SIMD3(outerRadius * cx, -halfH, outerRadius * cz))
            normals.append(SIMD3(cx, 0, cz))
            positions.append(SIMD3(outerRadius * cx, +halfH, outerRadius * cz))
            normals.append(SIMD3(cx, 0, cz))
        }
        for k in 0..<n {
            let b0 = outerSideBase + UInt32(k * 2)
            let t0 = b0 + 1
            let b1 = b0 + 2
            let t1 = b0 + 3
            indices.append(contentsOf: [b1, t0, b0])
            indices.append(contentsOf: [b1, t1, t0])
        }

        // ── inner side: inward normals, reversed winding
        let innerSideBase = UInt32(positions.count)
        for k in 0...n {
            let t = Float(k) / Float(n) * 2 * .pi
            let cx = cos(t), cz = sin(t)
            positions.append(SIMD3(innerRadius * cx, -halfH, innerRadius * cz))
            normals.append(SIMD3(-cx, 0, -cz))
            positions.append(SIMD3(innerRadius * cx, +halfH, innerRadius * cz))
            normals.append(SIMD3(-cx, 0, -cz))
        }
        for k in 0..<n {
            let b0 = innerSideBase + UInt32(k * 2)
            let t0 = b0 + 1
            let b1 = b0 + 2
            let t1 = b0 + 3
            indices.append(contentsOf: [b0, t0, b1])
            indices.append(contentsOf: [t0, t1, b1])
        }

        // ── top cap (y = +halfH, normal +Y), annular ring
        let topCapBase = UInt32(positions.count)
        for k in 0...n {
            let t = Float(k) / Float(n) * 2 * .pi
            let cx = cos(t), cz = sin(t)
            positions.append(SIMD3(outerRadius * cx, +halfH, outerRadius * cz))
            normals.append(SIMD3(0, 1, 0))
            positions.append(SIMD3(innerRadius * cx, +halfH, innerRadius * cz))
            normals.append(SIMD3(0, 1, 0))
        }
        for k in 0..<n {
            let o0 = topCapBase + UInt32(k * 2)
            let i0 = o0 + 1
            let o1 = o0 + 2
            let i1 = o0 + 3
            indices.append(contentsOf: [o0, o1, i0])
            indices.append(contentsOf: [i0, o1, i1])
        }

        // ── bottom cap (y = -halfH, normal -Y), reversed winding
        let botCapBase = UInt32(positions.count)
        for k in 0...n {
            let t = Float(k) / Float(n) * 2 * .pi
            let cx = cos(t), cz = sin(t)
            positions.append(SIMD3(outerRadius * cx, -halfH, outerRadius * cz))
            normals.append(SIMD3(0, -1, 0))
            positions.append(SIMD3(innerRadius * cx, -halfH, innerRadius * cz))
            normals.append(SIMD3(0, -1, 0))
        }
        for k in 0..<n {
            let o0 = botCapBase + UInt32(k * 2)
            let i0 = o0 + 1
            let o1 = o0 + 2
            let i1 = o0 + 3
            indices.append(contentsOf: [o0, i0, o1])
            indices.append(contentsOf: [i0, i1, o1])
        }

        var descriptor = MeshDescriptor(name: "hts_annulus")
        descriptor.positions = MeshBuffer(positions)
        descriptor.normals = MeshBuffer(normals)
        descriptor.primitives = .triangles(indices)
        return try! MeshResource.generate(from: [descriptor])
    }

    /// Build a helix tube — the HTS coil winding — as a single mesh.
    ///
    /// The helix path lives on a cylinder of radius `pathRadius`,
    /// axially spanning [-height/2, +height/2], with `turns` full
    /// revolutions. The wire's circular cross-section has radius
    /// `tubeRadius`. `pathSegments` controls path resolution;
    /// `tubeSegments` controls cross-section resolution.
    static func generateHelixTube(
        pathRadius: Float,
        tubeRadius: Float,
        height: Float,
        turns: Float,
        pathSegments: Int,
        tubeSegments: Int
    ) -> MeshResource {
        var positions: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        let twoPi: Float = 2.0 * .pi
        let halfH = height * 0.5
        let nPath = max(pathSegments, 16)
        let nTube = max(tubeSegments, 4)

        for i in 0...nPath {
            let t = Float(i) / Float(nPath)
            let theta = t * turns * twoPi
            let y = -halfH + t * height
            let cx = pathRadius * cos(theta)
            let cz = pathRadius * sin(theta)
            let center = SIMD3<Float>(cx, y, cz)
            // Helix tangent — d(center)/dt.
            let tangent = simd_normalize(SIMD3<Float>(
                -pathRadius * sin(theta) * turns * twoPi,
                height,
                pathRadius * cos(theta) * turns * twoPi))
            // Outward radial direction in the X-Z plane.
            let outward = simd_normalize(SIMD3<Float>(cx, 0, cz))
            // Binormal & corrected normal (Frenet-ish; outward picked
            // as reference to keep the cross-section consistently
            // oriented around the cylinder).
            let binormal = simd_normalize(simd_cross(tangent, outward))
            let normal = simd_normalize(simd_cross(binormal, tangent))
            // Cross-section ring around the helix path.
            for j in 0...nTube {
                let phi = Float(j) / Float(nTube) * twoPi
                let off = normal * cos(phi) + binormal * sin(phi)
                let pos = center + off * tubeRadius
                positions.append(pos)
                normals.append(simd_normalize(off))
            }
        }

        // Stitch triangles between consecutive cross-section rings.
        let M = UInt32(nTube + 1)
        for i in 0..<nPath {
            for j in 0..<nTube {
                let i0 = UInt32(i) * M + UInt32(j)
                let i1 = i0 + 1
                let i2 = i0 + M
                let i3 = i2 + 1
                indices.append(contentsOf: [i0, i2, i1])
                indices.append(contentsOf: [i1, i2, i3])
            }
        }

        var d = MeshDescriptor(name: "hts_helix_tube")
        d.positions = MeshBuffer(positions)
        d.normals = MeshBuffer(normals)
        d.primitives = .triangles(indices)
        return try! MeshResource.generate(from: [d])
    }
}

// Convenience: hex → NSColor (mirror of ComponentView3D's helper if any).
private extension NSColor {
    convenience init(hexString: String) {
        var s = hexString
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8)  & 0xFF) / 255.0
        let b = CGFloat( rgb        & 0xFF) / 255.0
        self.init(srgbRed: r, green: g, blue: b, alpha: 1.0)
    }
}
