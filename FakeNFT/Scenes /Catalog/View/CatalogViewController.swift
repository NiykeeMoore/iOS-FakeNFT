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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(named: "appWhite")
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
        refreshControl.tintColor = UIColor(named: "appBlack")
        refreshControl.addTarget(self, action: #selector(refreshCatalog), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    private func setupView() {
        [tableView, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchCollections() {
        guard !refreshControl.isRefreshing else {
            return
        }
        activityIndicator.startAnimating()
        
        viewModel.getCollections { [weak self] _ in
            self?.activityIndicator.stopAnimating()
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
        let nftViewModel = NftCollectionViewModel(
                    nftCollectionModel: selectedCollection,
                    nftService: nftService
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
        cell.backgroundColor = UIColor(named: "appWhite")

        return cell
    }
}
