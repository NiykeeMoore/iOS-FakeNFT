//
//  CartService.swift
//  FakeNFT
//
//  Created by Niykee Moore on 31.03.2025.
//

import Foundation

typealias CartCompletion = (Result<[CartItem], Error>) -> Void
typealias CartUpdateCompletion = (Result<OrderResult, Error>) -> Void

protocol CartService {
    func loadOrder(completion: @escaping CartCompletion)
    func updateOrder(with nftIds: [String], completion: @escaping CartUpdateCompletion)
}

final class CartServiceImpl: CartService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadOrder(completion: @escaping CartCompletion) {
        let request = GetOrderRequest()
        
        networkClient.send(request: request, type: OrderResult.self) { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success(let orderResult):
                if orderResult.nfts.isEmpty {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                self.loadNftsDetails(ids: orderResult.nfts, completion: completion)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func loadNftsDetails(ids: [String], completion: @escaping CartCompletion) {
        var loadedNfts: [Nft] = []
        let group = DispatchGroup()
        
        ids.forEach { id in
            group.enter()
            let nftRequest = NFTRequest(id: id)
            
            networkClient.send(request: nftRequest, type: Nft.self) { result in
                switch result {
                case .success(let nft):
                    loadedNfts.append(nft)
                case .failure(let error):
                    print("Ошибка загрузки nft id \(id): \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let cartItems = loadedNfts.map { nft in
                CartItem(
                    id: nft.id,
                    name: nft.name,
                    imageURL: nft.images.first,
                    price: nft.price,
                    rating: nft.rating
                )
            }
            completion(.success(cartItems))
        }
    }
    
    func updateOrder(with nftIds: [String], completion: @escaping CartUpdateCompletion) {
        let request = UpdateOrderRequest(nftIds: nftIds)

        networkClient.send(request: request, type: OrderResult.self) { result in
            switch result {
            case .success(let updatedOrder):
                completion(.success(updatedOrder))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
