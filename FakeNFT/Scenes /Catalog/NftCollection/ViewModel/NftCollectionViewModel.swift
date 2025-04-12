//
//  NftCollectionViewModel.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 02.04.2025.
//

import Foundation

protocol NftCollectionViewModelProtocol {
    var loadedNFTs: [Nft] { get }
    var collectionInfo: NftCollectionModel { get }
    var authorURLString: String { get }
    
    var onLikesUpdated: ((String?) -> Void)? { get set }
    
    func loadNFTs(completion: @escaping () -> Void)
    func loadCollectionInfo(completion: @escaping () -> Void)
    func returnCollectionCell(for index: Int) -> NftCollectionCellModel
    func isLiked(_ idOfCell: String) -> Bool
    func isAddedToCart(_ idOfCell: String) -> Bool
    func toggleLike(for nftId: String)
    func toggleCart(for nftId: String)
}

final class NftCollectionViewModel: NftCollectionViewModelProtocol {
    
    typealias Completion = (Result<Nft, Error>) -> Void
    
    var authorURLString: String = "https://practicum.yandex.ru/ios-developer/"
    
    private let nftCollectionModel: NftCollectionModel
    private let nftService: NftService
    private let likesService: LikesService
    var loadedNFTs: [Nft] = []
    var collectionInfo: NftCollectionModel { nftCollectionModel }
    var onLikesUpdated: ((String?) -> Void)?
    
    private var idLikes: Set<String> = []
    private var idAddedToCart: Set<String> = []
    
    init(nftCollectionModel: NftCollectionModel, nftService: NftService, likesService: LikesService) {
        self.nftCollectionModel = nftCollectionModel
        self.nftService = nftService
        self.likesService = likesService
    }
    
    func loadNFTs(completion: @escaping () -> Void) {
        likesService.getLikes { [weak self] likes in
            guard let self = self else {
                completion()
                return
            }
            
            if let likes = likes {
                self.idLikes = Set(likes)
                print("Loaded likes: \(self.idLikes)")
            } else {
                print("Failed to load likes")
            }
            
            self.loadedNFTs.removeAll()
            
            if let nftServiceImpl = self.nftService as? NftServiceImpl {
                nftServiceImpl.clearCache()
            }
            
            let group = DispatchGroup()
            
            for id in self.nftCollectionModel.nfts {
                group.enter()
                self.nftService.loadNft(id: id) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    switch result {
                    case .success(let nft):
                        self.loadedNFTs.append(nft)
                    case .failure(let error):
                        print("Error loading NFT \(id): \(error.localizedDescription)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    func loadCollectionInfo(completion: @escaping () -> Void) {
        completion()
    }
    
    func returnCollectionCell(for index: Int) -> NftCollectionCellModel {
        let nftForIndex = loadedNFTs[index]
        return NftCollectionCellModel(
            image: nftForIndex.images[0],
            name: nftForIndex.name,
            rating: nftForIndex.rating,
            price: nftForIndex.price,
            isLiked: isLiked(nftForIndex.id),
            isAddedToCart: isAddedToCart(nftForIndex.id),
            id: nftForIndex.id
        )
    }
    
    func isLiked(_ idOfCell: String) -> Bool {
        idLikes.contains(idOfCell)
    }
    
    func isAddedToCart(_ idOfCell: String) -> Bool {
        idAddedToCart.contains(idOfCell)
    }
    
    func toggleLike(for nftId: String) {
        let wasLiked = isLiked(nftId)
        if wasLiked {
            idLikes.remove(nftId)
        } else {
            idLikes.insert(nftId)
        }
        print("Optimistically set isItemLiked to \(!wasLiked) for item \(nftId)")
        
        let updatedLikes = Array(idLikes)
        likesService.setLike(nftsIds: updatedLikes) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                self.idLikes = Set(profile.likes)
                print("Successfully synced likes: \(profile.likes)")
                print("Calling onLikesUpdated for nftId: \(nftId)")
                self.onLikesUpdated?(nftId)
            case .failure(let error):
                if wasLiked {
                    self.idLikes.insert(nftId)
                } else {
                    self.idLikes.remove(nftId)
                }
                print("Failed to sync likes: \(error)")
                print("Calling onLikesUpdated for nftId: \(nftId) after failure")
                self.onLikesUpdated?(nftId)
            }
        }
    }
    
    func toggleCart(for nftId: String) {
        if isAddedToCart(nftId) {
            idAddedToCart.remove(nftId)
        } else {
            idAddedToCart.insert(nftId)
        }
    }
}
