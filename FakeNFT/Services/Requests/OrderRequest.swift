//
//  OrderRequest.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 12.04.2025.
//

import Foundation

struct OrderRequest: NetworkRequest {
    private let method: HttpMethod
    let nftsIds: [String]?
    
    init(httpMethod: HttpMethod, nftsIds: [String]? = nil) {
        self.method = httpMethod
        self.nftsIds = nftsIds
    }
    
    var endpoint: URL? {
        guard let baseURL = URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1") else {
            return nil
        }
        
        if method == .get {
            return baseURL
        }
        
        guard let nftsIds = nftsIds else {
            return baseURL
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        if !nftsIds.isEmpty {
            components?.queryItems = nftsIds.map { URLQueryItem(name: "nfts", value: $0) }
        }
        return components?.url
    }
    
    var httpMethod: HttpMethod {
        return method
    }
    
    var headers: [String: String]? {
        if method == .put {
            return ["Content-Type": "application/x-www-form-urlencoded"]
        }
        return nil
    }
    
    var dto: Dto? {
        guard let nftsIds = nftsIds else { return nil }
        return OrderDto(nftsIds: nftsIds)
    }
}

struct OrderDto: Dto {
    let nftsIds: [String]
    
    func asDictionary() -> [String: String] {
        return [:]
    }
}
