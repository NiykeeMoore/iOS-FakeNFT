//
//  ProfileInfoView.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 27.03.2025.
//

import UIKit
import Kingfisher
import SafariServices

final class ProfileViewController: UIViewController {
    private var viewModel: ProfileViewModelProtocol
    private var tableData: [(String, Int?)] = []
    
    // MARK: - UI Elements
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
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
        imageView.backgroundColor = UIColor(named: "appLightGrayDynamic")
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: viewModel.profileData?.avatar ?? ""))
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(named: "appBlackDynamic")
        label.text = viewModel.profileData?.name ?? ""
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.text = viewModel.profileData?.description  ?? ""
        label.textColor = UIColor(named: "appBlackDynamic")
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var websiteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.text = viewModel.profileData?.website  ?? ""
        label.textColor = UIColor(named: "appBlue")
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.layoutMargins = .zero
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat.greatestFiniteMagnitude)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "ProfileTableViewCell")
        return tableView
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 26)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: imageConfig)?
            .withTintColor(UIColor(named: "appBlackDynamic") ?? .black, renderingMode: .alwaysOriginal)
        
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupConstraints()
        viewModel.loadProfile()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        viewModel.onProfileUpdate = { [weak self] profileData in
            self?.updateUI(with: profileData)
        }
        
        viewModel.onError = { [weak self] error in
            self?.showErrorAlert(errorDescription: error.localizedDescription)
        }
        
        viewModel.isLoading = { [weak self] isLoading in
            if isLoading {
                self?.contentView.isHidden = true
                self?.activityIndicator.startAnimating()
            } else {
                self?.contentView.isHidden = false
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func setupView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor(named: "appWhiteDynamic")
        
        view.addSubview(contentView)
        view.addSubview(activityIndicator)
        
        contentView.addSubview(editButton)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(websiteLabel)
        contentView.addSubview(tableView)
        
        // Add button actions
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func updateUI(with profileData: ProfileData) {
        profileImageView.kf.setImage(with: URL(string: profileData.avatar ?? ""))
        nameLabel.text = profileData.name
        descriptionLabel.text = profileData.description
        websiteLabel.text = profileData.website
        tableData = viewModel.getTableData()
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    private func showErrorAlert(errorDescription: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Error.title", comment: ""),
            message: errorDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
            
            // Website Label
            websiteLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            websiteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            websiteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: websiteLabel.bottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(3 * 54)),
            
            // Loader View
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
        ) as? ProfileTableViewCell else {
            return UITableViewCell()
        }
        
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
            showMyNFTs()
        case 1:
            showLikedNFTs()
        case 2:
            openWebsite()
        default:
            break
        }
    }
    
    func showMyNFTs() {
        guard let profileData = viewModel.profileData else {
            return
        }
        
        let myNFTsVM = MyNFTsViewModel(
            profileService: viewModel.profileService,
            profileData: profileData,
            onClose: myNFTSClosed
        )
        let myNFTsVC = MyNFTsViewController(viewModel: myNFTsVM)
        
        myNFTsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(myNFTsVC, animated: true)
    }
    
    func showLikedNFTs() {
        guard let profileData = viewModel.profileData else {
            return
        }
        
        let likedNFTsVM = LikedNFTsViewModel(
            profileService: viewModel.profileService,
            profileData: profileData,
            onClose: myNFTSClosed
        )
        let likedNFTsVC = LikedNFTsViewController(viewModel: likedNFTsVM)
        
        likedNFTsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(likedNFTsVC, animated: true)
    }
    
    func myNFTSClosed(likes: [String]) {
        viewModel.updateLikes(likes)
        tableData = viewModel.getTableData()
        tableView.reloadData()
    }
    
    func openWebsite() {
        guard let url = viewModel.validateWebsiteURL() else {
            showErrorAlert(errorDescription: NSLocalizedString("Webview.invalidURL", comment: ""))
            return
        }
        
        let config = SFSafariViewController.Configuration()
        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.preferredControlTintColor = UIColor(named: "appBlackDynamic")
        
        present(safariVC, animated: true)
    }
}

// MARK: - Update ProfileViewController
extension ProfileViewController {
    @objc private func editButtonTapped() {
        guard let profileData = viewModel.profileData else {
            return
        }
        
        let editVC = EditProfileViewController(
            profileData: profileData
        ) { [weak self] updatedProfile in
            self?.viewModel.updateProfile(updatedProfile)
        }
        
        editVC.modalPresentationStyle = .pageSheet
        present(editVC, animated: true)
    }
}
