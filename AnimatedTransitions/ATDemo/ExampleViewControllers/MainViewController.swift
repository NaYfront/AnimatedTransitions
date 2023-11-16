//
//  ViewController.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 14.11.2023.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {

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
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(150)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BaseCollectionViewCell", for: indexPath) as? BaseCollectionViewCell else { return UICollectionViewCell() }
        
        let text = TransitionTypes.buttons[indexPath.row]
        cell.configure(text: text)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = TransitionSetViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = ModalTransitionSetViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = CustomTransitionSetViewController()
            navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 50, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50 //30
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0 //15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
        // UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    }
}

class TransitionTypes {
    static let buttons: [String] = ["Готовый набор переходов", "Готовый набор модальных переходов", "Кастомизация"]
}
