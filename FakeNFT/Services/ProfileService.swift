import Foundation

typealias ProfileCompletion = (Result<ProfileData, Error>) -> Void

protocol ProfileService {
    func loadProfileData(id: String, completion: @escaping ProfileCompletion)
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
    
    func updateProfileData(id: String, newData: ProfileData, completion: @escaping ProfileCompletion) {
        let dto = ProfileDtoObject(
            avatar: newData.avatar,
            name: newData.name,
            description: newData.description,
            website: newData.website
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
