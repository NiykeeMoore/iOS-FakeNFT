//
//  CartDeleteItemViewController.swift
//  FakeNFT
//
//  Created by Niykee Moore on 08.04.2025.
//

import UIKit
import Kingfisher

final class CartDeleteItemViewController: UIViewController {
    // MARK: - Properties
    var onDeleteConfirm: (() -> Void)?
    
    // MARK: - UI Elements
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    private lazy var containerView = UIView()
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var confirmationLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("cart_deletion_screen_confirmation_warning", comment: "")
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "appBlackDynamic")
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("cart_deletion_button_delete", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(UIColor(named: "appRed"), for: .normal)
        button.backgroundColor = UIColor(named: "appBlackDynamic")
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("cart_deletion_button_cancel", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(UIColor(named: "appWhiteDynamic"), for: .normal)
        button.backgroundColor = UIColor(named: "appBlackDynamic")
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [deleteButton, cancelButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Init
    init(imageURL: URL?) {
        super.init(nibName: nil, bundle: nil)
        nftImageView.kf.indicatorType = .activity
        nftImageView.kf.setImage(
            with: imageURL,
            placeholder: UIImage(named: "nftPlaceholder")
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear
        
        [blurEffectView, containerView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [nftImageView, confirmationLabel, buttonsStackView].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            
            nftImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            nftImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            confirmationLabel.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 12),
            confirmationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 41),
            confirmationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -41),
            
            buttonsStackView.topAnchor.constraint(equalTo: confirmationLabel.bottomAnchor, constant: 20),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Actions
    @objc private func deleteButtonTapped() {
        onDeleteConfirm?()
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}
