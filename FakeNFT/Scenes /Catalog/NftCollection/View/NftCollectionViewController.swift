//
//  NftCollectionViewController.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 02.04.2025.
//

import UIKit

final class NftCollectionViewController: UIViewController, LoadingView {
    
    var activityIndicator: UIActivityIndicatorView
    
    private let viewModel: NftCollectionViewModelProtocol
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(systemName: "chevron.backward"),
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        return scrollView
    }()
    
    private lazy var coverImageView: UIImageView = {
        let coverImage = UIImageView()
        coverImage.contentMode = .scaleAspectFill
        coverImage.clipsToBounds = true
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
        
        return author
    }()
    
    private lazy var collectionAuthorLinkLabel: UILabel = {
        let label = UILabel()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openAuthorLink))
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(named: "appBlue")
        
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
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            NftCollectionViewCell.self,
            forCellWithReuseIdentifier: NftCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = UIColor(named: "appWhite")
        
        return collectionView
    }()
    
    init(activityIndicator: UIActivityIndicatorView, viewModel: NftCollectionViewModelProtocol) {
        self.activityIndicator = UIActivityIndicatorView(style: .large)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    @objc func backButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func openAuthorLink() {
        
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "appWhite")
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            backButton,
            coverImageView,
            collectionTitleLabel,
            collectionAuthorLabel,
            collectionAuthorLinkLabel,
            collectionDescriptionLabel,
            collectionView,
            activityIndicator
        ].forEach {
            scrollView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            
            coverImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 310),
            
            activityIndicator.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            collectionTitleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            collectionTitleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            collectionTitleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            
            collectionAuthorLabel.topAnchor.constraint(equalTo: collectionTitleLabel.bottomAnchor, constant: 13),
            collectionAuthorLabel.leadingAnchor.constraint(equalTo: collectionTitleLabel.leadingAnchor),
            
            collectionAuthorLinkLabel.leadingAnchor.constraint(equalTo: collectionAuthorLabel.trailingAnchor, constant: 4),
            collectionAuthorLinkLabel.bottomAnchor.constraint(equalTo: collectionAuthorLabel.bottomAnchor),
            
            collectionDescriptionLabel.topAnchor.constraint(equalTo: collectionAuthorLabel.bottomAnchor, constant: 5),
            collectionDescriptionLabel.leadingAnchor.constraint(equalTo: collectionTitleLabel.leadingAnchor),
            collectionDescriptionLabel.trailingAnchor.constraint(equalTo: collectionTitleLabel.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: collectionDescriptionLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: collectionTitleLabel.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: collectionTitleLabel.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout

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

//MARK: UICollectionViewDataSource

extension NftCollectionViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        <#code#>
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        <#code#>
    }
    
}

//MARK: UIScrollViewDelegate

extension NftCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
}
