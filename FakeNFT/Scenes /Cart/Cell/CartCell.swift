//
//  CartCell.swift
//  FakeNFT
//
//  Created by Niykee Moore on 26.03.2025.
//

import UIKit

final class CartCell: UITableViewCell {
    // MARK: - Properties
    
    static let reuseIdentifier = String(describing: CartCell.self)
    
    // MARK: - UI Components
    
    private lazy var itemImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "nft"))
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var itemNameLabel: UILabel = {
        let label = UILabel()
        label.text = "April"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(named: "appBlackDynamic")
        return label
    }()
    
    private let itemRatingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        
        let filledStar = UIImageView(image: UIImage(named: "iconRatingStarActive"))
        stackView.addArrangedSubview(filledStar)
        
        for _ in 1..<5 {
            let emptyStar = UIImageView(image: UIImage(named: "iconRatingStarNoActive"))
            stackView.addArrangedSubview(emptyStar)
        }
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
        label.text = "1,78 ETH"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private lazy var removeFromCartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "iconCartItemRemove"), for: .normal)
        button.tintColor = UIColor(named: "appBlackDynamic")
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
        contentView.backgroundColor = .clear
        
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
            itemPriceTitleLabel.bottomAnchor.constraint(equalTo: itemPriceValueLabel.topAnchor, constant: -2),
            
            itemPriceValueLabel.topAnchor.constraint(equalTo: itemPriceTitleLabel.bottomAnchor, constant: 4),
            itemPriceValueLabel.leadingAnchor.constraint(equalTo: itemNameLabel.leadingAnchor),
            itemPriceValueLabel.bottomAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: -8),
            
            removeFromCartButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeFromCartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            removeFromCartButton.widthAnchor.constraint(equalToConstant: 40),
            removeFromCartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
