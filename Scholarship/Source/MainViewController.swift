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
    
    // MARK: - Public variables
    
    let manager = SceneManager.shared

    // MARK: - Overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.setup(scene: ARSCNView(frame: self.view.frame), host: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager.runSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        manager.pauseSession()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        manager.hitTest(touches, with: event)
    }
}
