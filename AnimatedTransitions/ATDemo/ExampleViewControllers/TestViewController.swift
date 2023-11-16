//
//  TestViewController.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 14.11.2023.
//

import UIKit

class TestViewController: UIViewController {

    lazy var dismissButton = UIButton(type: .system)
    
    lazy var tempView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.at.isEnabled = true
        view.at.id = "custom"
        
        return view
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        
        label.text = "4"
        label.textColor = .blue
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.layer.cornerRadius = 10
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.blue.cgColor
        
        label.at.isEnabled = true
        label.at.id = "4"
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.at.isEnabled = true
        view.backgroundColor = .systemPink
        
        view.addSubview(tempView)
        tempView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      dismissButton.sizeToFit()
      dismissButton.center = CGPoint(x: 30, y: 30)
    }
    
    func configure() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTap)))

        dismissButton.setTitle("Назад", for: .normal)
        dismissButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        view.addSubview(dismissButton)
    }
    
    func addModifiers(modifiers: [ATModifier]) {
        tempView.at.modifiers = modifiers
        tempView.alpha = 1
        tempView.backgroundColor = .systemPink
    }
    
    func addViewWithModifiers(modifiers: [ATModifier], id: String) {
        let view = UIView()
        view.backgroundColor = .green
        view.at.isEnabled = true
        view.at.id = id
        
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    @objc func buttonTap() {
      dismiss(animated: true, completion: nil)
    }
}

extension TestViewController {
    func setupLabel() {
        view.backgroundColor = .white
        
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.size.equalTo(75)
            make.right.bottom.equalToSuperview().inset(50)
        }
    }
}
