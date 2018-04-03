//
//  BoardView.swift
//  Scholarship
//
//  Created by Marcos Borges on 30/03/2018.
//  Copyright © 2018 Marcos Aires Borges. All rights reserved.
//

import UIKit

class BoardView: UIView {
    
    private let referenceFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
    
    private var title: String
    private var txt: String
    private var image: UIImage?
    private var buttonTitle: String
    private var action: () -> Void

    init(frame: CGRect, title: String, txt: String, image: UIImage? = nil, buttonTitle: String, action: @escaping () -> Void) {
        self.title = title
        self.txt = txt
        self.image = image
        self.buttonTitle = buttonTitle
        self.action = action
        
        super.init(frame: frame)
        
        setupBaseView()
        let poster = createImagePoster()
        let title = createLabel(text: self.title, font: UIFont.boldSystemFont(ofSize: 32))
        let text = createLabel(text: self.txt, font: UIFont.systemFont(ofSize: 18))
        let button = createButton()
        setupLayout(poster: poster, title: title, text: text, button: button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.title = ""
        self.txt = ""
        self.image = UIImage()
        self.buttonTitle = ""
        self.action = {}
        super.init(coder: aDecoder)
    }
    
    private func setupBaseView() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
    }
    
    private func createImagePoster() -> UIImageView {
        let poster = UIImageView(image: self.image)
        poster.frame = referenceFrame
        poster.backgroundColor = UIColor.orange
        poster.contentMode = .scaleAspectFill
        poster.layer.cornerRadius = 12
        poster.clipsToBounds = true
        return poster
    }
    
    private func createLabel(text: String, font: UIFont) -> UILabel {
        let label = UILabel(frame: referenceFrame)
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = font
        return label
    }
    
    private func createButton() -> UIButton {
        let button = UIButton(frame: referenceFrame)
        button.setTitle(self.buttonTitle, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.colorToChange
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(BoardView.buttonDidTouch), for: .touchUpInside)
        return button
    }

    private func setupLayout(poster: UIImageView, title: UILabel, text: UILabel, button: UIButton) {
        
        let scrollView = UIScrollView(frame: .zero)
        self.addSubview(scrollView)
        
        scrollView.addSubview(poster)
        scrollView.addSubview(title)
        scrollView.addSubview(text)
        self.addSubview(button)
        
        // scrollView
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -20.0).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0).isActive = true
        scrollView.heightAnchor.constraint(lessThanOrEqualToConstant: 280.0).isActive = true
        scrollView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        // button
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20.0).isActive = true
        button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        //--------------------------------------------------------------------
        
        // poster
        poster.translatesAutoresizingMaskIntoConstraints = false
        poster.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        poster.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0).isActive = true
        poster.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0.0).isActive = true
        if let _ = self.image {
            poster.heightAnchor.constraint(equalTo: poster.widthAnchor, multiplier: 0.7777).isActive = true
        }
        
        // title
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: poster.bottomAnchor, constant: 20.0).isActive = true
        title.leadingAnchor.constraint(equalTo: poster.leadingAnchor, constant: 20.0).isActive = true
        title.trailingAnchor.constraint(equalTo: poster.trailingAnchor, constant: -20.0).isActive = true
        title.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        // text
        text.translatesAutoresizingMaskIntoConstraints = false
        text.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20.0).isActive = true
        text.leadingAnchor.constraint(equalTo: poster.leadingAnchor, constant: 20.0).isActive = true
        text.trailingAnchor.constraint(equalTo: poster.trailingAnchor, constant: -20.0).isActive = true
        text.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20.0).isActive = true
        text.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    @objc func buttonDidTouch() {
        self.action()
    }
}
