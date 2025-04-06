//
//  NFTTableViewCell.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 06.04.2025.
//

import UIKit
import Kingfisher

final class NFTTableViewCell: UITableViewCell {
    static let identifier = "NFTTableViewCell"
    private var onLikeButtonTapped: (() -> Void)?
    
    private var isLiked: Bool = false {
        didSet {
            likeButton.tintColor = isLiked ? UIColor(named: "appRed") : UIColor(named: "appWhite")
        }
    }
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "heart.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingView = StarRatingView()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "appBlackDynamic")
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = NSLocalizedString("MyNFT.priceLabel", comment: "")
        label.textColor = UIColor(named: "appBlackDynamic")
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        infoStackView.addArrangedSubview(authorLabel)
        contentView.addSubview(infoStackView)
        
        priceStackView.addArrangedSubview(priceLabel)
        priceStackView.addArrangedSubview(priceValueLabel)
        contentView.addSubview(priceStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Image
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            // Like Button
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Info stack
            infoStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            infoStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceStackView.leadingAnchor, constant: -20),
            
            // Price stack
            priceStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            priceStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceStackView.widthAnchor.constraint(equalToConstant: 88)
        ])
    }
    
    func configure(nft: ProfileNFT, isLiked: Bool, onLikeButtonTapped: @escaping () -> Void) {
        self.onLikeButtonTapped = onLikeButtonTapped
        self.isLiked = isLiked
        nftImageView.kf.setImage(with: URL(string: nft.images[0]))
        nameLabel.text = nft.name
        ratingView.rating = nft.rating
        authorLabel.text = "\(NSLocalizedString("MyNFT.byAuthor", comment: "")) \(nft.author)"
        priceValueLabel.text = nft.formattedPrice
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
