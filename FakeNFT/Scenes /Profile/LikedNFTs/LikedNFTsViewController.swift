//
//  MyNftsViewController.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 05.04.2025.
//

import UIKit

final class LikedNFTsViewController: UIViewController {
    private var viewModel: LikedNFTsViewModelProtocol
    
    private let customNavBar = CustomNavigationBar()
    
    private lazy var emptyNFTsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(named: "appBlackDynamic")
        label.text = NSLocalizedString("Profile.emptyLikedNFT", comment: "")
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
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 7 // Space between columns
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            NFTCollectionViewCell.self,
            forCellWithReuseIdentifier: NFTCollectionViewCell.identifier
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        return collectionView
    }()
    
    init(viewModel: LikedNFTsViewModelProtocol) {
        self.viewModel = viewModel
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
        
        if (viewModel.profileData.likes ?? []).isEmpty {
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
        
        viewModel.onRemoveNFT = { [weak self] indexPath in
            guard let self else {
                return
            }
            
            DispatchQueue.main.async {
                if let cell = self.collectionView.cellForItem(at: indexPath) {
                    UIView.animate(
                        withDuration: 0.2,
                        animations: {
                            cell.alpha = 0
                            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        },
                        completion: { _ in
                            self.collectionView.performBatchUpdates({
                                self.collectionView.deleteItems(at: [indexPath])
                            })
                        }
                    )
                } else {
                    self.collectionView.reloadData()
                }
                
                if self.viewModel.nfts.isEmpty { self.updateUI() }
            }
        }
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "appWhiteDynamic")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(customNavBar)
        view.addSubview(collectionView)
        view.addSubview(emptyNFTsLabel)
        view.addSubview(activityIndicator)
        
        collectionView.isHidden = true
        emptyNFTsLabel.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Navigation Bar
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 44),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
        
        customNavBar.configureLeftButton(image: leftImage, target: self, action: #selector(backButtonTapped))
        customNavBar.configureTitle(viewModel.nfts.isEmpty ? nil : NSLocalizedString("Profile.likedNFT", comment: ""))
        
        // Layout constraints
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateUI() {
        if viewModel.nfts.isEmpty {
            collectionView.isHidden = true
            emptyNFTsLabel.isHidden = false
            customNavBar.configureTitle(nil)
        } else {
            collectionView.isHidden = false
            emptyNFTsLabel.isHidden = true
            collectionView.reloadData()
            customNavBar.configureTitle(NSLocalizedString("Profile.likedNFT", comment: ""))
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
}

extension LikedNFTsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.nfts.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cellId = NFTCollectionViewCell.identifier
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellId, for: indexPath
        ) as? NFTCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let nft = viewModel.nfts[indexPath.row]
        cell.configure(nft: nft, isLiked: true) { [weak self] in
            self?.viewModel.unlikedNFT(nft.id)
        }
        return cell
    }
}

extension LikedNFTsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let interitemSpacing: CGFloat = 7 // Space between columns
        let availableWidth = collectionView.bounds.width - interitemSpacing
        let widthPerItem = availableWidth / 2
        
        return CGSize(width: widthPerItem, height: 80) // Keep the same height
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3) {
            cell.alpha = 1
        }
    }
}
