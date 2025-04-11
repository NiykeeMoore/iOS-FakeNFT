//
//  NftCollectionViewHeader.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 11.04.2025.
//

import UIKit
import Kingfisher

final class NftCollectionViewHeader: UICollectionReusableView {
    
    static let reuseIdentifier = "NftCollectionViewHeader"
    
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(named: "appBlue")
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAuthorLinkTap))
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
    
    private var authorLinkAction: (() -> Void)?
    private var coverHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleAuthorLinkTap() {
        authorLinkAction?()
    }
    
    func configure(
        with model: NftCollectionModel,
        authorLinkAction: @escaping () -> Void,
        completion: @escaping () -> Void
    ) {
        collectionTitleLabel.text = model.name
        collectionAuthorLinkLabel.text = model.author
        collectionDescriptionLabel.text = model.description
        self.authorLinkAction = authorLinkAction
        
        setNeedsLayout()
        layoutIfNeeded()
        
        if let url = URL(string: model.cover) {
            coverImageView.kf.setImage(
                with: url,
                placeholder: nil
            ) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                    
                    completion()
                }
            
        } else {
            completion()
        }
    }
    
    private func setupViews() {
        [
            coverImageView,
            collectionTitleLabel,
            collectionAuthorLabel,
            collectionAuthorLinkLabel,
            collectionDescriptionLabel
        ].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        // Сохраняем ограничение высоты для coverImageView
        coverHeightConstraint = coverImageView.heightAnchor.constraint(equalToConstant: 310)
        coverHeightConstraint?.priority = .defaultHigh
        
        // Ограничение расстояния между collectionAuthorLabel и collectionAuthorLinkLabel
        let authorSpacingConstraint = collectionAuthorLinkLabel.leadingAnchor.constraint(
            equalTo: collectionAuthorLabel.trailingAnchor,
            constant: 4
        )
        authorSpacingConstraint.priority = .defaultHigh
        
        // Ограничение минимальной ширины collectionTitleLabel
        let titleWidthConstraint = collectionTitleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        titleWidthConstraint.priority = .defaultHigh
        
        // Ограничение правого отступа collectionTitleLabel
        let titleTrailingConstraint = collectionTitleLabel.trailingAnchor.constraint(
            lessThanOrEqualTo: trailingAnchor,
            constant: -16
        )
        titleTrailingConstraint.priority = .defaultHigh
        
        // Ограничение отступа между collectionTitleLabel и collectionAuthorLabel
        let titleToAuthorConstraint = collectionAuthorLabel.topAnchor.constraint(
            equalTo: collectionTitleLabel.bottomAnchor,
            constant: 8
        )
        titleToAuthorConstraint.priority = .defaultHigh // Приоритет ниже 1000
        
        // Ограничение отступа между collectionAuthorLabel и collectionDescriptionLabel
        let authorToDescriptionConstraint = collectionDescriptionLabel.topAnchor.constraint(
            equalTo: collectionAuthorLabel.bottomAnchor,
            constant: 8
        )
        authorToDescriptionConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverHeightConstraint!,
            
            collectionTitleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            collectionTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleTrailingConstraint,
            titleWidthConstraint,
            
            titleToAuthorConstraint,
            collectionAuthorLabel.leadingAnchor.constraint(equalTo: collectionTitleLabel.leadingAnchor),
            
            authorSpacingConstraint,
            collectionAuthorLinkLabel.centerYAnchor.constraint(equalTo: collectionAuthorLabel.centerYAnchor),
            collectionAuthorLinkLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            
            authorToDescriptionConstraint,
            collectionDescriptionLabel.leadingAnchor.constraint(equalTo: collectionTitleLabel.leadingAnchor),
            collectionDescriptionLabel.trailingAnchor.constraint(equalTo: collectionTitleLabel.trailingAnchor),
            collectionDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func calculatedHeight(for width: CGFloat) -> CGFloat {
        frame = CGRect(x: 0, y: 0, width: width, height: 0)
        setNeedsLayout()
        layoutIfNeeded()
        
        let availableWidth = width - 16 - 16
        let coverHeight: CGFloat = 310
        let titleSize = collectionTitleLabel.sizeThatFits(CGSize(
            width: availableWidth,
            height: .greatestFiniteMagnitude
        ))
        let authorLabelSize = collectionAuthorLabel.sizeThatFits(CGSize(
            width: availableWidth,
            height: .greatestFiniteMagnitude
        ))
        let authorLinkSize = collectionAuthorLinkLabel.sizeThatFits(CGSize(
            width: availableWidth,
            height: .greatestFiniteMagnitude
        ))
        let authorHeight = max(
            authorLabelSize.height,
            authorLinkSize.height
        )
        let descriptionSize = collectionDescriptionLabel.sizeThatFits(CGSize(
            width: availableWidth,
            height: .greatestFiniteMagnitude
        ))
        
        let totalHeight = coverHeight + 4 + titleSize.height + 8 + authorHeight + 8 + descriptionSize.height + 8
        
        return totalHeight
    }
}
