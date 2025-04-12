//
//  NftCollectionViewCell.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 02.04.2025.
//

//
//  NftCollectionViewCell.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 02.04.2025.
//

import UIKit
import Kingfisher

final class NftCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NftCollectionViewCell"
    
    private var isItemInCart: Bool = false
    private var isItemLiked: Bool = false
    private var isLikeRequestInProgress: Bool = false
    private var itemId: String = ""
    var onLikeButtonTapped: ((String) -> Void)?
    var onCartButtonTapped: ((String) -> Void)?
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(systemName: "heart.fill"),
            for: .normal
        )
        button.tintColor = .white
        button.addTarget(
            self,
            action: #selector(likeButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var likeButtonActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        
        let stars: [UIImageView] = (0..<5).map { _ in
            let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
            imageView.contentMode = .scaleAspectFit
            return imageView
        }
        
        stars.forEach { stackView.addArrangedSubview($0)}
        
        return stackView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var cartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cartAdd"), for: .normal)
        button.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func likeButtonTapped() {
        guard !isLikeRequestInProgress else {
            print("Like request is already in progress, ignoring tap")
            return
        }
        
        isLikeRequestInProgress = true
        likeButtonActivityIndicator.startAnimating()
        likeButton.isEnabled = false
        
        let desiredLikeState = !self.isItemLiked
        self.isItemLiked = desiredLikeState
        setLikeButtonState(isLiked: desiredLikeState)
        print("Optimistically set isItemLiked to \(desiredLikeState) for item \(itemId)")
        
        onLikeButtonTapped?(itemId)
    }
    
    @objc func cartButtonTapped() {
        onCartButtonTapped?(itemId)
    }
    
    private func setupLayout() {
        [nftImageView, likeButton, likeButtonActivityIndicator, ratingStackView, nameLabel, priceLabel, cartButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            
            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40),
            
            likeButtonActivityIndicator.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor),
            likeButtonActivityIndicator.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            ratingStackView.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 8),
            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            nameLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: cartButton.leadingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            priceLabel.trailingAnchor.constraint(equalTo: cartButton.leadingAnchor, constant: -8),
            
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            cartButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func calculateFittingHeight(for width: CGFloat) -> CGFloat {
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let fittingSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return fittingSize.height
    }
    
    func configure(with model: NftCollectionCellModel) {
        nftImageView.kf.setImage(with: model.image)
        nameLabel.text = model.name
        let priceString = String(format: "%.2f", model.price)
        priceLabel.text = priceString + " ETH"
        itemId = model.id
        isItemLiked = model.isLiked
        setLikeButtonState(isLiked: model.isLiked)
        print("Configured cell with isLiked = \(model.isLiked) for item \(itemId)")
        setCartButtonState(isAdded: model.isAddedToCart)
        setRating(rating: model.rating)
    }
    
    func completeLikeRequest(isLiked: Bool) {
        isLikeRequestInProgress = false
        likeButtonActivityIndicator.stopAnimating()
        likeButton.isEnabled = true
        self.isItemLiked = isLiked
        setLikeButtonState(isLiked: isLiked)
        print("Completed like request, set isLiked to \(isLiked) for item \(itemId)")
    }
    
    private func setLikeButtonState(isLiked: Bool) {
        likeButton.tintColor = isLiked ? UIColor(named: "appRed") : UIColor(named: "appWhite")
        print("Set like button state to \(isLiked) for item \(itemId)")
    }
    
    func setCartButtonState(isAdded: Bool) {
        let image = isAdded ? UIImage(named: "cartDelete") : UIImage(named: "cartAdd")
        cartButton.setImage(image, for: .normal)
    }
    
    private func setRating(rating: Int) {
        guard let arrangedSubviews = ratingStackView.arrangedSubviews as? [UIImageView] else {
            return
        }
        
        for (index, starImageView) in arrangedSubviews.enumerated() {
            starImageView.tintColor = index < rating
            ? UIColor(named: "appYellow")
            : UIColor(named: "appLightGrayDynamic")
        }
    }
}
