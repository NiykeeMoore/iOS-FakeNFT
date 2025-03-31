import UIKit

final class TabBarController: UITabBarController {

    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogViewModel = CatalogViewModel(netWorkClient: DefaultNetworkClient())
        let catalogViewController = CatalogViewController(viewModel: catalogViewModel)
        catalogViewController.tabBarItem = catalogTabBarItem

        viewControllers = [catalogViewController]

        view.backgroundColor = UIColor(named: "appWhite")
        tabBar.unselectedItemTintColor = UIColor(named: "appBlack")
        tabBar.isTranslucent = false
    }
}
