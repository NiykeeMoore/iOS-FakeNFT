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
        self.isItemLiked.toggle()
        setLikeButtonState(isLiked: self.isItemLiked)
        
        let likesService = LikesService(networkClient: DefaultNetworkClient())
        likesService.getLikes { [weak self] likes in
            guard let self = self,
                  let likes = likes else {
                return
            }
            if self.isItemLiked {
                self.addItemToLikes(likesService, likes)
            } else {
                self.removeItemFromLikes(likesService, likes)
            }
        }
    }
    
    @objc func cartButtonTapped() {
        
    }
    
    private func setupLayout() {
           [nftImageView, likeButton, ratingStackView, nameLabel, priceLabel, cartButton].forEach {
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
    
    func configure(with model: NftCollectionCellModel) {
        nftImageView.kf.setImage(with: model.image)
        nameLabel.text = model.name
        let priceString = String(format: "%.2f", model.price)
        priceLabel.text = priceString + " ETH"
        itemId = model.id
        setLikeButtonState(isLiked: model.isLiked)
        setCartButtonState(isAdded: model.isAddedToCart)
        setRating(rating: model.rating)
    }
    
    private func addItemToLikes(_ likesService: LikesService, _ likes: Likes) {
        var updatedLikes = likes.likes
        updatedLikes.append(self.itemId)
        likesService.setLike(nftsIds: updatedLikes) { error in
            if error != nil {
                return
            }
            DispatchQueue.main.async {
                self.setLikeButtonState(isLiked: true)
                self.isItemLiked = true
            }
        }
    }
    
    private func removeItemFromLikes(_ likesService: LikesService, _ likes: Likes) {
        var updatedLikes = likes.likes
        if let index = updatedLikes.firstIndex(of: self.itemId) {
            updatedLikes.remove(at: index)
        }
        likesService.setLike(nftsIds: updatedLikes) { error in
            if error != nil {
                return
            }
            DispatchQueue.main.async {
                self.setLikeButtonState(isLiked: false)
                self.isItemLiked = false
            }
        }
    }
    
    private func setLikeButtonState(isLiked: Bool) {
        likeButton.tintColor = isLiked ? UIColor(named: "appRed") : UIColor(named: "appWhite")
    }
    
    private func setCartButtonState(isAdded: Bool) {
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
