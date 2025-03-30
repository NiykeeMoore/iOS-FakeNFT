//
//  ProfileInfoView.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 27.03.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let servicesAssembly: ServicesAssembly
    private var profileData: ProfileData?
    
    // MARK: - UI Elements
    
    private lazy var activityIndicator = UIActivityIndicatorView()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.backgroundColor = .lightGray
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: profileData?.avatar ?? ""))
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(named: "appBlackDynamic")
        label.text = profileData?.name ?? ""
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.text = profileData?.description  ?? ""
        label.textColor = UIColor(named: "appBlackDynamic")
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var websiteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(profileData?.website ?? "", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.layoutMargins = .zero
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat.greatestFiniteMagnitude)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "ProfileTableViewCell")
        return tableView
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 26)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: imageConfig)?
            .withTintColor(UIColor(named: "appBlackDynamic") ?? .black, renderingMode: .alwaysOriginal)
        
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    private lazy var tableData = [
        ("Мои NFT", profileData?.nfts.count ?? 0),
        ("Избранные NFT", profileData?.likes.count ?? 0),
        ("О разработчике", nil)
    ]
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loader View
        view.addSubview(activityIndicator)
        activityIndicator.constraintCenters(to: view)
        
        loadProfileData()
    }
    
    // MARK: - Setup
    
    private func loadProfileData() {
        activityIndicator.startAnimating()

        servicesAssembly.profileService.loadProfileData(id: "1") { [weak self] result in
            switch result {
            case .success(let data):
                self?.profileData = data
                self?.setupView()
                self?.setupConstraints()
                self?.setupTableView()
                self?.activityIndicator.stopAnimating()
            case .failure(let error):
                print("Could not load profile data: \(error)")
            }
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Профиль"
        
        view.addSubview(contentView)
        
        contentView.addSubview(editButton)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(websiteButton)
        contentView.addSubview(tableView)
        contentView.addSubview(activityIndicator)
        
        // Add button actions
        websiteButton.addTarget(self, action: #selector(websiteButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Actions
    
    @objc private func websiteButtonTapped() {
        if let url = URL(string: "https://yandex.ru") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Content View
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Edit Profile Button
            editButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 42),
            editButton.heightAnchor.constraint(equalToConstant: 42),
            
            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Website Button
            websiteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            websiteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            websiteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(tableData.count * 54))
        ])
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProfileTableViewCell", for: indexPath
        ) as? ProfileTableViewCell
        else { return UITableViewCell() }
        
        let (title, count) = tableData[indexPath.row]
        cell.configure(title: title, count: count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            print("Мои NFT tapped")
        case 1:
            print("Избранные NFT tapped")
        case 2:
            print("О разработчике tapped")
        default:
            break
        }
    }
}

// MARK: - Update ProfileViewController
extension ProfileViewController {
    @objc private func editButtonTapped() {
        guard let profileData = profileData
        else { return }
        
        let editVC = EditProfileViewController(
            profileData: profileData,
            servicesAssembly: servicesAssembly
        ) { [weak self] updatedProfile in
            self?.updateData(newData: updatedProfile)
        }
        
        editVC.modalPresentationStyle = .pageSheet
        present(editVC, animated: true)
    }
    
    private func updateData(newData: ProfileData) {
        activityIndicator.startAnimating()
        let service = servicesAssembly.profileService
        service.updateProfileData(id: "1", newData: newData) { [weak self] result in
            switch result {
            case .success(let data):
                self?.profileData = data
                self?.profileImageView.kf.setImage(with: URL(string: data.avatar))
                self?.nameLabel.text = data.name
                self?.descriptionLabel.text = data.description
                self?.websiteButton.setTitle(data.website, for: .normal)
                self?.activityIndicator.stopAnimating()
            case .failure(let error):
                print("Could not update profile data: \(error)")
            }
        }
    }
}
