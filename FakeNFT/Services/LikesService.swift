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
    
    func getLikes(completion: @escaping (Likes?) -> Void) {
        networkClient.send(request: LikesRequest(httpMethod: .get), type: Likes.self) { [weak self] result in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let likes):
                    completion(likes)
                case .failure(let error):
                    completion(nil)
                }
            }
        }
    }
    
    func setLike(nftsIds: [String], completion: @escaping (Error?) -> Void) {
          let nftsString = nftsIds.joined(separator: ",")
          let bodyString = "nfts=\(nftsString)"
          guard let bodyData = bodyString.data(using: .utf8) else { return }

        guard let url = URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1") else { return }
          var request = URLRequest(url: url)
          request.httpMethod = "PUT"
          request.setValue("application/json", forHTTPHeaderField: "Accept")
          request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("\(RequestConstants.token)", forHTTPHeaderField: "X-Practicum-Mobile-Token")
          if nftsIds.count != 0 {
              request.httpBody = bodyData
          }

          let task = URLSession.shared.dataTask(with: request) { _, _, error in
              if let error = error {
                  completion(error)
                  return
              }
              completion(nil)
          }
          task.resume()
      }
}
