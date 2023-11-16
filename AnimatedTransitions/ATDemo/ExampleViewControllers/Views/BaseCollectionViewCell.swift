//
//  BaseCollectionViewCell.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 14.11.2023.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    // MARK: - User Interface
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blue
        
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(text: String) {
        titleLabel.text = text
    }
    
    // MARK: - Private Functions
    private func setupUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blue.cgColor
        
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
