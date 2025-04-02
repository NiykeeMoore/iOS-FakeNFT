//
//  CatalogCell.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 25.03.2025.
//

import UIKit
import Kingfisher

final class CatalogCell: UITableViewCell {
    
    static let identifier = "CatalogCell"
    static let height: CGFloat = 187
    
    private let previewImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let previewText: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "appBlack")
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.text = "Empty collection (0)"
        
        return label
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: NftCollectionPreviewModel) {
        loadingIndicator.startAnimating()
        if let url = URL(string: model.cover) {
            loadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    guard let self = self else {
                        return
                    }
                    self.loadingIndicator.stopAnimating()
                    self.previewImage.image = image
                }
            }
        } else {
            loadingIndicator.stopAnimating()
            
        }
        previewText.text = "\(model.name) (\(model.count))"
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure(let error):
                print("Error loading image: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func setupView() {
        [
            previewText,
            previewImage,
            loadingIndicator
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            previewImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            previewImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            previewImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            previewImage.heightAnchor.constraint(equalToConstant: 140),
            
            previewText.topAnchor.constraint(equalTo: previewImage.bottomAnchor, constant: 4),
            previewText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            previewText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: previewImage.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: previewImage.centerYAnchor)
        ])
    }
}
