import Foundation
import UIKit
import AVKit
import AVFoundation

class BrowserViewController: UIViewController {
    
    enum Section { case main }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, DriveItem>!
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    let engine: DriveEngine
    let directory: DriveItem
    
    init(engine: DriveEngine, directory: DriveItem) {
        self.engine = engine
        self.directory = directory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = directory.name
        setupCollectionView()
        setupLoadingIndicator()
        setupDataSource()
        applySnapshot()
        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DriveItem> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.image = item.icon
            content.text = item.name
            if let size = item.size, size > 0 {
                content.secondaryText = ByteCountFormatter().string(fromByteCount: Int64(size))
            }
            content.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = content
        }
        dataSource = UICollectionViewDiffableDataSource<Section, DriveItem>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
}

extension BrowserViewController {
    
    func applySnapshot() {
        
        Task { @MainActor in
            loadingIndicator.startAnimating()
            let files = try await engine.listFolder(at: directory)
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, DriveItem>()
            snapshot.appendSections([.main])
            snapshot.appendItems(Array(files.uniqued()), toSection: .main)
            await dataSource.apply(snapshot, animatingDifferences: false)
            loadingIndicator.stopAnimating()
        }
    }
    
}

extension BrowserViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        if item.isDirectory {
            let vc = BrowserViewController(engine: engine, directory: item)
            navigationController?.pushViewController(vc, animated: true)
        } else if item.isVideo {
            startPlayback(item)
        }
    }
}

extension BrowserViewController {
    
    func startPlayback(_ video: DriveItem) {
        Task { @MainActor in
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                let info = try await engine.getPlaybackInfo(of: video)
                let options = info.allHTTPHeaderFields ?? [:]
                let asset = AVURLAsset(url: info.url!, options: [
                    "AVURLAssetHTTPHeaderFieldsKey": options,
                    "AVURLAssetOutOfBandMIMETypeKey": "video/mp4"
                ])
                let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["playable"])
                let player = AVPlayer(playerItem: playerItem)

                let controller = AVPlayerViewController()
                controller.showsPlaybackControls = true
                controller.allowsPictureInPicturePlayback = true
                controller.updatesNowPlayingInfoCenter = false
                controller.player = player
                player.play()
                present(controller, animated: true)
            } catch {
                print(error)
            }
        }
    }
}
