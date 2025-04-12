//
//  NftCollectionViewController.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 02.04.2025.
//

import UIKit
import Kingfisher
import SafariServices

final class NftCollectionViewController: UIViewController, LoadingView {
    
    var activityIndicator: UIActivityIndicatorView
    
    private var viewModel: NftCollectionViewModelProtocol
    private var headerIsReady = false
    private var headerHeight: CGFloat = 350
    
    private lazy var customNavigationBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar()
        navBar.configure(
            leftButtonImage: UIImage(systemName: "chevron.left"),
            title: nil,
            rightButtonImage: nil
        )
        navBar.setLeftButtonTarget(target: self, action: #selector(backButtonTapped))
        navBar.backgroundColor = .clear
        return navBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            NftCollectionViewCell.self,
            forCellWithReuseIdentifier: NftCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            NftCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: NftCollectionViewHeader.reuseIdentifier
        )
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    init(viewModel: NftCollectionViewModelProtocol) {
        self.activityIndicator = UIActivityIndicatorView(style: .large)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        edgesForExtendedLayout = .top
        collectionView.contentInsetAdjustmentBehavior = .never
        setupView()
        viewModel.onLikesUpdated = { [weak self] nftId in
            print("onLikesUpdated called with nftId: \(String(describing: nftId))")
            if let nftId = nftId,
               let index = self?.viewModel.loadedNFTs.firstIndex(where: { $0.id == nftId }) {
                let indexPath = IndexPath(row: index, section: 0)
                print("Updating cell at indexPath: \(indexPath)")
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? NftCollectionViewCell {
                    let isLiked = self?.viewModel.isLiked(nftId) ?? false
                    cell.completeLikeRequest(isLiked: isLiked)
                }
            } else {
                print("Reloading entire collection view")
                self?.collectionView.reloadData()
            }
        }
        fetchNFTs()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func authorLinkTapped() {
        openAuthorLink()
    }
    
    private func openAuthorLink() {
        guard let url = URL(string: viewModel.authorURLString) else {
            print("Невозможно создать URL из строки: \(viewModel.authorURLString)")
            return
        }
        
        let config = SFSafariViewController.Configuration()
        let safariVC = SFSafariViewController(
            url: url,
            configuration: config
        )
        safariVC.preferredControlTintColor = UIColor(named: "appBlackDynamic")
        present(safariVC, animated: true)
    }
    
    private func fetchNFTs() {
        activityIndicator.startAnimating()
        viewModel.loadNFTs { [weak self] in
            guard let self = self else {
                return
            }
            self.activityIndicator.stopAnimating()
            self.collectionView.reloadData()
        }
        
        viewModel.loadCollectionInfo { [weak self] in
            guard let self = self else { return }
            self.title = self.viewModel.collectionInfo.name
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "appWhite")
        
        [customNavigationBar, collectionView, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            customNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationBar.heightAnchor.constraint(equalToConstant: 44),
            
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.bringSubviewToFront(customNavigationBar)
    }
    
    private func headerContentDidLoad() {
        headerIsReady = true
        let width = collectionView.bounds.width
        guard width > 0 else {
            return
        }
        
        let tempHeader = NftCollectionViewHeader(frame: .zero)
        tempHeader.configure(
            with: viewModel.collectionInfo,
            authorLinkAction: { [weak self] in
                self?.openAuthorLink()
            }, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                self.headerHeight = tempHeader.calculatedHeight(for: width)
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        )
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NftCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let interItemSpacing: CGFloat = 10
        let width = (collectionView.bounds.width - 32 - 2 * interItemSpacing) / 3
        
        let dummyCell = NftCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: 1000))
        let model = viewModel.returnCollectionCell(for: indexPath.row)
        dummyCell.configure(with: model)
        
        let height = dummyCell.calculateFittingHeight(for: width)
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 8
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let width = collectionView.bounds.width
        guard width > 0 else {
            return CGSize(width: width, height: headerHeight)
        }
        
        if !headerIsReady {
            return CGSize(width: width, height: headerHeight)
        }
        
        let header = NftCollectionViewHeader(frame: .zero)
        header.configure(
            with: viewModel.collectionInfo,
            authorLinkAction: { [weak self] in
                self?.openAuthorLink()
            },
            completion: {}
        )
        
        let height = header.calculatedHeight(for: width)
        return CGSize(width: width, height: max(height, 350))
    }
}

// MARK: - UICollectionViewDataSource

extension NftCollectionViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.loadedNFTs.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NftCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? NftCollectionViewCell else {
            print("Failed to dequeue NftCollectionViewCell")
            return UICollectionViewCell()
        }
        let nft = viewModel.returnCollectionCell(for: indexPath.row)
        cell.configure(with: nft)
        
        cell.onLikeButtonTapped = { [weak self] nftId in
            self?.viewModel.toggleLike(for: nftId)
        }
        
        cell.onCartButtonTapped = { [weak self] nftId in
            self?.viewModel.toggleCart(for: nftId)
            if let cell = collectionView.cellForItem(at: indexPath) as? NftCollectionViewCell {
                let isInCart = self?.viewModel.isAddedToCart(nftId) ?? false
                cell.setCartButtonState(isAdded: isInCart)
            }
        }
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: NftCollectionViewHeader.reuseIdentifier,
                for: indexPath
              ) as? NftCollectionViewHeader else {
            return UICollectionReusableView()
        }
        
        header.configure(
            with: viewModel.collectionInfo,
            authorLinkAction: { [weak self] in
                self?.openAuthorLink()
            },
            completion: { [weak self] in
                self?.headerContentDidLoad()
            }
        )
        
        return header
    }
}
