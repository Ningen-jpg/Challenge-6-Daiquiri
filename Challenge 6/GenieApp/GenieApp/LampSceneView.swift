import SwiftUI
import SceneKit

struct LampSceneView: UIViewRepresentable {
    @Binding var rubCount: Int
    @Binding var genieAppeared: Bool
    @Binding var showQuote: Bool
    @Binding var currentQuote: String
    
    let quotes: [String]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        let scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.backgroundColor = .clear
        sceneView.isOpaque = false
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false
        
        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 1.2, 8)
        scene.rootNode.addChildNode(cameraNode)
        
        // Main light
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.intensity = 900
        lightNode.position = SCNVector3(0, 5, 8)
        scene.rootNode.addChildNode(lightNode)
        
        // Ambient light
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.light?.intensity = 500
        scene.rootNode.addChildNode(ambientNode)
        
        // Lamp
        let lampNode = makeLampNode()
        lampNode.name = "lamp"
        lampNode.position = SCNVector3(0, -1.0, 0)
        scene.rootNode.addChildNode(lampNode)
        
        // Genie
        let genieNode = makeGenieNode()
        genieNode.name = "genie"
        genieNode.position = SCNVector3(0, -1.1, 0)
        genieNode.opacity = 0.0
        genieNode.scale = SCNVector3(0.75, 0.75, 0.75)
        scene.rootNode.addChildNode(genieNode)
        
        // Paper
        let paperNode = makePaperNode()
        paperNode.name = "paper"
        paperNode.position = SCNVector3(0, 1.0, 0.2)
        paperNode.opacity = 0.0
        genieNode.addChildNode(paperNode)
        
        context.coordinator.sceneView = sceneView
        
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        sceneView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        sceneView.addGestureRecognizer(tapGesture)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene else { return }
        
        if genieAppeared,
           let genieNode = scene.rootNode.childNode(withName: "genie", recursively: true),
           genieNode.opacity == 0.0 {
            
            let moveUp = SCNAction.move(to: SCNVector3(0, 0.45, 0), duration: 1.2)
            let fadeIn = SCNAction.fadeIn(duration: 0.9)
            let scaleUp = SCNAction.scale(to: 1.0, duration: 1.2)
            let revealGroup = SCNAction.group([moveUp, fadeIn, scaleUp])
            
            genieNode.runAction(revealGroup)
            
            let floatUp = SCNAction.moveBy(x: 0, y: 0.08, z: 0, duration: 1.2)
            let floatDown = SCNAction.moveBy(x: 0, y: -0.08, z: 0, duration: 1.2)
            let floating = SCNAction.repeatForever(.sequence([floatUp, floatDown]))
            
            genieNode.runAction(.sequence([
                .wait(duration: 1.2),
                floating
            ]))
            
            if let paperNode = genieNode.childNode(withName: "paper", recursively: true) {
                let delay = SCNAction.wait(duration: 1.0)
                let reveal = SCNAction.fadeIn(duration: 0.4)
                paperNode.runAction(.sequence([delay, reveal]))
            }
        }
    }
    
    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) {
        uiView.gestureRecognizers?.forEach { uiView.removeGestureRecognizer($0) }
    }
    
    class Coordinator: NSObject {
        var parent: LampSceneView
        weak var sceneView: SCNView?
        private var rubDirection: CGFloat = 0
        
        init(_ parent: LampSceneView) {
            self.parent = parent
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let sceneView = sceneView,
                  let scene = sceneView.scene,
                  !parent.genieAppeared else { return }
            
            let translation = gesture.translation(in: sceneView)
            
            if let lampNode = scene.rootNode.childNode(withName: "lamp", recursively: true) {
                let rotation = Float(translation.x) * 0.0015
                lampNode.eulerAngles.y = rotation
            }
            
            if gesture.state == .changed {
                let currentDirection: CGFloat = translation.x > 0 ? 1 : -1
                
                if rubDirection != 0 && currentDirection != rubDirection {
                    parent.rubCount += 1
                    
                    if parent.rubCount >= 6 {
                        parent.genieAppeared = true
                    }
                }
                
                rubDirection = currentDirection
            }
            
            if gesture.state == .ended {
                rubDirection = 0
                gesture.setTranslation(.zero, in: sceneView)
            }
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = sceneView,
                  let rootNode = sceneView.scene?.rootNode else { return }
            
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: nil)
            
            if let firstHit = hitResults.first,
               parent.genieAppeared,
               firstHit.node.name == "paper" {
                
                parent.currentQuote = parent.quotes.randomElement() ?? "Believe in yourself."
                parent.showQuote = true
                
                if let paperNode = rootNode.childNode(withName: "paper", recursively: true) {
                    let pulseUp = SCNAction.scale(to: 1.08, duration: 0.12)
                    let pulseDown = SCNAction.scale(to: 1.0, duration: 0.12)
                    paperNode.runAction(.sequence([pulseUp, pulseDown]))
                }
            }
        }
    }
}

func makeLampNode() -> SCNNode {
    let lampRoot = SCNNode()
    
    let goldColor = UIColor(
        red: 212/255,
        green: 160/255,
        blue: 23/255,
        alpha: 1.0
    )
    
    let base = SCNSphere(radius: 0.8)
    base.firstMaterial?.diffuse.contents = goldColor
    base.firstMaterial?.specular.contents = UIColor.white
    
    let baseNode = SCNNode(geometry: base)
    baseNode.scale = SCNVector3(1.4, 0.5, 0.8)
    baseNode.position = SCNVector3(0, -0.5, 0)
    lampRoot.addChildNode(baseNode)
    
    let neck = SCNCylinder(radius: 0.18, height: 0.9)
    neck.firstMaterial?.diffuse.contents = goldColor
    neck.firstMaterial?.specular.contents = UIColor.white
    
    let neckNode = SCNNode(geometry: neck)
    neckNode.position = SCNVector3(0.45, 0.0, 0)
    neckNode.eulerAngles.z = -.pi / 4
    lampRoot.addChildNode(neckNode)
    
    let spout = SCNCone(topRadius: 0.02, bottomRadius: 0.12, height: 0.4)
    spout.firstMaterial?.diffuse.contents = goldColor
    spout.firstMaterial?.specular.contents = UIColor.white
    
    let spoutNode = SCNNode(geometry: spout)
    spoutNode.position = SCNVector3(0.9, 0.35, 0)
    spoutNode.eulerAngles.z = -.pi / 3
    lampRoot.addChildNode(spoutNode)
    
    return lampRoot
}

func makeGenieNode() -> SCNNode {
    let genieRoot = SCNNode()
    
    let plane = SCNPlane(width: 2.0, height: 3.2)
    
    let material = SCNMaterial()
    material.diffuse.contents = UIImage(named: "genieCharacter")
    material.isDoubleSided = true
    material.lightingModel = .constant
    material.writesToDepthBuffer = false
    material.readsFromDepthBuffer = false
    
    plane.materials = [material]
    
    let genieImageNode = SCNNode(geometry: plane)
    genieImageNode.position = SCNVector3(0, 1.1, 0)
    
    genieRoot.addChildNode(genieImageNode)
    return genieRoot
}

func makePaperNode() -> SCNNode {
    let paper = SCNPlane(width: 1.45, height: 0.85)
    
    paper.firstMaterial?.diffuse.contents = UIColor(
        red: 244/255,
        green: 227/255,
        blue: 188/255,
        alpha: 1.0
    )
    paper.firstMaterial?.isDoubleSided = true
    paper.firstMaterial?.lightingModel = .lambert
    
    let paperNode = SCNNode(geometry: paper)
    paperNode.eulerAngles.x = -.pi / 14
    
    return paperNode
}
