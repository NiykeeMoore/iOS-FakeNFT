//
//  CatalogViewModel.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 25.03.2025.
//

import Foundation

protocol CatalogViewModelProtocol {
    var catalogItems: [NftCollectionModel] { get }
    var sortType: SortType { get set }
    func getCollections(completion: @escaping ([NftCollectionModel]) -> Void)
    func sortCatalog(by sortType: SortType) -> [NftCollectionModel]
}

final class CatalogViewModel: CatalogViewModelProtocol {
    
    var catalogItems: [NftCollectionModel] = []
    var sortType: SortType = .none
    private let netWorkClient: NetworkClient
    
    init(netWorkClient: NetworkClient) {
        self.netWorkClient = netWorkClient
    }
    
    func sortCatalog(by sortType: SortType) -> [NftCollectionModel] {
        switch sortType {
        case .byName:
            catalogItems = catalogItems.sorted { $0.name < $1.name }
        case .byQuantity:
            catalogItems = catalogItems.sorted { $0.count > $1.count }
        case .none:
            break
        }
        return catalogItems
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
