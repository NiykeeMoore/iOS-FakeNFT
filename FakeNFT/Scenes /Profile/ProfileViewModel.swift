//
//  ProfileViewModel.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 30.03.2025.
//

import Foundation

final class ProfileViewModel {
    // MARK: - Properties
    private let servicesAssembly: ServicesAssembly
    private(set) var profileData: ProfileData?
    
    // MARK: - Observables
    var onProfileUpdate: ((ProfileData) -> Void)?
    var onError: ((Error) -> Void)?
    var isLoading: ((Bool) -> Void)?
    
    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - Public Methods
    func loadProfile() {
        isLoading?(true)
        servicesAssembly.profileService.loadProfileData(id: "1") { [weak self] result in
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
    
    func updateProfile(_ newData: ProfileData) {
        isLoading?(true)
        servicesAssembly.profileService.updateProfileData(id: "1", newData: newData) { [weak self] result in
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
    
    func getTableData() -> [(String, Int?)] {
        return [
            ("Мои NFT", profileData?.nfts.count),
            ("Избранные NFT", profileData?.likes.count),
            ("О разработчике", nil)
        ]
    }
    
    func validateWebsiteURL() -> URL? {
        guard let website = profileData?.website else {
            return nil
        }
        return URL(string: website)
    }
}
