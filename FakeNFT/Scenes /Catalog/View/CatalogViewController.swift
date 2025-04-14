//
//  CatalogViewController.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 25.03.2025.
//

import UIKit
import ProgressHUD

final class CatalogViewController: UIViewController, LoadingView {
    
    var activityIndicator: UIActivityIndicatorView
    
    private var viewModel: CatalogViewModelProtocol
    private let servicesAssembly: ServicesAssembly
    
    private lazy var customNavigationBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar()
        navBar.configure(
            leftButtonImage: nil,
            title: nil,
            rightButtonImage: UIImage(named: "iconNavBarSort")
        )
        navBar.setRightButtonTarget(target: self, action: #selector(sortButtonTapped))
        navBar.backgroundColor = .clear
        return navBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(named: "appWhiteDynamic")
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            CatalogCell.self,
            forCellReuseIdentifier: CatalogCell.identifier
        )
        tableView.refreshControl = refreshControl
        
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(named: "appBlackDynamic")
        refreshControl.addTarget(self, action: #selector(refreshCatalog), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupView()
        fetchCollections()
    }
    
    init(viewModel: CatalogViewModelProtocol, servicesAssembly: ServicesAssembly) {
        self.viewModel = viewModel
        self.servicesAssembly = servicesAssembly
        self.activityIndicator = UIActivityIndicatorView(style: .large)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func refreshCatalog() {
        fetchCollections()
    }
    
    @objc func sortButtonTapped() {
        let sortingAlert  = UIAlertController(
            title: NSLocalizedString("Sorting", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        sortingAlert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Sorting.byName", comment: ""),
                style: .default
            ) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.viewModel.sortType = .byName
                _ = self.viewModel.sortCatalog(by: self.viewModel.sortType)
                self.tableView.reloadData()
            }
        )
        
        sortingAlert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Sorting.byQuantity", comment: ""),
                style: .default
            ) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.viewModel.sortType = .byQuantity
                _ = self.viewModel.sortCatalog(by: self.viewModel.sortType)
                self.tableView.reloadData()
            }
        )
        
        sortingAlert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Sorting.cancel", comment: ""),
                style: .cancel
            )
        )
        
        present(sortingAlert, animated: true)
    }
    
    private func setupView() {
        [tableView, customNavigationBar, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            customNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationBar.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchCollections() {
        guard !refreshControl.isRefreshing else {
            return
        }
        activityIndicator.startAnimating()
        customNavigationBar.isHidden = true
        
        viewModel.getCollections { [weak self] _ in
            self?.activityIndicator.stopAnimating()
            self?.customNavigationBar.isHidden = false
            guard let self = self else {
                return
            }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
}

// MARK: - UITableViewDelegate

extension CatalogViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        CatalogCell.height
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let selectedCollection = viewModel.catalogItems[indexPath.row]
        let nftService = servicesAssembly.nftService
        let likesService = servicesAssembly.likesService
        let orderService = servicesAssembly.orderService
        let nftViewModel = NftCollectionViewModel(
            nftCollectionModel: selectedCollection,
            nftService: nftService,
            likesService: likesService,
            orderService: orderService
        )
        let nftController = NftCollectionViewController(viewModel: nftViewModel)
        
        navigationController?.pushViewController(nftController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CatalogViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.catalogItems.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CatalogCell.identifier,
            for: indexPath
        ) as? CatalogCell else {
            return UITableViewCell()
        }
        
        let catalogItem = viewModel.catalogItems[indexPath.row]
        cell.configure(with: catalogItem)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "appWhiteDynamic")
        
        return cell
    }
}
