//
//  EditProfileViewModel.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 30.03.2025.
//

import Foundation

final class EditProfileViewModel {
    // MARK: - Properties
    private let servicesAssembly: ServicesAssembly
    private(set) var profileData: ProfileData
    
    // MARK: - Initialization
    init(profileData: ProfileData, servicesAssembly: ServicesAssembly) {
        self.profileData = profileData
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - Public Methods
    func updateAvatar(_ urlString: String) -> Bool {
        guard URL(string: urlString) != nil else { return false }
        profileData.avatar = urlString
        return true
    }
    
    func getUpdatedProfile(name: String, description: String, website: String) -> ProfileData {
        return ProfileData(
            id: profileData.id,
            avatar: profileData.avatar,
            name: name,
            description: description,
            website: website,
            nfts: profileData.nfts,
            likes: profileData.likes
        )
    }
}
