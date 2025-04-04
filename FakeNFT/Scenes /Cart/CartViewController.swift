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
    
    private lazy var customNavBar = CustomNavigationBar()
    
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
    
    private lazy var footerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "appLightGrayDynamic")
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
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
        button.setTitle("К оплате", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitleColor(UIColor(named: "appWhiteDynamic"), for: .normal)
        button.backgroundColor = UIColor(named: "appBlackDynamic")
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Init
    init(viewModel: CartViewModel) {
        self.viewModel = viewModel
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
        }
        
        return cell
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        [totalNftCountLabel, totalPriceLabel, payButton].forEach {
            footerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [customNavBar, nftListTableView, footerView, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupNavigationBar()
        setupConstraints()
    }
    private func setupNavigationBar() {
        customNavBar.backgroundColor = .clear
        
        customNavBar.configure(
            leftButtonImage: nil,
            title: nil,
            rightButtonImage: UIImage(named: "iconNavBarSort")
        )
        
        customNavBar.setRightButtonTarget(target: self, action: #selector(rightButtonTapped))
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 44),
            
            nftListTableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 20),
            nftListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            nftListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            nftListTableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            footerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 75),
            
            totalNftCountLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16),
            totalNftCountLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            totalNftCountLabel.bottomAnchor.constraint(equalTo: totalPriceLabel.topAnchor, constant: 2),
            
            totalPriceLabel.leadingAnchor.constraint(equalTo: totalNftCountLabel.leadingAnchor),
            totalPriceLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -16),
            
            payButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16),
            payButton.leadingAnchor.constraint(equalTo: totalPriceLabel.trailingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            payButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -16)
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
            
            // swiftlint:disable:next void_function_in_ternary
            isLoading ? self.showLoading() : self.hideLoading()
        }
        
        viewModel.onError = { [weak self] errorModel in
            guard let self else {
                return
            }
            self.showError(errorModel)
        }
    }
    
    // MARK: - Actions
    
    @objc private func rightButtonTapped() {
        print("Правая кнопка нажата")
    }
}
