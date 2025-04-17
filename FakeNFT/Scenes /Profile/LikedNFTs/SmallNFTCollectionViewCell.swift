//
//  NFTCollectionViewCell.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 11.04.2025.
//

import UIKit
import Kingfisher

final class NFTCollectionViewCell: UICollectionViewCell {
    static let identifier = "NFTCollectionViewCell"
    private var onLikeButtonTapped: (() -> Void)?
    
    private var isLiked: Bool = false {
        didSet {
            likeButton.tintColor = isLiked ? UIColor(named: "appRed") : UIColor(named: "appWhite")
        }
    }
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "heart.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingView = StarRatingView()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(likeButton)
        
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(ratingView)
        infoStackView.addArrangedSubview(priceLabel)
        contentView.addSubview(infoStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Image
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 80),
            nftImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Like Button
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: -6),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 6),
            likeButton.widthAnchor.constraint(equalToConstant: 42),
            likeButton.heightAnchor.constraint(equalToConstant: 42),
            
            // Info stack
            infoStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 12),
            infoStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(nft: ProfileNFT, isLiked: Bool, onLikeButtonTapped: @escaping () -> Void) {
        self.onLikeButtonTapped = onLikeButtonTapped
        self.isLiked = isLiked
        nftImageView.kf.setImage(with: URL(string: nft.images[0]))
        nameLabel.text = nft.name
        ratingView.rating = nft.rating
        priceLabel.text = nft.formattedPrice
        likeButton.addTarget(self, action: #selector(likeButtonAction), for: .touchUpInside)
    }
    
    @objc private func likeButtonAction() {
        isLiked.toggle()
        onLikeButtonTapped?()
        
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.likeButton.transform = .identity
                }
            }
        )
    }
}
