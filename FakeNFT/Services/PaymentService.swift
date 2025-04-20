//
//  PaymentService.swift
//  FakeNFT
//
//  Created by Niykee Moore on 20.04.2025.
//

import Foundation

protocol PaymentServiceProtocol {
    func loadPaymentMethods(completion: @escaping (Result<[PaymentMethod], Error>) -> Void)
}

final class PaymentService: PaymentServiceProtocol {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadPaymentMethods(completion: @escaping (Result<[PaymentMethod], Error>) -> Void) {
        let request = GetPaymentMethodsRequest()
        networkClient.send(request: request, type: [PaymentMethod].self) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
