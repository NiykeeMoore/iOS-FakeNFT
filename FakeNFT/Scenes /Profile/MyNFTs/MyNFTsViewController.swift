//
//  MyNftsViewController.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 05.04.2025.
//

import UIKit

final class MyNFTsViewController: UIViewController {
    private var viewModel: MyNFTsViewModelProtocol
    private var isEmptyNFT: Bool
    
    private let customNavBar = ProfileNavigationBar()
    
    private lazy var emptyNFTsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(named: "appBlackDynamic")
        label.text = NSLocalizedString("Profile.emptyNFT", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NFTTableViewCell.self, forCellReuseIdentifier: NFTTableViewCell.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat.greatestFiniteMagnitude)
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 140
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor(named: "appWhiteDynamic")
        return tableView
    }()
    
    init(viewModel: MyNFTsViewModelProtocol) {
        self.viewModel = viewModel
        self.isEmptyNFT = (viewModel.profileData.nfts ?? []).isEmpty
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupNavigationBar()
        setupConstraints()
        
        if isEmptyNFT {
            updateUI()
        } else {
            viewModel.loadNFTs()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.onCloseHandler()
        super.viewWillDisappear(animated)
    }
    
    private func setupBindings() {
        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onError = { [weak self] error in
            self?.showErrorAlert(errorDescription: error.localizedDescription)
        }
        
        viewModel.isLoading = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "appWhiteDynamic")
        
        tableView.dataSource = self
        view.addSubview(customNavBar)
        view.addSubview(tableView)
        view.addSubview(emptyNFTsLabel)
        view.addSubview(activityIndicator)
        
        tableView.isHidden = true
        emptyNFTsLabel.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Navigation Bar
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 44),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -39),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Empty NFTs View
            emptyNFTsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyNFTsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Loader View
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let leftImage = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)?
            .withTintColor(UIColor(named: "appBlackDynamic") ?? .black, renderingMode: .alwaysOriginal)
        let rightImage = isEmptyNFT ? nil : UIImage(systemName: "text.justifyleft", withConfiguration: imageConfig)?
            .withTintColor(UIColor(named: "appBlackDynamic") ?? .black, renderingMode: .alwaysOriginal)
        
        customNavBar.configureLeftButton(image: leftImage, target: self, action: #selector(backButtonTapped))
        customNavBar.configureTitle(isEmptyNFT ? nil : NSLocalizedString("Profile.likedNFT", comment: ""))
        customNavBar.configureRightButton(image: rightImage, target: self, action: #selector(sortButtonTapped))
        
        // Layout constraints
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateUI() {
        if isEmptyNFT {
            tableView.isHidden = true
            emptyNFTsLabel.isHidden = false
        } else {
            tableView.isHidden = false
            emptyNFTsLabel.isHidden = true
            tableView.reloadData()
        }
    }
    
    private func showErrorAlert(errorDescription: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Error.title", comment: ""),
            message: errorDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sortButtonTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("MyNFT.sort.title", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let byPrice = UIAlertAction(
            title: NSLocalizedString("MyNFT.sort.byPrice", comment: ""),
            style: .default
        ) { [weak self] _ in
            self?.viewModel.sortNFTs(by: .price)
        }
        
        let byRating = UIAlertAction(
            title: NSLocalizedString("MyNFT.sort.byRating", comment: ""),
            style: .default
        ) { [weak self] _ in
            self?.viewModel.sortNFTs(by: .rating)
        }
        
        let byName = UIAlertAction(
            title: NSLocalizedString("MyNFT.sort.byName", comment: ""),
            style: .default
        ) { [weak self] _ in
            self?.viewModel.sortNFTs(by: .name)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("MyNFT.sort.close", comment: ""),
            style: .cancel
        )
        
        // Add all actions
        alert.addAction(byPrice)
        alert.addAction(byRating)
        alert.addAction(byName)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

extension MyNFTsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.nfts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = NFTTableViewCell.identifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? NFTTableViewCell
        else {
            return UITableViewCell()
        }
        
        let nft = viewModel.nfts[indexPath.row]
        let isLiked = viewModel.profileData.likes?.contains(nft.id) ?? false
        cell.configure(nft: nft, isLiked: isLiked) { [weak self] in
            self?.viewModel.likedNFT(nft.id)
        }
        return cell
    }
}
