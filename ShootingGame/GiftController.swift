//
//  GiftController.swift
//  TyumaOShootinG
//
//  Created by Shuntaro Kasatani on 2021/02/21.
//

import UIKit

class GiftController: UIViewController, UIColorPickerViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var locked: UILabel!
    @IBOutlet weak var settingLabel: UIButton!
    
    var image: UIImage?
    var titleString: String?
    var highScore: Int?
    var lock: Bool?
    var settingType: SettingType = .none
    
    var preVC: HomeViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = image
        titleLabel.text = titleString
        if let highScore = highScore {
            highScoreLabel.text = String(highScore) + "のハイスコアが必要です"
            if lock ?? true { locked.text = "ロックされています" }
            else { locked.text = "アンロックされています" }
            switch titleString {
                case "カスタム背景色":
                    settingLabel.setTitle("背景色を選択...", for: .normal)
                    settingType = .customColor
                    if highScore < 50000000 {
                        settingLabel.isEnabled = false
                    }
                case .none:
                    settingLabel.setTitle("設定...", for: .normal)
                    settingLabel.isEnabled = false
                    settingType = .none
                case .some(_):
                    settingLabel.setTitle("設定...", for: .normal)
                    settingLabel.isEnabled = false
                    settingType = .none
            }
        }
    }
    
    enum SettingType {
        case customColor
        case none
    }
    
    @IBAction func settingButton(_ sender: Any) {
        switch settingType {
            case .customColor:
                if #available(iOS 14.0, *) {
                    let colorPicker = UIColorPickerViewController()
                    colorPicker.selectedColor = UserDefaults.standard.color(forKey: "color") ?? .systemTeal
                    colorPicker.delegate = self
                    present(colorPicker, animated: true)
                } else {
                    // Fallback on earlier versions
                    let alert = UIAlertController(title: "この機能はiOS14から使用できます。", message: "お使いのデバイスをiOS14にアップデートしてください。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true)
                }
                break
            default:
                return
        }
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        UserDefaults.standard.setValue(color, forKey: "color")
        preVC?.kousin()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UserDefaults {
    func setValue(_ value: UIColor, forKey key: String) {
        let hex = value.hex()
        UserDefaults.standard.setValue(hex, forKey: key)
    }
    func color(forKey key: String) -> UIColor? {
        if let hex = UserDefaults.standard.string(forKey: key) {
            let color = UIColor(hex: hex)
            return color
        } else {
            return nil
        }
    }
}

extension UIColor {
    public func hex(withHash hash: Bool = false, uppercase up: Bool = false) -> String {
        if let components = self.cgColor.components {
            let r = ("0" + String(Int(components[0] * 255.0), radix: 16, uppercase: up)).suffix(2)
            let g = ("0" + String(Int(components[1] * 255.0), radix: 16, uppercase: up)).suffix(2)
            let b = ("0" + String(Int(components[2] * 255.0), radix: 16, uppercase: up)).suffix(2)
            return (hash ? "#" : "") + String(r + g + b)
        }
        return "000000"
    }

    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
}
