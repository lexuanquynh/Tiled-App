//
//  TinledViewController.swift
//  DemoLoadTiled
//
//  Created by Prank on 5/1/25.
//

import UIKit
import LDOTiledView
import SDWebImage

class TinledViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var tiledView: LDOTiledView!

    @IBOutlet weak var showGridSwitch: UISwitch!
    private var imageName: String = ""
    private var imageSize: CGSize = CGSize(width: 1000, height: 1000)
    private var maximumZoomLevel: Int = 5
    private var fileExtension = "jpg"
    private var tileCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // load data from setting
        let setting = SettingHelper.shared.getSetting()
        imageSize = CGSize(width: setting.width, height: setting.height)
        maximumZoomLevel = setting.maxLevel
        imageName = setting.url
        // show grid
        showGridSwitch.isOn = tiledView.debugAnnotateTiles


        tiledView.imageSize = imageSize
        tiledView.maximumZoomLevel = maximumZoomLevel
        scrollView.maximumZoomScale = tiledView.maximumZoomScale
        scrollView.minimumZoomScale = 0.5
        scrollView.delegate = self
        tiledView.dataSource = self
    }

    @IBAction func onShowTilesTouched(_ sender: UISwitch) {
        tiledView.debugAnnotateTiles = sender.isOn
    }

    @IBAction func onSettingTouched(_ sender: UIButton) {
        let settingViewController = SettingViewController()
        settingViewController.delegate = self
        let naviVC = UINavigationController(rootViewController: settingViewController)
        present(naviVC, animated: true)
    }

}


extension TinledViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return tiledView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        updateUI()
    }
}


extension TinledViewController: LDOTiledViewDataSource {
    func tiledView(_ tiledView: LDOTiledView, tileForRow row: Int, column: Int, zoomLevel: Int) -> UIImage? {
        let cacheKey = "\(zoomLevel)_\(row)_\(column)" as NSString
        debugPrint("cacheKey \(cacheKey)")
        // Kiểm tra xem tile có sẵn trong cache chưa
        if let cachedImage = tileCache.object(forKey: cacheKey) {
            return cachedImage
        }

        let urlString = imageName + "/\(zoomLevel)/\(row)/\(column).\(fileExtension)"

        guard let url = URL(string: urlString) else { return nil }

        var image: UIImage?

        let semaphore = DispatchSemaphore(value: 0)

        SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { (fetchedImage, _, _, _, _, _) in
            if let fetchedImage = fetchedImage {
                image = fetchedImage
                SDImageCache.shared.store(fetchedImage, forKey: cacheKey as String)
            }
            semaphore.signal()
        }

        semaphore.wait()

        return image
    }
}

// SettingViewControllerDelegate
extension TinledViewController: SettingViewControllerDelegate {
    func settingViewController(_ settingViewController: SettingViewController, didApplySetting setting: Setting) {
        imageSize = CGSize(width: setting.width, height: setting.height)
        maximumZoomLevel = setting.maxLevel
        imageName = setting.url

        tiledView.imageSize = imageSize
        tiledView.maximumZoomLevel = maximumZoomLevel
        scrollView.maximumZoomScale = tiledView.maximumZoomScale
        scrollView.minimumZoomScale = 0.5

        // set for show grid
        showGridSwitch.isOn = setting.showGrid
        tiledView.debugAnnotateTiles = setting.showGrid
    }
}
