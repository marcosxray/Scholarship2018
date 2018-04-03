
import PlaygroundSupport
import UIKit

//: # ARKit Interactive Experience
//: ## Playground
//: This Swift playground demonstrates the use of ARKit and SceneKit to interact with 3D animated objects projected in the real world, through the device's camera viewpoint.
//: - This playground is best experienced when in fullscreen
//: - All 3D elements are interactive. You can touch them to see they changing color and animating
//: - The 3 orange buttons in the center of the scene show extra information about this project and about me.
//: - (1) Position your iPad's camera towards a plane surface (table, floor, etc) until you see green wireframe planes over it. Once you find a plane, touch it to project the AR content. (2) At this point, you'll be able to interact with all the 3D elements.

let vc = MainViewController()
PlaygroundPage.current.liveView = vc


