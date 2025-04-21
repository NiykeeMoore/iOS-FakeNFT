//
//  PaymentMethodViewController.swift
//  FakeNFT
//
//  Created by Niykee Moore on 19.04.2025.
//

import UIKit
import SafariServices

final class PaymentMethodViewController: UIViewController,
                                         UICollectionViewDelegateFlowLayout,
                                         UICollectionViewDelegate, UICollectionViewDataSource,
                                         LoadingView {
    // MARK: - Dependencies & State
    private var viewModel: PaymentViewModelProtocol
    var activityIndicator = UIActivityIndicatorView()
    private var selectedIndexPath: IndexPath?
    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTermsLink))
        label.addGestureRecognizer(tapGesture)
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
    
    // MARK: - Initialization
    init(viewModel: PaymentViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        bindViewModel()
        viewModel.loadPaymentMethods()
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
        
        [collectionView, bottomContainerView, activityIndicator].forEach {
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
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
    // swiftlint:enable line_length
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else {
                return
            }
            
            switch state {
            case .initial:
                self.hideLoading()
                
            case .loading:
                self.showLoading()
                
            case .loaded:
                self.hideLoading()
                
            case .error(let error):
                self.hideLoading()
                
                let errorModel = ErrorModel(
                    message: error.localizedDescription,
                    actionText: NSLocalizedString("Error.repeat", comment: "")
                ) {
                    self.viewModel.loadPaymentMethods()
                }
                print(errorModel)
            }
        }
        
        viewModel.onPaymentMethodsChange = { [weak self] in
            guard let self else {
                return
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        viewModel.onPaymentProcessing = { [weak self] in
            guard let self else {
                return
            }
            self.showLoading()
            self.payButton.isEnabled = false
        }
        
        viewModel.onPaymentSuccess = { [weak self] in
            guard let self else {
                return
            }
            self.hideLoading()
            self.navigateToSuccessScreen()
        }
        
        viewModel.onPaymentFailed = { [weak self] errorModel in
            guard let self else {
                return
            }
            self.hideLoading()
            
            let alert = UIAlertController(
                title: errorModel.actionText,
                message: errorModel.message,
                preferredStyle: .alert
            )
            
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("Error.repeat", comment: ""),
                    style: .cancel
                ) { [weak self] _ in
                    guard let self else {
                        return
                    }
                    self.viewModel.performPayment()
                }
            )
            
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("Error.cancel", comment: ""),
                    style: .default,
                    handler: nil
                )
            )
            
            present(alert, animated: true, completion: nil)
        }
    }
    
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
        return viewModel.paymentMethods.count
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
        let method = viewModel.paymentMethods[indexPath.item]
        cell.configure(with: method)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectPaymentMethod(index: indexPath.item)
    }
    
    // MARK: - Helper Methods
    private func navigateToSuccessScreen() {
        let successVC = PaymentSuccessViewController()
        
        successVC.onDismiss = { [weak self] in
            guard let self else {
                return
            }
            
            self.dismiss(animated: true) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        successVC.modalPresentationStyle = .fullScreen
        present(successVC, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapPayButton() {
        viewModel.performPayment()
    }
    
    @objc private func didTapTermsLink() {
        guard let url = URL(string: "https://yandex.ru/legal/practicum_termsofuse/") else {
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
}
