
import UIKit

public class WelcomeViewController: UIViewController {
    
    // MARK: - Overridden methods

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    // MARK: - Private methods
    
    private func setupLayout() {
        
        let margins = self.view.layoutMarginsGuide
        self.view.backgroundColor = UIColor.lightGray
        
        let image = UIImage(named: "tables")
        let boardView = BoardView(frame: CGRect.zero, title: welcomeTitle, txt: welcomeText, image: image, buttonTitle: "START") {
            self.gotoMainScreen()
        }
        
        self.view.addSubview(boardView)
        
        boardView.translatesAutoresizingMaskIntoConstraints = false
        boardView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        boardView.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        boardView.widthAnchor.constraint(equalTo: boardView.heightAnchor, multiplier: 0.7777).isActive = true
        boardView.heightAnchor.constraint(lessThanOrEqualTo: self.view.heightAnchor, multiplier: 0.95).isActive = true
    }
    
    private func gotoMainScreen() {
        self.dismiss(animated: true, completion: {
            SceneManager.shared.runSession()
        })
    }
}













