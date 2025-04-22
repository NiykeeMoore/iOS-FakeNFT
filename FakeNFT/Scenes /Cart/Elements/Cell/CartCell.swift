//
//  CartCell.swift
//  FakeNFT
//
//  Created by Niykee Moore on 26.03.2025.
//

import UIKit
import Kingfisher

final class CartCell: UITableViewCell {
    // MARK: - Properties
    var didDeletionButtonTapped: ((CartItem) -> Void)?
    
    static let reuseIdentifier = String(describing: CartCell.self)
    private var currentItem: CartItem?
    
    // MARK: - UI Components
    private lazy var itemImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.cornerRadius = 12
        return image
    }()
    
    private lazy var itemNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(named: "appBlackDynamic")
        return label
    }()
    
    private let itemRatingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        return stackView
    }()
    
    private lazy var itemPriceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("NFT.Cell.price", comment: "Цена")
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var itemPriceValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private lazy var removeFromCartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "iconCartItemRemove"), for: .normal)
        button.tintColor = UIColor(named: "appBlackDynamic")
        button.addTarget(self, action: #selector(removeFromCartButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = UIColor(resource: .appWhiteDynamic)
        
        [
            itemImageView,
            itemNameLabel,
            itemRatingStackView,
            itemPriceTitleLabel,
            itemPriceValueLabel,
            removeFromCartButton
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            itemImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            itemImageView.widthAnchor.constraint(equalTo: itemImageView.heightAnchor),
            
            itemNameLabel.topAnchor.constraint(equalTo: itemImageView.topAnchor, constant: 8),
            itemNameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 20),
            itemNameLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: removeFromCartButton.leadingAnchor,
                constant: -16
            ),
            
            itemRatingStackView.topAnchor.constraint(equalTo: itemNameLabel.bottomAnchor, constant: 4),
            itemRatingStackView.leadingAnchor.constraint(equalTo: itemNameLabel.leadingAnchor),
            
            itemPriceTitleLabel.topAnchor.constraint(equalTo: itemRatingStackView.bottomAnchor, constant: 12),
            itemPriceTitleLabel.leadingAnchor.constraint(equalTo: itemNameLabel.leadingAnchor),
            
            itemPriceValueLabel.topAnchor.constraint(equalTo: itemPriceTitleLabel.bottomAnchor, constant: 4),
            itemPriceValueLabel.leadingAnchor.constraint(equalTo: itemNameLabel.leadingAnchor),
            itemPriceValueLabel.bottomAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: -8),
            
            removeFromCartButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeFromCartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            removeFromCartButton.widthAnchor.constraint(equalToConstant: 40),
            removeFromCartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with item: CartItem) {
        currentItem = item
        itemNameLabel.text = item.name
        itemPriceValueLabel.text = String(format: "%.2f ETH", item.price)
        configureRating(item.rating)
        
        if let imageURL = item.imageURL {
            itemImageView.kf.indicatorType = .activity
            itemImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(named: "nftPlaceholder") // TODO: посмотреть плейсхолдер
            )
        } else {
            itemImageView.image = UIImage(named: "nftPlaceholder") // TODO: определиться с дефолтом
        }
    }
    
    // MARK: - Private methods
    private func configureRating(_ rating: Int) {
        itemRatingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for index in 0..<5 {
            let starImage = (index < rating) ?
            UIImage(named: "iconRatingStarActive") :
            UIImage(named: "iconRatingStarNoActive")
            
            let imageView = UIImageView(image: starImage)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            itemRatingStackView.addArrangedSubview(imageView)
        }
    }
    
    // MARK: - Actions
    @objc private func removeFromCartButtonTapped() {
        if let item = currentItem {
            didDeletionButtonTapped?(item)
        }
    }
}
