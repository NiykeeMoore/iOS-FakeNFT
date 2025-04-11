//
//  LikesService.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 10.04.2025.
//

import Foundation

final class LikesService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func getLikes(completion: @escaping ([String]?) -> Void) {
        let request = LikesRequest(httpMethod: .get)
        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("Successfully fetched profile: \(profile)")
                    completion(profile.likes)
                case .failure(let error):
                    print("Failed to get profile with error: \(error)")
                    if let networkError = error as? NetworkClientError {
                        switch networkError {
                        case .httpStatusCode(let code):
                            print("HTTP status code: \(code)")
                        case .urlRequestError(let underlyingError):
                            print("URL request error: \(underlyingError)")
                        case .urlSessionError:
                            print("URL session error")
                        case .parsingError:
                            print("Parsing error")
                        }
                    }
                    completion(nil)
                }
            }
        }
    }
    
    func setLike(nftsIds: [String], completion: @escaping (Result<Profile, Error>) -> Void) {
        let request = LikesRequest(httpMethod: .put, nftsIds: nftsIds)
        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    completion(.success(profile))
                case .failure(let error):
                    print("Failed to set like: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
}
