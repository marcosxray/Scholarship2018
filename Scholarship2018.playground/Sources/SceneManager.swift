
import UIKit
import SceneKit
import ARKit

public class SceneManager: NSObject, ARSCNViewDelegate {
    
    // MARK: - Public variables
    
    static let shared = SceneManager()
    weak var delegate: ButtonDelegate?
    var showingItems: Bool = false
    
    var transparentFloor: Bool = true {
        didSet {
            guard let fNode = floorNode?.childNodes.first else { return }
            if transparentFloor {
                changeMaterial(node: fNode, material: getTransparentMaterial())
            } else {
                changeColor(node: fNode, bitmap: UIImage(named: "floor"))
            }
        }
    }
    
    // MARK: - Private variables
    
    private var sceneView: ARSCNView?
    private let ambientLight = SCNLight()
    private let directionalLight = SCNLight()
    private var shouldDetectPlane: Bool = true
    private var floorNode: SCNNode?
    private var referencePosition = SCNVector3()
    private var referenceScale = SCNVector3(1, 1, 1)
    private var referenceEulerRotation = SCNVector3()
    private var referenceNode = SCNNode()
    private var detectedPlaneNodes: [SCNNode] = []
    private var buttonNodes: [SCNNode] = []
    
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
        
        sceneView?.automaticallyUpdatesLighting = true
        sceneView?.preferredFramesPerSecond = 60
        sceneView?.autoenablesDefaultLighting = true
        
        setupLights()
    }
    
    func runSession() {
        sceneView?.session.run(getSessionConfiguration())
    }
    
    func pauseSession() {
        sceneView?.session.pause()
    }
    
    func stopAllButtonNodes() {
        for node in buttonNodes {
            freezeAnimationOnFirstKeyframe(node: node)
        }
    }
    
    // MARK: - Private methods -----------------------------------------------------
    
    private func loadAllGeometry() {
        for name in daeNames {
            
            let fileName = name + "." + scnExtension
            guard let scene = SCNScene(named: fileName) else { return }
            let node = SCNNode()
            node.name = name

            for child in scene.rootNode.childNodes {
                
                for key in child.animationKeys {
                    if let player = child.animationPlayer(forKey: key) {
                        player.animation.repeatCount = 1
                        player.animation.isRemovedOnCompletion = false
                        player.animation.usesSceneTimeBase = false
                        player.play()
                    }
                }
                
                node.addChildNode(child)
                setupBaseColor(node: child)
            }
            
            if name == "pole1" || name == "pole2" || name == "pole3" {
                buttonNodes.append(node)
            }
            
            if name == "floor" {
                if let refGeo = referenceNode.geometry, let floorGeo = node.childNodes.first?.geometry {
                    let scaleFactorX = refGeo.boundingBox.max.x / (floorGeo.boundingBox.max.x * 0.025)
                    let scaleFactorY = refGeo.boundingBox.max.z / (floorGeo.boundingBox.max.y * 0.025)
                    let scaleFactor = min(scaleFactorX, scaleFactorY)
                    
                    self.referenceScale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
                    floorNode = node

                    node.castsShadow = false
                    if let firstNode = node.childNodes.first {
                        firstNode.geometry?.materials = [getTransparentMaterial()]
                    }
                }
            }
            
            node.position = referencePosition
            node.scale = referenceScale
            node.eulerAngles = referenceEulerRotation
            node.eulerAngles.y += rotationFactor
            sceneView?.scene.rootNode.addChildNode(node)
        }
    }
    
    private func getTransparentMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .lambert
        material.diffuse.contents = UIColor.white
        material.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        material.blendMode = .multiply
        return material
    }
    
    private func isNodeSpecial(node: SCNNode) -> Bool {
        guard let name = node.name else { return false }
        return name == "pole1" || name == "pole2" || name == "pole3" || name == "basePoles"
    }
    
    private func isParentNodeSpecial(node: SCNNode) -> Bool {
        guard let parent = node.parent else { return false }
        return isNodeSpecial(node:parent)
    }
    
    private func isParentNodeButton(node: SCNNode) -> Bool {
        guard let parent = node.parent else { return false }
        guard let name = parent.name else { return false }
        return name == "pole1" || name == "pole2" || name == "pole3"
    }
    
    private func removePlaneNodes() {
        for node in detectedPlaneNodes {
            node.removeFromParentNode()
        }
    }
    
    private func getSessionConfiguration() -> ARConfiguration {
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.isLightEstimationEnabled = true
            return configuration;
        } else {
            return AROrientationTrackingConfiguration()
        }
    }
    
    private func setupLights() {
        changeDirectionalLight(light: directionalLight)
        let directionalNode1 = SCNNode()
        directionalNode1.light = directionalLight
        directionalNode1.position = SCNVector3(0, 2, 0)
        directionalNode1.eulerAngles = SCNVector3(-Float.pi/2,0,0)
        sceneView?.scene.rootNode.addChildNode(directionalNode1)
        
        ambientLight.type = .ambient
        ambientLight.intensity = 0.40
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        
        sceneView?.scene.rootNode.addChildNode(ambientNode)
    }
    
    private func changeDirectionalLight(light: SCNLight) {
        light.type = .directional
        light.intensity = 100
        light.castsShadow = true
        light.shadowRadius = 16
        light.shadowMode = .deferred
        light.shadowColor = UIColor(white: 0.0, alpha: 0.7)
        light.automaticallyAdjustsShadowProjection = true
        light.shadowSampleCount = 128
        light.shadowRadius = 12
        light.shadowMode = .deferred
        light.shadowMapSize = CGSize(width: 2048, height: 2048)
    }
    
    private func setupBaseColor(node: SCNNode) {
        changeColor(node: node, color: UIColor.baseColor)
    }
    
    private func setupColors(node: SCNNode, color: UIColor) {
        guard let group = getNodeGroup(node: node) else { return }
        for innerNode in group {
            changeColor(node: innerNode, color: color)
        }
    }

    private func changeColor(node: SCNNode, color: UIColor? = nil, bitmap: UIImage? = nil) {
        guard !isParentNodeSpecial(node: node) else { return }
        let material = SCNMaterial()
        material.lightingModel = .phong
        
        if let selectedColor = color {
            material.diffuse.contents = selectedColor
            material.diffuse.intensity = 1
            material.emission.contents = selectedColor
            material.emission.intensity = 0.55
        }
        
        if let image = bitmap {
            material.diffuse.contents = image
            material.diffuse.intensity = 1
            material.emission.contents = image
            material.emission.intensity = 0.55
        }
        
        material.reflective.contents = UIImage(named: "reflection.jpg")
        material.reflective.intensity = 0.2
        
        
        material.isDoubleSided = true
        changeMaterial(node: node, material: material)
    }
    
    private func changeMaterial(node: SCNNode, material: SCNMaterial) {
        node.geometry?.materials = [material]
    }
    
    //----------------------------------------------------------------------------------------------------------
    // Animations
    //----------------------------------------------------------------------------------------------------------
    
    private func loadAnimations(node: SCNNode, name: String) {
        var names: [String] = []
        for child in node.childNodes {
            for animationKey in child.animationKeys {
                names.append(animationKey)
            }
        }
    }
    
    private func freezeAnimationOnFirstKeyframe(node: SCNNode) {
        for innerNode in node.childNodes {
            for aKey in innerNode.animationKeys {
                let animationPlayer = innerNode.animationPlayer(forKey: aKey)
                animationPlayer?.animation.repeatCount = 1
                animationPlayer?.animation.autoreverses = true
                animationPlayer?.animation.isRemovedOnCompletion = false
                animationPlayer?.speed = 100
                animationPlayer?.play()
            }
        }
    }
    
    private func playAnimations(node: SCNNode) {
        guard let group = getNodeGroup(node: node) else { return }
        for innerNode in group {
            runAnimation(node: innerNode, reverse: false, speed: 1.0)
        }
    }
    
    private func reverseAnimations(node: SCNNode) {
        guard let group = getNodeGroup(node: node) else { return }
        for innerNode in group {
            runAnimation(node: innerNode, reverse: true, speed: 2.0)
        }
    }
    
    private func pauseAnimations(node: SCNNode) {
        guard let group = getNodeGroup(node: node) else { return }
        for innerNode in group {
            innerNode.isPaused = true
        }
    }
    
    private func resumeAnimations(node: SCNNode) {
        guard let group = getNodeGroup(node: node) else { return }
        for innerNode in group {
            innerNode.isPaused = false
        }
    }
    
    private func runAnimation(node: SCNNode, reverse: Bool, speed: CGFloat) {
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
        
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        guard let hitResults: [SCNHitTestResult]  = sceneView?.hitTest(location, options: hitTestOptions) else { return }
        guard let first = hitResults.first else { return }
        let node = first.node
        let position = node.worldPosition
        let transform = first.modelTransform
        
        if let geometry = node.geometry, geometry.isKind(of: SCNBox.self) {
            DispatchQueue.main.async {
                if !(self.showingItems) {
                    
                    // position
                    self.referencePosition =  SCNVector3(position.x, position.y + 0.01, position.z)
                    
                    // rotation
                    let n = SCNNode()
                    n.transform = transform
                    self.referenceEulerRotation = n.eulerAngles
                    
                    // node
                    self.referenceNode = node
                    
                    self.showingItems = true
                    self.shouldDetectPlane = false
                    self.removePlaneNodes()
                    self.loadAllGeometry()
                    self.stopAllButtonNodes()
                    self.delegate?.sessionDidRun()
                }
            }
        } else {
            
            guard let fNode = floorNode?.childNodes.first, fNode != node else { return }
            nodeDidTouch(node: node)
        }
    }
    
    private func nodeDidTouch(node: SCNNode) {
        if isParentNodeButton(node: node) {
            self.stopAllButtonNodes()
            self.playAnimations(node: node)
            
            if let name = node.parent?.name {
                switch name {
                case "pole1":
                    delegate?.buttonDidTouch(type: .project)
                case "pole2":
                    delegate?.buttonDidTouch(type: .bio)
                case "pole3":
                    delegate?.buttonDidTouch(type: .country)
                default:
                    break
                }
            }
        } else {
            setupColors(node: node, color: UIColor.colorToChange)
            reverseAnimations(node: node)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.setupColors(node: node, color: UIColor.baseColor)
                self.playAnimations(node: node)
            })
        }
    }
    
    private func getNodeGroup(node: SCNNode) -> [SCNNode]? {
        guard let parent = node.parent, parent != sceneView?.scene.rootNode else { return nil }
        return parent.childNodes
    }
    
    //----------------------------------------------------------------------------------------------------------
    // ARSCNViewDelegate
    //----------------------------------------------------------------------------------------------------------
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let lightEstimate = sceneView?.session.currentFrame?.lightEstimate else { return }
        self.ambientLight.intensity = lightEstimate.ambientIntensity / 12
        self.ambientLight.temperature = lightEstimate.ambientColorTemperature
        self.directionalLight.intensity = lightEstimate.ambientIntensity / 8
        self.directionalLight.temperature = lightEstimate.ambientColorTemperature
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let planeAnchor = anchor as? ARPlaneAnchor, shouldDetectPlane {
            let planeGeometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeHeight), length: CGFloat(planeAnchor.extent.z), chamferRadius: 0.0)
            planeGeometry.firstMaterial?.diffuse.contents = UIColor.detectedPlaneColor
            planeGeometry.firstMaterial?.specular.contents = UIColor.white
            planeGeometry.firstMaterial?.fillMode = .lines
            planeGeometry.firstMaterial?.lightingModel = .constant
            
            let planeNode = SCNNode(geometry: planeGeometry)
            planeNode.castsShadow = false

            if self.shouldDetectPlane {
                return planeNode
            }
        }
        
        return nil
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let _ = anchor as? ARPlaneAnchor {
            detectedPlaneNodes.append(node)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            if node.childNodes.count > 0 {
                let planeNode = node.childNodes.first!
                planeNode.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
                
                if let plane = planeNode.geometry as? SCNBox {
                    plane.width = CGFloat(planeAnchor.extent.x)
                    plane.length = CGFloat(planeAnchor.extent.z)
                    plane.height = CGFloat(planeHeight)
                }
            }
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        delegate?.sessionDidFail(error: error as NSError)
    }
}
