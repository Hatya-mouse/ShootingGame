//
//  HomeViewController.swift
//  TyumaOShootinG
//
//  Created by Shuntaro Kasatani on 2021/02/20.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var highScoreLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kousin()
    }
    
    func kousin() {
        let highScore = UserDefaults.standard.integer(forKey: "bestScore")
        let highScoreString = highScore.withComma
        highScoreLabel.text = "ハイスコア：" + highScoreString
        if let color = UserDefaults.standard.color(forKey: "color") {
            view.backgroundColor = color
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier=", segue.identifier ?? "nil")
        if segue.identifier == "showTokuten" {
            // Get the new view controller using segue.destination.
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ScoreTableViewController
            // Pass the selected object to the new view controller.
            controller.preVC = self
        } else if segue.identifier == "game" {
            // Get the new view controller using segue.destination.
            let controller = segue.destination as! GameViewController
            // Pass the selected object to the new view controller.
            controller.preVC = self
        } else if segue.identifier == "present" {
            // Get the new view controller using segue.destination.
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! PresentViewController
            // Pass the selected object to the new view controller.
            controller.preVC = self
        }
    }

}

private let formatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.groupingSeparator = ","
    f.groupingSize = 3
    return f
}()

extension Int {
    var withComma: String {
        return formatter.string(from: NSNumber(integerLiteral: self)) ?? "\(self)"
    }
}

