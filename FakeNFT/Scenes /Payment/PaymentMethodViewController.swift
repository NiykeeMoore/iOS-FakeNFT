//
//  PaymentMethodViewController.swift
//  FakeNFT
//
//  Created by Niykee Moore on 19.04.2025.
//

import UIKit

final class PaymentMethodViewController: UIViewController,
                                         UICollectionViewDelegateFlowLayout,
                                         UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UI Elements
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 7
        layout.minimumInteritemSpacing = 7
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PaymentMethodCell.self, forCellWithReuseIdentifier: PaymentMethodCell.reuseIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        return collectionView
    }()
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "appLightGrayDynamic")
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "appBlackDynamic")
        label.text = NSLocalizedString("payment_terms_prefix", comment: "")
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var termsLinkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "appBlue")
        label.text = NSLocalizedString("payment_terms_link", comment: "")
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var termsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [termsLabel, termsLinkLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("payment_button_pay", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(UIColor(named: "appWhiteDynamic"), for: .normal)
        button.backgroundColor = UIColor(named: "appBlackDynamic")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapPayButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    private var paymentMethods: [PaymentMethod] = []
    private var selectedIndexPath: IndexPath?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        loadMockData()
        selectInitialItem()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = NSLocalizedString("payment_nav_title", comment: "")
        if let backButtonImage = UIImage(named: "iconNavBarBack") {
            let backButton = UIBarButtonItem(
                image: backButtonImage,
                style: .plain,
                target: self,
                action: #selector(didTapBackButton)
            )
            backButton.tintColor = UIColor(named: "appBlackDynamic")
            navigationItem.leftBarButtonItem = backButton
        }
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "appWhiteDynamic")
        
        [collectionView, bottomContainerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [termsStackView, payButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomContainerView.addSubview($0)
        }
    }
    
    // swiftlint:disable line_length
    private func setupConstraints() {
        let horizontalMargin: CGFloat = 16
        let verticalMargin: CGFloat = 16
        let topCollectionViewMargin: CGFloat = 20
        let buttonHeight: CGFloat = 60
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topCollectionViewMargin),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            termsStackView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: horizontalMargin),
            termsStackView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -horizontalMargin),
            termsStackView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: verticalMargin),
            
            payButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: horizontalMargin),
            payButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -horizontalMargin),
            payButton.topAnchor.constraint(equalTo: termsStackView.bottomAnchor, constant: verticalMargin),
            payButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -verticalMargin)
        ])
    }
    
    // MARK: - Data Loading (Mock)
    
    private func loadMockData() {
        paymentMethods = [
            PaymentMethod(id: "1", name: "Bitcoin", abbreviation: "BTC", icon: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Bitcoin.png")),
            PaymentMethod(id: "2", name: "Dogecoin", abbreviation: "DOGE", icon: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Dogecoin.png")),
            PaymentMethod(id: "3", name: "USDT", abbreviation: "Card", icon: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Card(USD).png")),
            PaymentMethod(id: "4", name: "Etherium", abbreviation: "ETH", icon: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Etherium.png")),
            PaymentMethod(id: "6", name: "Tether", abbreviation: "USDT", icon: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Tether(USDT).png")),
            PaymentMethod(id: "7", name: "Ape Coin", abbreviation: "APE", icon: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/ApeCoin.png")),
            PaymentMethod(id: "8", name: "Solana", abbreviation: "SOL", icon: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Solana.png")),
            PaymentMethod(id: "9", name: "Shiba Inu", abbreviation: "SHIB", icon: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/ShibaInu.png"))
        ]
        collectionView.reloadData()
    }
    // swiftlint:enable line_length
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 100, height: 60)
        }
        let horizontalMargin: CGFloat = 16
        let interItemSpacing = layout.minimumInteritemSpacing
        let availableWidth = collectionView.bounds.width - (horizontalMargin * 2) - interItemSpacing
        
        let itemWidth = availableWidth / 2
        return CGSize(width: itemWidth, height: 60)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paymentMethods.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PaymentMethodCell.reuseIdentifier,
            for: indexPath
        ) as? PaymentMethodCell else {
            return UICollectionViewCell()
        }
        let method = paymentMethods[indexPath.item]
        cell.configure(with: method)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath != indexPath {
            selectedIndexPath = indexPath
        }
        print("Selected: \(paymentMethods[indexPath.item].name)")
    }
    
    private func selectInitialItem() {
        if !paymentMethods.isEmpty {
            let firstIndexPath = IndexPath(item: 0, section: 0)
            collectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: [])
            selectedIndexPath = firstIndexPath
            
            collectionView.layoutIfNeeded()
            if let cell = collectionView.cellForItem(at: firstIndexPath) as? PaymentMethodCell {
                cell.isSelected = true
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapPayButton() {
        guard let selectedIndexPath = selectedIndexPath else {
            
            print("No payment method selected")
            return
        }
        let selectedMethod = paymentMethods[selectedIndexPath.item]
        print("Proceed to pay with: \(selectedMethod.name) (ID: \(selectedMethod.id))")
        
    }
}
