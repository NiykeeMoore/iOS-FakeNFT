//
//  ProfileTableViewCell.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 27.03.2025.
//

import UIKit

final class ProfileTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    private let customAccessoryView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular)
        imageView.image = UIImage(systemName: "chevron.right")?
            .withConfiguration(config)
            .withTintColor(UIColor(named: "appBlackDynamic") ?? .systemFill, renderingMode: .alwaysOriginal)
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func setupCell() {
        // Remove default padding/margins
        preservesSuperviewLayoutMargins = false
        contentView.preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = .zero
        
        // Customize selection
        selectionStyle = .none
        
        // Configure text label
        textLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        textLabel?.textColor = UIColor(named: "appBlackDynamic")
        
        // Add custom accessory
        contentView.addSubview(customAccessoryView)
        
        NSLayoutConstraint.activate([
            customAccessoryView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customAccessoryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            customAccessoryView.widthAnchor.constraint(equalToConstant: 14),
            customAccessoryView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(title: String, count: Int?) {
        if let count {
            textLabel?.text = "\(title) (\(count))"
        } else {
            textLabel?.text = title
        }
    }
}
