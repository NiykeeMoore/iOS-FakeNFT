//
//  CartViewModel.swift
//  FakeNFT
//
//  Created by Niykee Moore on 31.03.2025.
//

import Foundation

protocol CartViewModel {
    var onItemsUpdate: (() -> Void)? { get set }
    var onTotalUpdate: ((Int, String) -> Void)? { get set }
    var onLoadingStateChange: ((Bool) -> Void)? { get set }
    var onError: ((ErrorModel) -> Void)? { get set }
    var didSortButtonTapped: (() -> Void)? { get set }
    var onSortStateDidChanged: ((CartSortType) -> Void)? { get }
    
    func numberOfItems() -> Int
    func item(at indexPath: IndexPath) -> CartItem?
    func viewDidLoad()
    func retryLoad()
    func deleteItem(withId id: String)
}

final class CartViewModelImpl: CartViewModel {
    var onItemsUpdate: (() -> Void)?
    var onTotalUpdate: ((Int, String) -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?
    var onError: ((ErrorModel) -> Void)?
    var didSortButtonTapped: (() -> Void)?
    var onSortStateDidChanged: ((CartSortType) -> Void)?
    
    private let cartService: CartService
    private var cartItemsInternal: [CartItem] = []
    private var cartItems: [CartItem] = [] {
        didSet {
            onItemsUpdate?()
            calculateTotal()
        }
    }
    
    private var state = CartState.initial {
        didSet {
            stateDidChanged()
        }
    }
    
    private var sortState = CartSortType.nameDescending {
        didSet {
            sortItems(by: sortState, items: cartItemsInternal) { [weak self] sortedItems in
                guard let self else {
                    return
                }
                self.cartItemsInternal = sortedItems
                self.onItemsUpdate?()
            }
        }
    }
    
    init(cartService: CartService) {
        self.cartService = cartService
        
        onSortStateDidChanged = { [weak self] sortType in
            guard let self else {
                return
            }
            self.sortState = sortType
        }
    }
    
    // MARK: - CartViewModel Protocol
    
    func viewDidLoad() {
        state = .loading
    }
    
    func retryLoad() {
        state = .loading
    }
    
    func numberOfItems() -> Int {
        return cartItemsInternal.count
    }
    
    func item(at indexPath: IndexPath) -> CartItem? {
        guard indexPath.row < cartItemsInternal.count else {
            return nil
        }
        return cartItemsInternal[indexPath.row]
    }
    
    func deleteItem(withId id: String) {
        let currentIds = cartItemsInternal.map { $0.id }
        let updatedNftIds = currentIds.filter { $0 != id }
        
        onLoadingStateChange?(true)
        
        cartService.updateOrder(with: updatedNftIds) { [weak self] result in
            guard let self else {
                return
            }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedOrder):
                    self.updateLocalItems(basedOn: updatedOrder.nfts)
                    self.onLoadingStateChange?(false)
                    
                case .failure(let error):
                    self.onLoadingStateChange?(false)
                    let errorModel = self.makeErrorModel(error, context: "Удаление NFT")
                    self.onError?(errorModel)
                }
            }
        }
    }
    
    private func updateLocalItems(basedOn serverNftIds: [String]) {
        let serverSet = Set(serverNftIds)
        let updatedItems = self.cartItemsInternal.filter { serverSet.contains($0.id) }
        cartItemsInternal = updatedItems
        cartItems = updatedItems
    }
    
    // MARK: - Private Methods
    
    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("Невозможно перейти в начальное состояние")
            
        case .loading:
            onLoadingStateChange?(true)
            loadCartData()
            
        case .data(let items):
            onLoadingStateChange?(false)
            //todo вот тут надо показать 0 и отправить плейсхолдер
            cartItemsInternal = items
            sortItems(by: sortState, items: items) { [weak self] sortedItems in
                guard let self else {
                    return
                }
                self.cartItemsInternal = sortedItems
                self.cartItems = sortedItems
            }
            
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            onLoadingStateChange?(false)
            onError?(errorModel)
        }
    }
    
    private func loadCartData() {
        cartService.loadOrder { [weak self] result in
            guard let self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.state = .data(items)
                case .failure(let error):
                    self.state = .failed(error)
                }
            }
        }
    }
    
    private func calculateTotal() {
        let totalCount = cartItemsInternal.count
        let totalPrice = cartItemsInternal.reduce(0.0) { $0 + $1.price }
        let formattedPrice = String(format: "%.2f ETH", totalPrice)
        
        onTotalUpdate?(totalCount, formattedPrice)
    }
    
    private func makeErrorModel(_ error: Error, context: String? = nil) -> ErrorModel {
        let baseMessage: String
        switch error {
        case is NetworkClientError:
            baseMessage = NSLocalizedString("Error.network", comment: "")
        default:
            baseMessage = NSLocalizedString("Error.unknown", comment: "")
        }
        
        let message = context != nil ? "\(context ?? ""): \(baseMessage)" : baseMessage
        
        let actionText = NSLocalizedString("Error.repeat", comment: "")
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            guard let self else {
                return
            }
            
            if context == "Удаление NFT" {
                
                print("Ошибка при удалении, повторная попытка не реализована в makeErrorModel")
            } else {
                self.retryLoad()
            }
        }
    }
    
    private func sortItems(by sortType: CartSortType, items: [CartItem], completion: @escaping ([CartItem]) -> Void) {
        DispatchQueue.global().async {
            var sortedItems = items
            switch sortType {
            case .priceDescending:
                sortedItems.sort { $0.price > $1.price }
            case .nameDescending:
                sortedItems.sort { $0.name < $1.name }
            case .raitingDescending:
                sortedItems.sort { $0.rating > $1.rating }
            case .cancel:
                break
            }
            DispatchQueue.main.async {
                completion(sortedItems)
            }
        }
    }
}
