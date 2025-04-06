import Foundation

typealias ProfileCompletion = (Result<ProfileData, Error>) -> Void
typealias ProfileNFTCompletion = (Result<ProfileNFT, Error>) -> Void

protocol ProfileService {
    func loadProfileData(id: String, completion: @escaping ProfileCompletion)
    func loadNFT(id: String, completion: @escaping ProfileNFTCompletion)
    func updateProfileData(id: String, newData: ProfileData, completion: @escaping ProfileCompletion)
}

final class ProfileServiceImpl: ProfileService {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadProfileData(id: String, completion: @escaping ProfileCompletion) {
        let request = ProfileRequest(id: id, httpMethod: .get)
        networkClient.send(request: request, type: ProfileData.self) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadNFT(id: String, completion: @escaping ProfileNFTCompletion) {
        let request = NFTRequest(id: id)
        networkClient.send(request: request, type: ProfileNFT.self) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateProfileData(id: String, newData: ProfileData, completion: @escaping ProfileCompletion) {
        let dto = ProfileDtoObject(
            name: newData.name,
            avatar: newData.avatar,
            description: newData.description,
            website: newData.website,
            nfts: newData.nfts,
            likes: newData.likes
        )
        let request = ProfileRequest(id: id, httpMethod: .put, dto: dto)
        networkClient.send(request: request, type: ProfileData.self) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
