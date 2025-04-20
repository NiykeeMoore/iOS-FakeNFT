//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Niykee Moore on 26.03.2025.
//

import UIKit

final class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LoadingView, ErrorView {
    // MARK: - Properties
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var viewModel: CartViewModel
    private let serviceAssembly: ServicesAssembly
    
    private lazy var nftListTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        tableView.register(CartCell.self, forCellReuseIdentifier: CartCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var bottomPaymentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "appLightGrayDynamic")
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var totalNftCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor(named: "appBlackDynamic")
        return label
    }()
    
    private lazy var totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = UIColor(named: "appGreen")
        return label
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("cart_screen_button_pay", comment: ""), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitleColor(UIColor(named: "appWhiteDynamic"), for: .normal)
        button.backgroundColor = UIColor(named: "appBlackDynamic")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapPayButton), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Init
    init(viewModel: CartViewModel, serviceAssembly: ServicesAssembly) {
        self.viewModel = viewModel
        self.serviceAssembly = serviceAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "appWhiteDynamic")
        
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CartCell.reuseIdentifier,
                for: indexPath
            ) as? CartCell else {
            return UITableViewCell()
        }
        
        if let item = viewModel.item(at: indexPath) {
            cell.configure(with: item)
            
            cell.didDeletionButtonTapped = { [weak self] tappedItem in
                guard let self else {
                    return
                }
                self.showDeleteConfirmation(for: tappedItem)
            }
        }
        
        return cell
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        
        [totalNftCountLabel, totalPriceLabel, payButton].forEach {
            bottomPaymentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [nftListTableView, bottomPaymentView, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        let sortButton = UIBarButtonItem(
            image: UIImage(named: "iconNavBarSort"),
            style: .plain,
            target: self,
            action: #selector(rightButtonTapped)
        )
        sortButton.tintColor = UIColor(named: "appBlackDynamic")
        navigationItem.rightBarButtonItem = sortButton
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            nftListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nftListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            nftListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            nftListTableView.bottomAnchor.constraint(equalTo: bottomPaymentView.topAnchor),
            
            bottomPaymentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPaymentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPaymentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomPaymentView.heightAnchor.constraint(equalToConstant: 76),
            
            totalNftCountLabel.topAnchor.constraint(equalTo: bottomPaymentView.topAnchor, constant: 16),
            totalNftCountLabel.leadingAnchor.constraint(equalTo: bottomPaymentView.leadingAnchor, constant: 16),
            
            totalPriceLabel.topAnchor.constraint(equalTo: totalNftCountLabel.bottomAnchor, constant: 2),
            totalPriceLabel.leadingAnchor.constraint(equalTo: totalNftCountLabel.leadingAnchor),
            totalPriceLabel.bottomAnchor.constraint(equalTo: bottomPaymentView.bottomAnchor, constant: -16),
            
            payButton.topAnchor.constraint(equalTo: bottomPaymentView.topAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: bottomPaymentView.trailingAnchor, constant: -16),
            payButton.bottomAnchor.constraint(equalTo: bottomPaymentView.bottomAnchor, constant: -16),
            payButton.leadingAnchor.constraint(equalTo: totalPriceLabel.trailingAnchor, constant: 24)
        ])
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onItemsUpdate = { [weak self] in
            guard let self else {
                return
            }
            self.nftListTableView.reloadData()
        }
        
        viewModel.onTotalUpdate = { [weak self] count, price in
            guard let self else {
                return
            }
            self.totalNftCountLabel.text = "\(count) NFT"
            self.totalPriceLabel.text = price
            self.payButton.isEnabled = count > 0
        }
        
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            guard let self else {
                return
            }
            
            payButton.isEnabled = !isLoading
            // swiftlint:disable:next void_function_in_ternary
            isLoading ? self.showLoading() : self.hideLoading()
        }
        
        viewModel.onError = { [weak self] errorModel in
            guard let self else {
                return
            }
            self.showError(errorModel)
        }
        
        viewModel.didSortButtonTapped = { [weak self] in
            guard let self else {
                return
            }
            
            let alert = UIAlertController(
                title: NSLocalizedString("cart_nav_sortAlert_title", comment: ""),
                message: nil,
                preferredStyle: .actionSheet
            )
            
            CartSortType.allCases.forEach { sortType in
                let style: UIAlertAction.Style = (sortType == .cancel) ? .cancel : .default
                let action = UIAlertAction(title: sortType.title, style: style) { _ in
                    self.viewModel.onSortStateDidChanged?(sortType)
                }
                alert.addAction(action)
            }
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func showDeleteConfirmation(for item: CartItem) {
        let deleteVC = CartDeleteItemViewController(imageURL: item.imageURL)
        
        deleteVC.modalPresentationStyle = .overCurrentContext
        deleteVC.modalTransitionStyle = .crossDissolve
        
        deleteVC.onDeleteConfirm = { [weak self] in
            guard let self else {
                return
            }
            self.viewModel.deleteItem(withId: item.id)
        }
        
        present(deleteVC, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func rightButtonTapped() {
        viewModel.didSortButtonTapped?()
    }
    
    @objc private func didTapPayButton() {
        let paymentAssembly = PaymentAssembly(servicesAssembler: serviceAssembly)
        let paymentVC = paymentAssembly.build()
        paymentVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(paymentVC, animated: true)
    }
}
