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

enum ButtonType {
    case project
    case bio
    case country
}

protocol ButtonDelegate: NSObjectProtocol {
    func buttonDidTouch(type: ButtonType)
    func sessionDidRun()
    func sessionDidFail(error: NSError)
}

class MainViewController: UIViewController, ButtonDelegate {
    
    // MARK: - Public variables
    
    let manager = SceneManager.shared
    var floorButton: UIButton!
    var boardView: BoardView?
    var welcomeDidShow = false
    var transparentFloor: Bool = true {
        didSet {
            manager.transparentFloor = transparentFloor
        }
    }

    // MARK: - Overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.darkGray
        manager.delegate = self
        manager.setup(scene: ARSCNView(frame: self.view.frame), host: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !welcomeDidShow {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                let vc = WelcomeViewController()
                self.show(vc, sender: nil)
                self.welcomeDidShow = true
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager.pauseSession()
        super.viewWillDisappear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        manager.hitTest(touches, with: event)
    }
    
    // MARK: - Private merthods
    
    private func setupFloorButton() {
        let margins = self.view.layoutMarginsGuide
        
        floorButton = UIButton(frame: CGRect(x: 100, y: 200, width: 150, height: 80))
        changeFloorButtonImage()
        
        floorButton.addTarget(self, action: #selector(floorButtonDidTouch), for: .touchUpInside)
        floorButton.layer.cornerRadius = 20
        view.addSubview(floorButton)

        floorButton.translatesAutoresizingMaskIntoConstraints = false
        floorButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20.0).isActive = true
        floorButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20.0).isActive = true
        floorButton.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        floorButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
    }
    
    @objc private func floorButtonDidTouch() {
        transparentFloor = transparentFloor ? false : true
        changeFloorButtonImage()
    }
    
    private func changeFloorButtonImage() {
        let image = transparentFloor ? UIImage(named: "floorOff") : UIImage(named: "floorOn")
        floorButton.setImage(image, for: .normal)
    }
    
    private func showInfo(title: String, txt: String) {
        let margins = self.view.layoutMarginsGuide

        let startFrame = CGRect(x: 40, y: 1000, width: self.view.bounds.size.width / 2, height: 100)
        self.boardView = BoardView(frame: startFrame, title: title, txt: txt, image: nil, buttonTitle: "CLOSE") {
            self.boardView?.removeFromSuperview()
        }
        
        guard let _ = boardView else { return }
        self.view.addSubview(boardView!)
        
        boardView?.translatesAutoresizingMaskIntoConstraints = false
        boardView?.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20.0).isActive = true
        boardView?.heightAnchor.constraint(lessThanOrEqualTo: margins.heightAnchor, multiplier: 0.7).isActive = true
        
        if let bView = boardView {
            bView.widthAnchor.constraint(equalTo: bView.heightAnchor, multiplier: 0.7777).isActive = true
        }
        
        UIView.animate(withDuration: 0.5) {
            self.boardView?.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -40.0).isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Button delegate
    
    func buttonDidTouch(type: ButtonType) {
        self.boardView?.removeFromSuperview()
        
        switch type {
        case .project:
            showInfo(title: projectTitle, txt: projectText)
        case .bio:
            showInfo(title: meTitle, txt: meText)
        case .country:
            showInfo(title: fromTitle, txt: fromText)
        }
    }
    
    func sessionDidRun() {
        setupFloorButton()
    }
    
    func sessionDidFail(error: NSError) {
        var message = ""
        
        switch error.code {
        case ARError.Code.sensorUnavailable.rawValue:
            message = arErrorMessage
        case ARError.Code.cameraUnauthorized.rawValue:
            message = cameraErrorMessage
        default:
            message = generalErrorMessage
        }
        
        let alert = UIAlertController(title: errorTitle, message: message, preferredStyle: .alert)
        self.show(alert, sender: nil)
    }
}

