//
//  ProfileViewModel.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 30.03.2025.
//

import Foundation

protocol ProfileViewModelProtocol {
    // MARK: - Properties
    var profileData: ProfileData? { get }
    var profileService: ProfileService { get }
    var nftService: NftService { get }
    
    // MARK: - Observables
    var onProfileUpdate: ((ProfileData) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    var isLoading: ((Bool) -> Void)? { get set }
    
    // MARK: - Public Methods
    func loadProfile()
    func updateProfile(_ newData: ProfileData)
    func updateLikes(_ likes: [String])
    func getTableData() -> [(String, Int?)]
    func validateWebsiteURL() -> URL?
}

final class ProfileViewModel: ProfileViewModelProtocol {
    // MARK: - Properties
    var profileService: ProfileService
    var nftService: NftService
    private(set) var profileData: ProfileData?
    
    // MARK: - Observables
    var onProfileUpdate: ((ProfileData) -> Void)?
    var onError: ((Error) -> Void)?
    var isLoading: ((Bool) -> Void)?
    
    // MARK: - Initialization
    init(profileService: ProfileService, nftService: NftService) {
        self.profileService = profileService
        self.nftService = nftService
    }
    
    // MARK: - Public Methods
    func loadProfile() {
        isLoading?(true)
        profileService.loadProfileData(id: "1") { [weak self] result in
            self?.isLoading?(false)
            switch result {
            case .success(let data):
                self?.profileData = data
                
                // For Testing
                self?.profileData?.nfts = [
                    "ca34d35a-4507-47d9-9312-5ea7053994c0",
                    "1fda6f0c-a615-4a1a-aa9c-a1cbd7cc76ae",
                    "9e472edf-ed51-4901-8cfc-8eb3f617519f"
                ]
                
                self?.onProfileUpdate?(data)
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func updateProfile(_ newData: ProfileData) {
        isLoading?(true)
        profileService.updateProfileData(id: "1", newData: newData) { [weak self] result in
            self?.isLoading?(false)
            switch result {
            case .success(let data):
                self?.profileData = data
                self?.onProfileUpdate?(data)
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func updateLikes(_ likes: [String]) {
        profileData?.likes = likes
    }
    
    func getTableData() -> [(String, Int?)] {
        return [
            (NSLocalizedString("Profile.myNFT", comment: ""), profileData?.nfts?.count),
            (NSLocalizedString("Profile.likedNFT", comment: ""), profileData?.likes?.count),
            (NSLocalizedString("Profile.website", comment: ""), nil)
        ]
    }
    
    func validateWebsiteURL() -> URL? {
        guard let website = profileData?.website else {
            return nil
        }
        return URL(string: website)
    }
}
