//
//  ViewController.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 14.11.2023.
//

import UIKit
import SnapKit

class CustomTransitionSetViewController: UIViewController {

    private lazy var cvLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        return layout
    }()
    
    lazy var tempView = UIView()
    
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
    
    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.cvLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Configuration
    func configure() {
        self.at.isEnabled = true
        
        tempView.at.isEnabled = true
        tempView.atID = "custom"
        tempView.alpha = 0
        
        self.navigationItem.title = "Кастомизация"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BaseCollectionViewCell.self, forCellWithReuseIdentifier: "BaseCollectionViewCell")
        
        setupUI()
    }
    
    func addModifiers(modifiers: [ATModifier]) {
        tempView.at.modifiers = modifiers
    }
    
    // MARK: - Private Functions
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        tempView.backgroundColor = .blue
        view.addSubview(tempView)
        tempView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        setupLabel()
    }
}

// MARK: - UICollectionViewDataSource
extension CustomTransitionSetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BaseCollectionViewCell", for: indexPath) as? BaseCollectionViewCell else { return UICollectionViewCell() }
        
        let text = TransitionSet.buttons[indexPath.row]
        cell.configure(text: text)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CustomTransitionSetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc2 = TestViewController()
        switch indexPath.row {
        case 0:
            vc2.addModifiers(modifiers: [.duration(3)])
            
            navigationController?.atNavigationAnimationType = .fade
        case 1:
            vc2.addViewWithModifiers(modifiers: [.scale(5)], id: "custom")
            
            navigationController?.atNavigationAnimationType = .pageIn(direction: .up)
        case 2:
            vc2.setupLabel()
            
            navigationController?.atNavigationAnimationType = .cover(direction: .down)
        default:
            break
        }
        
        navigationController?.pushViewController(vc2, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CustomTransitionSetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
    }
}

class CustomTransitionSet {
    static let buttons: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
}

extension CustomTransitionSetViewController {
    func setupLabel() {
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.size.equalTo(75)
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(collectionView.snp.top).offset(220)
        }
    }
}
