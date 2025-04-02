//
//  CatalogViewModel.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 25.03.2025.
//

import Foundation

protocol CatalogViewModelProtocol {
    var catalogItems: [NftCollectionPreviewModel] { get }
    func getCollections(completion: @escaping ([NftCollectionPreviewModel]) -> Void)
}

final class CatalogViewModel: CatalogViewModelProtocol {
    
    var catalogItems: [NftCollectionPreviewModel] = []
    private let netWorkClient: NetworkClient
    
    init(netWorkClient: NetworkClient) {
        self.netWorkClient = netWorkClient
    }
    
    func getCollections(completion: @escaping ([NftCollectionPreviewModel]) -> Void) {
        netWorkClient.send(request: GetNftCollectionsRequest(), type: [NftCollectionPreviewModel].self) { [weak self] result in
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
