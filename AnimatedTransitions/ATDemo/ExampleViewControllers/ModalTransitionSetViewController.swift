//
//  ViewController.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 14.11.2023.
//

import UIKit
import SnapKit

class ModalTransitionSetViewController: UIViewController {

    private lazy var cvLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        return layout
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
        
        self.navigationItem.title = "Готовый набор модальных переходов"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BaseCollectionViewCell.self, forCellWithReuseIdentifier: "BaseCollectionViewCell")
        
        setupUI()
    }
    
    // MARK: - Private Functions
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ModalTransitionSetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 11
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BaseCollectionViewCell", for: indexPath) as? BaseCollectionViewCell else { return UICollectionViewCell() }
        
        let text = ModalTransitionSet.buttons[indexPath.row]
        cell.configure(text: text)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ModalTransitionSetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc2 = TestViewController()
        vc2.configure()
        switch indexPath.row {
        case 0:
            vc2.atModalAnimationType = .fade
        case 1:
            vc2.atModalAnimationType = .pageIn(direction: .up)
        case 2:
            vc2.atModalAnimationType = .cover(direction: .down)
        case 3:
            vc2.atModalAnimationType = .pull(direction: .right)
        case 4:
            vc2.atModalAnimationType = .pageOut(direction: .down)
        case 5:
            vc2.atModalAnimationType = .zoom
        case 6:
            vc2.atModalAnimationType = .slide(direction: .left)
        case 7:
            vc2.atModalAnimationType = .slide(direction: .left)
        case 8:
            vc2.atModalAnimationType = .zoomSlide(direction: .up)
        case 9:
            vc2.atModalAnimationType = .uncover(direction: .right)
        case 10:
            vc2.atModalAnimationType = .push(direction: .down)
        default:
            break
        }
        
        present(vc2, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ModalTransitionSetViewController: UICollectionViewDelegateFlowLayout {
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

class ModalTransitionSet {
    static let buttons: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
}
