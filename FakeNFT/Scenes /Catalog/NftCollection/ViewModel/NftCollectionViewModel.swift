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
    func loadNFTs(completion: @escaping () -> Void)
    func loadCollectionInfo(completion: @escaping () -> Void)
    func returnCollectionCell(for index: Int) -> NftCollectionCellModel
    func isLiked(_ idOfCell: String) -> Bool
    func isAddedToCart(_ idOfCell: String) -> Bool
}

final class NftCollectionViewModel: NftCollectionViewModelProtocol {
    
    typealias Completion = (Result<Nft, Error>) -> Void
    
    var authorURLString: String = "https://practicum.yandex.ru/ios-developer/"
    
    private let nftCollectionModel: NftCollectionModel
    private let nftService: NftService
    var loadedNFTs: [Nft] = []
    var collectionInfo: NftCollectionModel { nftCollectionModel }
    
    private var idLikes: Set<String> = []
    private var idAddedToCart: Set<String> = []
    
    init(nftCollectionModel: NftCollectionModel, nftService: NftService) {
        self.nftCollectionModel = nftCollectionModel
        self.nftService = nftService
    }
    
    func loadNFTs(completion: @escaping () -> Void) {
        loadedNFTs.removeAll()
        let group = DispatchGroup()
        
        for id in nftCollectionModel.nfts {
            group.enter()
            nftService.loadNft(id: id) { [weak self] result in
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
}
