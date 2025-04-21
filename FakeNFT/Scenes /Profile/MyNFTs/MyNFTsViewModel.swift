//
//  ProfileViewModel.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 30.03.2025.
//

import Foundation

enum SortOption: String {
    case price
    case rating
    case name
}

protocol MyNFTsViewModelProtocol {
    // MARK: - Properties
    var nfts: [ProfileNFT] { get }
    var profileData: ProfileData { get }
    
    // MARK: - Observables
    var onUpdate: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    var isLoading: ((Bool) -> Void)? { get set }
    
    // MARK: - Public Methods
    func loadNFTs()
    func sortNFTs(by option: SortOption?)
    func likedNFT(_ id: String)
    func onCloseHandler()
}

final class MyNFTsViewModel: MyNFTsViewModelProtocol {
    // MARK: - Properties
    var profileData: ProfileData
    let onClose: ([String]) -> Void
    
    private let sortOptionKey = "myNFTSorting"
    private let service: ProfileService
    private(set) var nfts: [ProfileNFT] = []
    
    // MARK: - Observables
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    var isLoading: ((Bool) -> Void)?
    
    // MARK: - Initialization
    init(profileService: ProfileService, profileData: ProfileData, onClose: @escaping ([String]) -> Void) {
        self.service = profileService
        self.profileData = profileData
        self.onClose = onClose
    }
    
    // MARK: - Public Methods
    func loadNFTs() {
        isLoading?(true)
        let nftIds = profileData.nfts ?? []
        
        var tempNFTs: [ProfileNFT?] = Array(repeating: nil, count: nftIds.count)
        var remainingRequests = nftIds.count
        var hasError = false
        
        for (index, nftId) in nftIds.enumerated() {
            service.loadNFT(id: nftId) { [weak self] result in
                DispatchQueue.main.async {
                    remainingRequests -= 1
                    
                    switch result {
                    case .success(let data):
                        tempNFTs[index] = data
                    case .failure(let error):
                        hasError = true
                        print("Failed to load NFT \(nftId): \(error)")
                    }
                    
                    if remainingRequests == 0 {
                        self?.isLoading?(false)
                        let loadedNFTs = tempNFTs.compactMap { $0 }
                        
                        if hasError {
                            self?.onError?(
                                NSError(
                                    domain: "",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Failed to load NFTs"]
                                )
                            )
                        }
                        self?.nfts = loadedNFTs
                        self?.sortNFTs(by: nil)
                        self?.onUpdate?()
                    }
                }
            }
        }
    }
    
    func sortNFTs(by option: SortOption?) {
        var currentOption: SortOption
        
        // if SortOption is nil, get value from UserDefaults
        if let option {
            currentOption = option
        } else {
            if let rawValue = UserDefaults.standard.string(forKey: sortOptionKey) {
                currentOption = SortOption(rawValue: rawValue) ?? .rating
            } else {
                currentOption = .rating
            }
        }
        
        isLoading?(true)
        
        // Sorting
        switch currentOption {
        case .price:
            nfts.sort { $0.price > $1.price }
        case .rating:
            nfts.sort { $0.rating > $1.rating }
        case .name:
            nfts.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        }
        
        UserDefaults.standard.set(currentOption.rawValue, forKey: sortOptionKey)
        
        isLoading?(false)
        onUpdate?()
    }
    
    func likedNFT(_ id: String) {
        if profileData.likes?.contains(id) ?? false {
            profileData.likes = profileData.likes?.filter { $0 != id }
        } else {
            if profileData.likes == nil {
                profileData.likes = [id]
            } else {
                profileData.likes?.append(id)
            }
        }
        
        service.updateProfileData(id: "1", newData: profileData) { [weak self] result in
            switch result {
            case .success(_):
                print("liked")
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func onCloseHandler() {
        onClose(profileData.likes ?? [])
    }
}
