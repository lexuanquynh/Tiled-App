//
//  SettingViewController.swift
//  DemoLoadTiled
//
//  Created by Prank on 5/1/25.
//

import UIKit

protocol SettingViewControllerDelegate: AnyObject {
    func settingViewController(_ settingViewController: SettingViewController, didApplySetting setting: Setting)
}

class SettingViewController: UIViewController {
    @IBOutlet weak var widthTextField: UITextField!

    @IBOutlet weak var heightTextField: UITextField!

    @IBOutlet weak var maxLevelTextField: UITextField!

    @IBOutlet weak var urlTextField: UITextField!

    // delegate
    weak var delegate: SettingViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // fill data from setting
        let setting = SettingHelper.shared.getSetting()
        widthTextField.text = "\(setting.width)"
        heightTextField.text = "\(setting.height)"
        maxLevelTextField.text = "\(setting.maxLevel)"
        urlTextField.text = setting.url
    }


    @IBAction func onApplyTouched(_ sender: UIButton) {
        guard let width = Int(widthTextField.text ?? ""),
              let height = Int(heightTextField.text ?? ""),
              let maxLevel = Int(maxLevelTextField.text ?? ""),
              let url = urlTextField.text else {
            return
        }

        let setting = Setting(width: width, height: height, maxLevel: maxLevel, url: url, showGrid: true)
        // save setting
        SettingHelper.shared.saveSetting(setting)
        delegate?.settingViewController(self, didApplySetting: setting)
        self.dismiss(animated: true)
    }

}

// setting
struct Setting {
    var width: Int
    var height: Int
    var maxLevel: Int
    var url: String
    var showGrid: Bool
}


// Setting helper for saving setting to user default
class SettingHelper {
    static let shared = SettingHelper()

    private let widthKey = "width"
    private let heightKey = "height"
    private let maxLevelKey = "maxLevel"
    private let urlKey = "url"
    private let showGridKey = "showGrid"

    // save setting
    func saveSetting(_ setting: Setting) {
        UserDefaults.standard.set(setting.width, forKey: widthKey)
        UserDefaults.standard.set(setting.height, forKey: heightKey)
        UserDefaults.standard.set(setting.maxLevel, forKey: maxLevelKey)
        UserDefaults.standard.set(setting.url, forKey: urlKey)
        UserDefaults.standard.set(setting.showGrid, forKey: showGridKey)
    }

    // get setting
    func getSetting() -> Setting {
        var width = UserDefaults.standard.integer(forKey: widthKey)
        var height = UserDefaults.standard.integer(forKey: heightKey)
        var maxLevel = UserDefaults.standard.integer(forKey: maxLevelKey)
        let showGrid = UserDefaults.standard.bool(forKey: showGridKey)
        let url = UserDefaults.standard.string(forKey: urlKey) ?? "https://raw.githubusercontent.com/p-lr/MapView/master/demo/src/main/assets/tiles/esp"

        if width == 0 {
            width = 1024
        }
        if height == 0 {
            height = 1024
        }

        if maxLevel == 0 {
            maxLevel = 5
        }

        return Setting(width: width, height: height, maxLevel: maxLevel, url: url, showGrid: showGrid)
    }

}

