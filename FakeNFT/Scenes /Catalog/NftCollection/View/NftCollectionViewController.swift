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
    
    private let viewModel: NftCollectionViewModelProtocol
    
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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        let scrollTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScrollViewTap(_:)))
        scrollView.addGestureRecognizer(scrollTapGesture)
        
        return scrollView
    }()
    
    private lazy var coverImageView: UIImageView = {
        let coverImage = UIImageView()
        coverImage.contentMode = .scaleAspectFill
        coverImage.layer.masksToBounds = true
        coverImage.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        coverImage.layer.cornerRadius = 12
        
        return coverImage
    }()
    
    private lazy var collectionTitleLabel: UILabel = {
        let tittleLabel = UILabel()
        tittleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        tittleLabel.textColor = UIColor(named: "appBlack")
        tittleLabel.numberOfLines = 0
        
        return tittleLabel
    }()
    
    private lazy var collectionAuthorLabel: UILabel = {
        let author = UILabel()
        author.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        author.textColor = UIColor(named: "appBlack")
        author.numberOfLines = 0
        author.text = NSLocalizedString("Collection's author", comment: "")
        
        return author
    }()
    
    private lazy var collectionAuthorLinkLabel: UILabel = {
        let label = UILabel()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(authorLinkTapped))
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(named: "appBlue")
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    private lazy var collectionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "appBlack")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = true
        collectionView.register(
            NftCollectionViewCell.self,
            forCellWithReuseIdentifier: NftCollectionViewCell.reuseIdentifier
        )
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    private lazy var containerView = UIView()
    
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
        setupView()
        configureUI(with: viewModel.collectionInfo)
        fetchNFTs()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func authorLinkTapped() {
        openAuthorLink()
    }
    
    @objc private func handleScrollViewTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: collectionAuthorLinkLabel)
        if collectionAuthorLinkLabel.bounds.contains(location) {
            authorLinkTapped()
        }
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
        print("Link tapped")
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
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure(let error):
                print("Error loading cover image: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    private func configureUI(with model: NftCollectionModel) {
        if let coverURL = URL(string: model.cover) {
            activityIndicator.startAnimating()
            loadImage(from: coverURL) { [weak self] image in
                DispatchQueue.main.async {
                    guard let self = self else {
                        return }
                    
                    self.activityIndicator.stopAnimating()
                    self.coverImageView.image = image
                }
            }
        }
        collectionTitleLabel.text = model.name
        collectionAuthorLinkLabel.text = model.author
        collectionDescriptionLabel.text = model.description
        
        collectionView.reloadData()
        
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "appWhite")
        view.addSubview(customNavigationBar)
        customNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        [
            coverImageView,
            collectionTitleLabel,
            collectionDescriptionLabel,
            collectionView,
            collectionAuthorLabel,
            collectionAuthorLinkLabel,
            activityIndicator
        ].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupScrollViewConsraints()
        setupContainerViewConsraints()
        setupCustomNavigationBarConstraints()
        setupCoverImageViewConstraints()
        setupActivityIndicatorConstraints()
        setupCollectionTitleLabelConstraints()
        setupCollectionAuthorLabelConstraints()
        setupCollectionAuthorLinkLabelConstraints()
        setupCollectionDescriptionLabelConstraints()
        setupCollectionViewConstraints()
        
        view.bringSubviewToFront(customNavigationBar)
    }
    
    // MARK: - Setup Constraints
    private func setupScrollViewConsraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupContainerViewConsraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupCustomNavigationBarConstraints() {
        NSLayoutConstraint.activate([
            customNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    private func setupCoverImageViewConstraints() {
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: view.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 310)
        ])
    }
    
    private func setupActivityIndicatorConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
    }
    
    private func setupCollectionTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            collectionTitleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            collectionTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            collectionTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCollectionAuthorLabelConstraints() {
        NSLayoutConstraint.activate([
            collectionAuthorLabel.topAnchor.constraint(equalTo: collectionTitleLabel.bottomAnchor, constant: 13),
            collectionAuthorLabel.leadingAnchor.constraint(equalTo: collectionTitleLabel.leadingAnchor)
        ])
    }
    
    private func setupCollectionAuthorLinkLabelConstraints() {
        NSLayoutConstraint.activate([
            collectionAuthorLinkLabel.leadingAnchor.constraint(
                equalTo: collectionAuthorLabel.trailingAnchor,
                constant: 4
            ),
            collectionAuthorLinkLabel.bottomAnchor.constraint(equalTo: collectionAuthorLabel.bottomAnchor)
        ])
    }
    
    private func setupCollectionDescriptionLabelConstraints() {
        NSLayoutConstraint.activate([
            collectionDescriptionLabel.topAnchor.constraint(equalTo: collectionAuthorLabel.bottomAnchor, constant: 5),
            collectionDescriptionLabel.leadingAnchor.constraint(equalTo: collectionTitleLabel.leadingAnchor),
            collectionDescriptionLabel.trailingAnchor.constraint(equalTo: collectionTitleLabel.trailingAnchor)
        ])
    }
    
    private func setupCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: collectionDescriptionLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: collectionTitleLabel.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: collectionTitleLabel.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        let width = (collectionView.bounds.width - 2 * interItemSpacing) / 3
        return CGSize(width: width, height: 202)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 16
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
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension NftCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    func scrollViewShouldScrollWhenContentReceivesTouch(_ scrollView: UIScrollView, touch: UITouch) -> Bool {
        let location = touch.location(in: collectionAuthorLinkLabel)
        
        return !collectionAuthorLinkLabel.bounds.contains(location)
    }
}
