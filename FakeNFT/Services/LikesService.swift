//
//  LikesService.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 10.04.2025.
//

import Foundation

final class LikesService {
    private let networkClient: NetworkClient
    private var cachedLikes: [String]?
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func getLikes(completion: @escaping ([String]?) -> Void) {
        if let cachedLikes = cachedLikes {
            print("Returning cached likes: \(cachedLikes)")
            completion(cachedLikes)
            return
        }
        
        let request = LikesRequest(httpMethod: .get)
        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("Successfully fetched profile: \(profile)")
                    self.cachedLikes = profile.likes
                    completion(profile.likes)
                case .failure(let error):
                    print("Failed to get profile with error: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    func setLike(nftsIds: [String], completion: @escaping (Result<Profile, Error>) -> Void) {
        let request = LikesRequest(httpMethod: .put, nftsIds: nftsIds.isEmpty ? [] : nftsIds)
        print("Sending setLike request with nftsIds: \(nftsIds)")
        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("Successfully fetched profile: \(profile)")
                    self.cachedLikes = profile.likes
                    completion(.success(profile))
                case .failure(let error):
                    print("Failed to set like: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
}
