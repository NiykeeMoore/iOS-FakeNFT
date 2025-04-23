//
//  ProfileViewModel.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 30.03.2025.
//

import Foundation

protocol LikedNFTsViewModelProtocol {
    // MARK: - Properties
    var nfts: [ProfileNFT] { get }
    var profileData: ProfileData { get }
    
    // MARK: - Observables
    var onUpdate: (() -> Void)? { get set }
    var onRemoveNFT: ((IndexPath) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    var isLoading: ((Bool) -> Void)? { get set }
    
    // MARK: - Public Methods
    func loadNFTs()
    func unlikedNFT(_ id: String)
    func onCloseHandler()
}

final class LikedNFTsViewModel: LikedNFTsViewModelProtocol {
    // MARK: - Properties
    var profileData: ProfileData
    let onClose: ([String]) -> Void
    
    private let service: ProfileService
    private(set) var nfts: [ProfileNFT] = []
    
    // MARK: - Observables
    var onUpdate: (() -> Void)?
    var onRemoveNFT: ((IndexPath) -> Void)?
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
        let nftIds = profileData.likes ?? []
        
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
                        self?.onUpdate?()
                    }
                }
            }
        }
    }
    
    func unlikedNFT(_ id: String) {
        guard let index = nfts.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let newData = ProfileData(likes: profileData.likes?.filter { $0 != id })
        
        service.updateProfileData(id: "1", newData: newData) { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success(_):
                if index >= nfts.count {
                    return
                }
                nfts.remove(at: index)
                profileData.likes?.remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                onRemoveNFT?(indexPath)
            case .failure(let error):
                onError?(error)
            }
        }
    }
    
    func onCloseHandler() {
        onClose(profileData.likes ?? [])
    }
}
