//
//  PaymentSuccessViewController.swift
//  FakeNFT
//
//  Created by Niykee Moore on 20.04.2025.
//

import UIKit

final class PaymentSuccessViewController: UIViewController {
    var onDismiss: (() -> Void)?

    // MARK: - UI Elements
    private lazy var successImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "imageSuccessPay")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var successLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("paymentSuccess_message", comment: "")
        label.textColor = UIColor(named: "appBlackDynamic")
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var backToCatalogButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("paymentSuccess_button_backToCatalog", comment: ""), for: .normal)
        button.setTitleColor(UIColor(named: "appWhiteDynamic"), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = UIColor(named: "appBlackDynamic")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureConstraints()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(named: "appWhiteDynamic")
        navigationItem.hidesBackButton = true
        
        [successImageView, successLabel, backToCatalogButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    // MARK: - Layout UI
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            successImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            successImageView.widthAnchor.constraint(equalToConstant: 278),
            successImageView.heightAnchor.constraint(equalToConstant: 278),
            
            successLabel.topAnchor.constraint(equalTo: successImageView.bottomAnchor, constant: 20),
            successLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 36),
            successLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -36),
            
            backToCatalogButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backToCatalogButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            backToCatalogButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            backToCatalogButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        onDismiss?()
    }
}
