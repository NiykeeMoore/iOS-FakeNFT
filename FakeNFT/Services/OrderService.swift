//
//  OrderService.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 12.04.2025.
//

import Foundation

final class OrderService {
    private let networkClient: NetworkClient
    private var cachedOrder: [String]?
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func getOrder(completion: @escaping ([String]?) -> Void) {
        if let cachedOrder = cachedOrder {
            print("Returning cached order: \(cachedOrder)")
            completion(cachedOrder)
            return
        }
        
        let request = OrderRequest(httpMethod: .get)
        networkClient.send(request: request, type: Order.self) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let order):
                    print("Successfully fetched order: \(order)")
                    self.cachedOrder = order.nfts
                    completion(order.nfts)
                case .failure(let error):
                    print("Failed to get order with error: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    func setOrder(nftsIds: [String], completion: @escaping (Result<Order, Error>) -> Void) {
        let request = OrderRequest(httpMethod: .put, nftsIds: nftsIds.isEmpty ? [] : nftsIds)
        print("Sending setOrder request with nftsIds: \(nftsIds)")
        networkClient.send(request: request, type: Order.self) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let order):
                    print("Successfully fetched order: \(order)")
                    self.cachedOrder = order.nfts
                    completion(.success(order))
                case .failure(let error):
                    print("Failed to set order: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
}

struct Order: Decodable {
    let nfts: [String]
    let id: String
}
