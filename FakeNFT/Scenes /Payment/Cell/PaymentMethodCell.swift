//
//  PaymentMethodCell.swift
//  FakeNFT
//
//  Created by Niykee Moore on 19.04.2025.
//

import UIKit
import Kingfisher

final class PaymentMethodCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: PaymentMethodCell.self)
    
    // MARK: - UI Elements
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "appLightGrayDynamic")
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor(named: "appBlackDynamic")
        imageView.tintColor = UIColor(named: "appWhiteDynamic")
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "appBlackDynamic")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var abbreviationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "appGreen")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, abbreviationLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    
    override var isSelected: Bool {
        didSet {
            updateSelectionAppearance()
        }
    }
    
    // MARK: - prepareForReuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.kf.cancelDownloadTask()
        iconImageView.image = nil
        iconImageView.backgroundColor = UIColor(named: "appBlackDynamic")
        iconImageView.contentMode = .center
        nameLabel.text = nil
        abbreviationLabel.text = nil
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        updateSelectionAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(with method: PaymentMethod) {
        nameLabel.text = method.name
        abbreviationLabel.text = method.title
        
        iconImageView.backgroundColor = UIColor(named: "appBlackDynamic")
        
        if let url = URL(string: method.image) {
            iconImageView.kf.setImage(with: url) { [weak self] result in
                guard let self else {
                    return
                }
                switch result {
                case .success:
                    self.iconImageView.backgroundColor = .clear
                    self.iconImageView.contentMode = .scaleAspectFit
                case .failure:
                    self.iconImageView.backgroundColor = UIColor(named: "appBlackDynamic")
                    self.iconImageView.contentMode = .center
                }
            }
            updateSelectionAppearance()
        }
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(labelsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36),
            
            labelsStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 4),
            labelsStackView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    // MARK: - Private Methods
    
    private func updateSelectionAppearance() {
        containerView.layer.borderWidth = isSelected ? 1 : 0
        
        containerView.layer.borderColor = isSelected ?
        UIColor(named: "appBlackDynamic")?.cgColor :
        UIColor.clear.cgColor
    }
}
