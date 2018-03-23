//
//  SceneManager.swift
//  Scholarship
//
//  Created by Marcos Aires Borges on 20/03/2018.
//  Copyright © 2018 Marcos Aires Borges. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class SceneManager: NSObject, ARSCNViewDelegate {
    
    // MARK: - Public variables
    
    static let shared = SceneManager()
    var showItems: Bool = false
    
    // MARK: - Public variables
    
    var detectedPlane: ARPlaneAnchor?
    var shouldDetectPlane: Bool = true
    
    // MARK: - Private variables
    
    private var sceneView: ARSCNView?
    private var x: Float = 0
    private var y: Float = 0
    private var z: Float = 0
    private let ambientLight = SCNLight()
    private let directionalLight = SCNLight()
//    private var camera: SCNCamera?
    
    private var animationData: [String: [String]] = [:]
    private var allNodes: [SCNNode] = []
    
    // MARK: - Initialization
    
    private override init() { super.init() }
    
    // MARK: - Public methods -----------------------------------------------------
    
    func setup(scene: ARSCNView, host: UIViewController) {
        sceneView = scene
        sceneView?.delegate = self
        
        guard let sView = sceneView else { return }
        host.view.addSubview(sView)
        
        let scene = SCNScene()
        sceneView?.scene = scene
        
        sceneView?.showsStatistics = true
        sceneView?.automaticallyUpdatesLighting = true
        sceneView?.preferredFramesPerSecond = 60
        sceneView?.autoenablesDefaultLighting = true
//        sceneView?.debugOptions  = [.showConstraints,
//                                    .showLightExtents,
//                                    ARSCNDebugOptions.showFeaturePoints,
//                                    ARSCNDebugOptions.showWorldOrigin]
        
//        self.camera = sceneView?.scene.rootNode.camera
        setupLights()
    }
    
    func runSession() {
        sceneView?.session.run(getSessionConfiguration())
    }
    
    func pauseSession() {
        sceneView?.session.pause()
    }
    
    func loadAllGeometry() {
        for name in daeNames {
            
            let fileName = daeBaseUrl + name + "." + daeExtension
            guard let scene = SCNScene(named: fileName) else { return }
            let node = SCNNode()

            for child in scene.rootNode.childNodes {
                
                // to play DAE animation just once
                for key in child.animationKeys {
                    if let player = child.animationPlayer(forKey: key) {
                        player.animation.repeatCount = 1
                        player.animation.isRemovedOnCompletion = false
                    }
                }
                
                setupBaseColor(node: child)
                node.addChildNode(child)
            }
            
            node.position = SCNVector3(0, self.y + 0.01, -1)
            node.scale = SCNVector3(0.5, 0.5, 0.5)
            
            sceneView?.scene.rootNode.addChildNode(node)
            allNodes.append(node)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    // Animations
    //----------------------------------------------------------------------------------------------------------
    
    func loadAnimations(node: SCNNode, name: String) {
        
        var names: [String] = []
        for child in node.childNodes {
            for animationKey in child.animationKeys {
                names.append(animationKey)
            }
        }
        
        animationData[name] = names
    }
    
    func playAnimations(node: SCNNode) {
        guard let group = getNodeGroup(node: node) else { return }
        for innerNode in group {
            runAnimation(node: innerNode, reverse: false, speed: 1.0)
        }
    }
    
    func reverseAnimations(node: SCNNode) {
        guard let group = getNodeGroup(node: node) else { return }
        for innerNode in group {
            runAnimation(node: innerNode, reverse: true, speed: 2.0)
        }
    }
    
    func pauseAnimations(node: SCNNode) {
        guard let group = getNodeGroup(node: node) else { return }
        for innerNode in group {
            innerNode.isPaused = true
        }
    }
    
    func resumeAnimations(node: SCNNode) {
        guard let group = getNodeGroup(node: node) else { return }
        for innerNode in group {
            innerNode.isPaused = false
        }
    }
    
    func runAnimation(node: SCNNode, reverse: Bool, speed: CGFloat) {
        for aKey in node.animationKeys {
            let animationPlayer = node.animationPlayer(forKey: aKey)
            animationPlayer?.speed = speed
            animationPlayer?.animation.repeatCount = 1
            animationPlayer?.animation.autoreverses = reverse
            animationPlayer?.animation.isRemovedOnCompletion = false
            animationPlayer?.play()
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    // hit test
    //----------------------------------------------------------------------------------------------------------
    
    func hitTest(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        // Let's test if a 3D Object was touched
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        guard let hitResults: [SCNHitTestResult]  = sceneView?.hitTest(location, options: hitTestOptions) else { return }
        
        if let node = hitResults.first?.node {
            
            if node == detectedPlane {
                shouldDetectPlane = false
            }
            
            nodeDidTouch(node: node)
            return
        }
    }
    
    func nodeDidTouch(node: SCNNode) {
        setupColors(node: node, color: colorToChange)
        reverseAnimations(node: node)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.setupColors(node: node, color: baseColor)
            self.playAnimations(node: node)
        })
    }
    
    func getNodeGroup(node: SCNNode) -> [SCNNode]? {
        guard let parent = node.parent, parent != sceneView?.scene.rootNode else { return nil }
        return parent.childNodes
    }

    // MARK: - Private methods -----------------------------------------------------
    
    private func getSessionConfiguration() -> ARConfiguration {
        if ARWorldTrackingConfiguration.isSupported {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.isLightEstimationEnabled = true
            return configuration;
        } else {
            // Slightly less immersive AR experience due to lower end processor
            return AROrientationTrackingConfiguration()
        }
    }
    
    private func setupLights() {
        directionalLight.type = .directional
        directionalLight.intensity = 100
        directionalLight.castsShadow = true
        directionalLight.shadowRadius = 16
        directionalLight.shadowMode = .deferred
        directionalLight.shadowColor = UIColor(white: 0.0, alpha: 0.5)
        directionalLight.automaticallyAdjustsShadowProjection = true
        directionalLight.shadowSampleCount = 64
        directionalLight.shadowRadius = 16
        directionalLight.shadowMode = .deferred
        directionalLight.shadowMapSize = CGSize(width: 2048, height: 2048)
        
        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.position = SCNVector3(0, 2, 0)
        directionalNode.eulerAngles = SCNVector3(-Float.pi/2,0,0)
        
        ambientLight.type = .ambient
        ambientLight.intensity = 0.40
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        
        sceneView?.scene.rootNode.addChildNode(directionalNode)
        sceneView?.scene.rootNode.addChildNode(ambientNode)
    }
    
    private func setupBaseColor(node: SCNNode) {
        changeColor(node: node, color: baseColor)
    }
    
    private func setupColors(node: SCNNode, color: UIColor) {
        guard let group = getNodeGroup(node: node) else { return }
        for innerNode in group {
            changeColor(node: innerNode, color: color)
        }
    }
    
    private func changeColor(node: SCNNode, color: UIColor) {
        let material = SCNMaterial()
        material.lightingModel = .phong
        material.diffuse.contents = color
        material.emission.contents = color
        material.emission.intensity = 0.5
        
        // Add material to the cube node
        node.geometry?.materials = [material]
    }
    
    
    // MARK: - ARSCNViewDelegate -----------------------------------------------------
    //----------------------------------------------------------------------------------------------------------
    // ARSCNViewDelegate
    //----------------------------------------------------------------------------------------------------------
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let lightEstimate = sceneView?.session.currentFrame?.lightEstimate else { return }
        self.ambientLight.intensity = lightEstimate.ambientIntensity / 8
        self.ambientLight.temperature = lightEstimate.ambientColorTemperature
        self.directionalLight.intensity = lightEstimate.ambientIntensity / 2
        self.directionalLight.temperature = lightEstimate.ambientColorTemperature
        
//        guard let root = sceneView?.scene.rootNode else { return }
//        let visibleNodes = renderer.nodesInsideFrustum(of: root)
//        renderer.isNode(<#T##node: SCNNode##SCNNode#>, insideFrustumOf: <#T##SCNNode#>)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                // For a first detected plane
                if !self.showItems {

                    let x = planeAnchor.center.x + node.position.x
                    let y = planeAnchor.center.y + node.position.y
                    let z = planeAnchor.center.z + node.position.z

                    self.x = x
                    self.y = y
                    self.z = z

                    self.loadAllGeometry()
                    self.showItems = true
                }
            }
        }
        
//        DispatchQueue.main.async {
//            if !self.showItems {
//                self.loadAllGeometry()
//                self.showItems = true
//            }
//        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        var node:  SCNNode?
        if let planeAnchor = anchor as? ARPlaneAnchor {
            node = SCNNode()
            // let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeGeometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeHeight), length: CGFloat(planeAnchor.extent.z), chamferRadius: 0.0)
            planeGeometry.firstMaterial?.diffuse.contents = UIColor.green
            planeGeometry.firstMaterial?.specular.contents = UIColor.white
            let planeNode = SCNNode(geometry: planeGeometry)
            planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight / 2), planeAnchor.center.z)
            //since SCNPlane is vertical, needs to be rotated -90 degrees on X axis to make a plane //planeNode.transform = SCNMatrix4MakeRotation(Float(-CGFloat.pi/2), 1, 0, 0)
            node?.addChildNode(planeNode)
            
//            if shouldDetectPlane {
//                detectedPlane = planeAnchor
                return node
//            }
        }
        
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
//            if anchors.contains(planeAnchor) {
            if planeAnchor == detectedPlane {
                if node.childNodes.count > 0 {
                    let planeNode = node.childNodes.first!
                    planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight / 2), planeAnchor.center.z)
                    if let plane = planeNode.geometry as? SCNBox {
                        plane.width = CGFloat(planeAnchor.extent.x)
                        plane.length = CGFloat(planeAnchor.extent.z)
                        plane.height = CGFloat(planeHeight)
                    }
                }
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
