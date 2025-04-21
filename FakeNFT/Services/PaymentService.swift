//
//  PaymentService.swift
//  FakeNFT
//
//  Created by Niykee Moore on 20.04.2025.
//

import Foundation

protocol PaymentServiceProtocol {
    func loadPaymentMethods(completion: @escaping (Result<[PaymentMethod], Error>) -> Void)
    func performPayment(currencyId: String, completion: @escaping (Result<PaymentResult, Error>) -> Void)
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
    
    func performPayment(currencyId: String, completion: @escaping (Result<PaymentResult, Error>) -> Void) {
        let request = PerformPaymentRequest(currencyId: currencyId)
        networkClient.send(request: request, type: PaymentResult.self, completionQueue: .main, onResponse: completion)
    }
}
