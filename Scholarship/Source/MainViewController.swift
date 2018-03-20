//
//  ViewController.swift
//  Scholarship
//
//  Created by Marcos Aires Borges on 19/03/2018.
//  Copyright © 2018 Marcos Aires Borges. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class MainViewController: UIViewController {
    
    var sceneView: ARSCNView!
    var animations = [String: CAAnimation]()
    var idle: Bool = true
    
    let ambientLight = SCNLight()
    let omniLight = SCNLight()
    
    var showItems: Bool = false
    private var x: Float = 0
    private var y: Float = 0
    private var z: Float = 0
    var anchors: [ARPlaneAnchor] = []
    let planeHeight = 0.01
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        self.sceneView.autoenablesDefaultLighting = true
        
        self.sceneView.debugOptions  = [.showConstraints,
                                        .showLightExtents,
                                        ARSCNDebugOptions.showFeaturePoints,
                                        ARSCNDebugOptions.showWorldOrigin
                                        ]
        //shows fps rate
        self.sceneView.showsStatistics = true
        self.sceneView.automaticallyUpdatesLighting = true
        self.sceneView.preferredFramesPerSecond = 60
        
        // Load the DAE animations
        //        loadAnimations()
        
        
        ////-------------------
        // light
        ////-------------------
        
        
        omniLight.type = .directional
        
        omniLight.intensity = 100
        omniLight.castsShadow = true
        omniLight.shadowRadius = 16
        omniLight.shadowMode = .deferred
        omniLight.shadowColor = UIColor.black
        omniLight.automaticallyAdjustsShadowProjection = true
        omniLight.shadowSampleCount = 64
        omniLight.shadowRadius = 16
        omniLight.shadowMode = .deferred
        omniLight.shadowMapSize = CGSize(width: 2048, height: 2048)
        
        let spotNode = SCNNode()
        spotNode.light = omniLight
        spotNode.position = SCNVector3(0, 2, 0)
        spotNode.eulerAngles = SCNVector3(-Float.pi/2,0,0)
        
        
        ambientLight.type = .ambient
        ambientLight.intensity = 0.40
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        
        
        sceneView.scene.rootNode.addChildNode(spotNode)
        sceneView.scene.rootNode.addChildNode(ambientNode)
        
        ////-------------------
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session
        sceneView.session.run(getSessionConfiguration())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let location = touches.first!.location(in: sceneView)
        
        // Let's test if a 3D Object was touched
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
        
        if let node = hitResults.first?.node {
            if(idle) {
//                playAnimation(key: "dancing")
                changeColor(node: node)
            } else {
//                stopAnimation(key: "dancing")
                changeColor(node: node)
            }
            idle = !idle
            return
        }
    }
    
    func changeColor(node: SCNNode) {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor.red
        
        // Add material to the cube node
        node.geometry?.materials = [material]
    }
    
    func loadAnimations() {
        
        // Load the character in the idle animation
        let idleScene = SCNScene(named: "art.scnassets/wwdc.DAE")!
        
        // This node will be parent of all the animation models
        let node = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        // Set up some properties
        node.position = SCNVector3(0, self.y + 0.01, -1)
        node.scale = SCNVector3(0.5, 0.5, 0.5)
        
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        
        // Load all the DAE animations
        //        loadAnimation(withKey: "dancing", sceneName: "art.scnassets/sobe", animationIdentifier: "keyframedAnimations1")
    }
    
    
    func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
        
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "DAE")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            // The animation will only play once
            animationObject.repeatCount = 0 // 1
            // To create smooth transitions between animations
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            // Store the animation for later use
            animations[withKey] = animationObject
        }
    }
    
    func playAnimation(key: String) {
        // Add the animation to start playing it right away
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
    //----------------------------------------------------------------------------------------
    
    
    
    func addGeometry() {
        loadAnimations()
    }
}

extension ViewController: ARSCNViewDelegate {
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let lightEstimate = sceneView.session.currentFrame?.lightEstimate else { return }

        self.ambientLight.intensity = lightEstimate.ambientIntensity / 10
        self.ambientLight.temperature = lightEstimate.ambientColorTemperature
        
        self.omniLight.intensity = lightEstimate.ambientIntensity / 2
        self.omniLight.temperature = lightEstimate.ambientColorTemperature
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // We need async execution to get anchor node's position relative to the root
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                // For a first detected plane
                if !self.showItems {
                    // get center of the plane
                    let x = planeAnchor.center.x + node.position.x
                    let y = planeAnchor.center.y + node.position.y
                    let z = planeAnchor.center.z + node.position.z
                    
                    self.x = x
                    self.y = y
                    self.z = z
                    
                    self.addGeometry()
                    self.showItems = true
                    
//                    self.sceneView.scene.rootNode.addChildNode(node)
//                    node.geometry = SCNGeometry
                    /////
                    

//                    let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.y))// [SCNPlane planeWithWidth:anchor.extent.x height:anchor.extent.z];
//                    let planeNode = SCNNode(geometry: plane)
//                    //                    SCNNode *planeNode = [SCNNode nodeWithGeometry:self.planeGeometry];
//                    // Move the plane to the position reported by ARKit
//                    planeNode.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z);
//                    // Planes in SceneKit are vertical by default so we need to rotate
//                    // 90 degrees to match planes in ARKit
//                    planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);
//                    // We add the new node to ourself since we inherited from SCNNode
//
//                    self.sceneView.scene.rootNode.addChildNode(planeNode)

                    
                    
                    /////
                }
            }
        }
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
            anchors.append(planeAnchor)
        } else {
            // haven't encountered this scenario yet
            print("not plane anchor \(anchor)")
        }
        return node
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            if anchors.contains(planeAnchor) {
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
