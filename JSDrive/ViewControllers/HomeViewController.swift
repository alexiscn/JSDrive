import UIKit
import Foundation

class HomeViewController: UIViewController {
    
    enum Section { case main }
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, DriveScript>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupCollectionView()
        setupDataSource()
        applySnapshot()
    }
    
    private func setupNavBar() {
        navigationItem.title = "JSDrive"
        
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonTapped))
        navigationItem.rightBarButtonItem = addItem
    }
    
    @objc private func onAddButtonTapped() {
        let url = Bundle.main.url(forResource: "template", withExtension: "js")!
        showEditor(url: url)
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            return self.leadingSwipeActionConfiguration(for: item)
        }
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            return self.trailingSwipeActionConfigurations(for: item)
        }
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DriveScript> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.name
            cell.contentConfiguration = content
        }
        dataSource = UICollectionViewDiffableDataSource<Section, DriveScript>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DriveScript>()
        snapshot.appendSections([.main])
        
        let resources = ["alist"]
        var items = [DriveScript]()
        for resource in resources {
            let url = Bundle.main.url(forResource: resource, withExtension: "js")!
            items.append(DriveScript(url: url))
        }
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let script = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        run(script)
    }
}

extension HomeViewController {
    
    private func leadingSwipeActionConfiguration(for script: DriveScript) -> UISwipeActionsConfiguration? {
        let runAction = UIContextualAction(style: .destructive, title: nil) { [unowned self] action, view, completion in
            run(script)
            completion(true)
        }
        runAction.image = UIImage(systemName: "play.rectangle")
        return UISwipeActionsConfiguration(actions: [runAction])
    }
    
    private func trailingSwipeActionConfigurations(for script: DriveScript) -> UISwipeActionsConfiguration? {
        
        let removeAction = UIContextualAction(style: .destructive, title: nil) { (action, view, completion) in
            completion(true)
        }
        removeAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal, title: nil) { [unowned self] (action, view, completion) in
            edit(script)
            completion(true)
        }
        editAction.image = UIImage(systemName: "pencil.and.ellipsis.rectangle")
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [removeAction, editAction])
    }
}

extension HomeViewController {
    
    private func run(_ script: DriveScript) {
        Task {
            do {
                let engine = DriveEngine(script: try! String(contentsOf: script.url))
                let directory = try await engine.login()
                let vc = BrowserViewController(engine: engine, directory: directory)
                navigationController?.pushViewController(vc, animated: true)
            } catch {
                print(error)
            }
        }
    }
    
    private func edit(_ script: DriveScript) {
        showEditor(url: script.url)
    }
    
    private func showEditor(url: URL) {
        let vc = EditorViewController(scriptURL: url)
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationController.navigationBar.compactAppearance = navigationBarAppearance
        navigationController.navigationBar.compactAppearance = navigationBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        present(navigationController, animated: true)
    }
}
