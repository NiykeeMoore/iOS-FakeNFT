//
//  CustomNavigationBar.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 05.04.2025.
//

import UIKit

final class CustomNavigationBar: UIView {
    
    // MARK: - UI Elements
    
    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(named: "appBlackDynamic")
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(named: "appBlackDynamic")
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Настройка вью
    
    private func setupView() {
        backgroundColor = .clear
        
        [leftButton, titleLabel, rightButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 9),
            leftButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftButton.widthAnchor.constraint(equalToConstant: 24),
            leftButton.heightAnchor.constraint(equalToConstant: 24),
            
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -9),
            rightButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightButton.widthAnchor.constraint(equalToConstant: 42),
            rightButton.heightAnchor.constraint(equalToConstant: 42),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftButton.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: rightButton.leadingAnchor, constant: -10)
        ])
    }
    
    // MARK: - Public methods
    
    func configureLeftButton(image: UIImage?, target: Any?, action: Selector) {
        leftButton.setImage(image, for: .normal)
        if image != nil {
            leftButton.addTarget(target, action: action, for: .touchUpInside)
        } else {
            leftButton.removeTarget(nil, action: nil, for: .allEvents)
        }
    }
    
    func configureRightButton(image: UIImage?, target: Any?, action: Selector) {
        rightButton.setImage(image, for: .normal)
        if image != nil {
            rightButton.addTarget(target, action: action, for: .touchUpInside)
        } else {
            rightButton.removeTarget(nil, action: nil, for: .allEvents)
        }
    }
    
    func configureTitle(_ title: String?) {
        titleLabel.text = title
    }
}
