//
//  CatalogViewModel.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 25.03.2025.
//

import Foundation

protocol CatalogViewModelProtocol {
    var catalogItems: [NftCollectionModel] { get }
    func getCollections(completion: @escaping ([NftCollectionModel]) -> Void)
}

final class CatalogViewModel: CatalogViewModelProtocol {
    
    var catalogItems: [NftCollectionModel] = []
    private let netWorkClient: NetworkClient
    
    init(netWorkClient: NetworkClient) {
        self.netWorkClient = netWorkClient
    }
    
    func getCollections(completion: @escaping ([NftCollectionModel]) -> Void) {
        netWorkClient.send(request: GetNftCollectionsRequest(), type: [NftCollectionModel].self) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let collections):
                self.catalogItems = collections
                completion(collections)
            case .failure(let error):
                print("Error fetching NFT collections: \(error.localizedDescription)")
                completion([])
            }
        }
    }
    
}
