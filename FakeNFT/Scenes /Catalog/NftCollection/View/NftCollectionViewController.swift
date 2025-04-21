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
            if let nftId = nftId,
               let index = self?.viewModel.loadedNFTs.firstIndex(where: { $0.id == nftId }) {
                let indexPath = IndexPath(row: index, section: 0)
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? NftCollectionViewCell {
                    let isLiked = self?.viewModel.isLiked(nftId) ?? false
                    cell.completeLikeRequest(isLiked: isLiked)
                }
            } else {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.onCartUpdated = { [weak self] nftId in
            if let nftId = nftId,
               let index = self?.viewModel.loadedNFTs.firstIndex(where: { $0.id == nftId }) {
                let indexPath = IndexPath(row: index, section: 0)
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? NftCollectionViewCell {
                    let isInCart = self?.viewModel.isAddedToCart(nftId) ?? false
                    cell.completeCartRequest(isInCart: isInCart)
                } else {
                    self?.collectionView.reloadItems(at: [indexPath])
                }
            } else {
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
        safariVC.preferredControlTintColor = UIColor(resource: .appBlackDynamic)
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
            guard let self = self else {
                return
            }
            self.title = self.viewModel.collectionInfo.name
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(resource: .appWhiteDynamic)
        
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
        let totalWidth = collectionView.bounds.width
        let itemsPerRow: CGFloat = 3
        let spacing: CGFloat = Constants.interItemSpacing
        let insets: CGFloat = Constants.sectionInset * 2
        
        let availableWidth = totalWidth - insets - (spacing * (itemsPerRow - 1))
        let itemWidth = floor(availableWidth / itemsPerRow)
        
        guard itemWidth > 0 else {
            return CGSize(width: 0, height: 0)
        }
        
        let rowStartIndex = (indexPath.row / Int(itemsPerRow)) * Int(itemsPerRow)
        let rowEndIndex = min(rowStartIndex + Int(itemsPerRow), viewModel.loadedNFTs.count)
        
        var maxHeight: CGFloat = 0
        for rowIndex in rowStartIndex..<rowEndIndex {
            let dummyCell = NftCollectionViewCell(frame: CGRect(x: 0, y: 0, width: itemWidth, height: 1000))
            let model = viewModel.returnCollectionCell(for: rowIndex)
            dummyCell.configure(with: model)
            let height = dummyCell.calculateFittingHeight(for: itemWidth)
            maxHeight = max(maxHeight, height)
        }
        
        return CGSize(width: itemWidth, height: maxHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.interItemSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.interItemSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: Constants.interItemSpacing,
            left: Constants.sectionInset,
            bottom: Constants.interItemSpacing,
            right: Constants.sectionInset
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let width = collectionView.bounds.width
        
        if width <= 0 || !headerIsReady {
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

private extension NftCollectionViewController {
    enum Constants {
        static let interItemSpacing: CGFloat = 10
        static let sectionInset: CGFloat = 16
    }
}
