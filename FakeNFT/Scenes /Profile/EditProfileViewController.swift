//
//  EditProfileViewController.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 29.03.2025.
//

import UIKit
import Kingfisher

// MARK: - Edit Profile View Controller
final class EditProfileViewController: UIViewController {
    // MARK: - Properties
    private var profileData: ProfileData
    private var onClose: (ProfileData) -> Void
    private var imageURL: String?
    
    // MARK: - UI Elements
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileImageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 35
        button.backgroundColor = .lightGray
        button.contentMode = .scaleAspectFill
        
        // Create dark overlay view
        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlayView.layer.cornerRadius = 35
        overlayView.isUserInteractionEnabled = false
        
        // Create "Change" label
        let changeLabel = UILabel()
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        changeLabel.text = NSLocalizedString("Profile.changeImgLabel", comment: "")
        changeLabel.textColor = .white
        changeLabel.font = .systemFont(ofSize: 10, weight: .medium)
        changeLabel.textAlignment = .center
        changeLabel.numberOfLines = 2
        
        // Add overlay and label to button
        button.addSubview(overlayView)
        button.addSubview(changeLabel)
        
        // Set constraints
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: button.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            
            changeLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            changeLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            changeLabel.widthAnchor.constraint(equalTo: button.widthAnchor, constant: -8)
        ])
        
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)?
            .withTintColor(UIColor(named: "appBlackDynamic") ?? .black, renderingMode: .alwaysOriginal)
        
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    private lazy var nameTextField = TextFieldView(
        title: NSLocalizedString("Profile.editNameTitle", comment: ""),
        initialValue: profileData.name
    )
    
    private lazy var descriptionTextField = TextFieldView(
        title: NSLocalizedString("Profile.editDescTitle", comment: ""),
        initialValue: profileData.description,
        isTextView: true
    )
    
    private lazy var websiteTextField = TextFieldView(
        title: NSLocalizedString("Profile.editSiteTitle", comment: ""),
        initialValue: profileData.website
    )
    
    // MARK: - Initialization
    init(profileData: ProfileData, onClose: @escaping (ProfileData) -> Void) {
        self.profileData = profileData
        self.onClose = onClose
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let newData = ProfileData(
            id: profileData.id,
            avatar: imageURL ?? profileData.avatar,
            name: nameTextField.getValue(),
            description: descriptionTextField.getValue(),
            website: websiteTextField.getValue(),
            nfts: profileData.nfts,
            likes: profileData.likes
        )
        onClose(newData)
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(contentView)
        contentView.addSubview(closeButton)
        contentView.addSubview(profileImageButton)
        contentView.addSubview(nameTextField)
        contentView.addSubview(descriptionTextField)
        contentView.addSubview(websiteTextField)
        
        // Actions
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        profileImageButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
        
        // Set the initial image (using Kingfisher)
        if let url = URL(string: profileData.avatar) {
            profileImageButton.kf.setImage(with: url, for: .normal)
            profileImageButton.imageView?.contentMode = .scaleAspectFill
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Content View
            contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Close Button
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 42),
            closeButton.heightAnchor.constraint(equalToConstant: 42),
            
            // Profile Image
            profileImageButton.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 22),
            profileImageButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageButton.widthAnchor.constraint(equalToConstant: 70),
            profileImageButton.heightAnchor.constraint(equalToConstant: 70),
            
            // Name Text Field
            nameTextField.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Description Text View
            descriptionTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            descriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Website Text Field
            websiteTextField.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 24),
            websiteTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            websiteTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func profileImageButtonTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("Profile.changeImgTitle", comment: ""),
            message: NSLocalizedString("Profile.changeImgDesc", comment: ""),
            preferredStyle: .alert
        )
        
        // Add text field to the alert
        alert.addTextField { textField in
            textField.placeholder = "https://example.com/photo.jpg"
            textField.keyboardType = .URL
            textField.textContentType = .URL
            textField.autocapitalizationType = .none
            textField.clearButtonMode = .whileEditing
        }
        
        // Add OK action
        let okAction = UIAlertAction(
            title: NSLocalizedString("Profile.okButton", comment: ""),
            style: .default
        ) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let urlString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !urlString.isEmpty else {
                return
            }
            
            // Update image view with new URL
            if let url = URL(string: urlString) {
                self.profileImageButton.kf.setImage(with: url, for: .normal)
                self.imageURL = urlString
            } else {
                self.showInvalidURLError()
            }
        }
        alert.addAction(okAction)
        
        // Add Cancel action
        let cancelAction = UIAlertAction(title: NSLocalizedString("Profile.cancelButton", comment: ""), style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showInvalidURLError() {
        let alert = UIAlertController(
            title: NSLocalizedString("Profile.invalidImgURLTitle", comment: ""),
            message: NSLocalizedString("Profile.invalidImgURLDesc", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Profile.okButton", comment: ""), style: .default))
        present(alert, animated: true)
    }
}
