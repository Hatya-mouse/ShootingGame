//
//  GameViewController.swift
//  ShootingGame
//
//  Created by Shuntaro Kasatani on 2021/02/20.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var top: NSLayoutConstraint!
    
    var scene: SKScene?
    
    var preVC: HomeViewController? = nil
    
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                (scene as! GameScene).gameVC = self
                //(scene as! GameScene).score = 95
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        preVC?.kousin()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func showNotifcation(_ gift: Gift) {
        print("show notification")
        let imageView = notificationView.viewWithTag(1) as! UIImageView
        let titleLabel = notificationView.viewWithTag(2) as! UILabel
        let messageLabel = notificationView.viewWithTag(3) as! UILabel
        imageView.image = gift.image
        titleLabel.text = """
            "\(gift.name)"をアンロック!
            """
        messageLabel.text = "\(gift.point)のハイスコアを獲得"
        notificationView.backgroundColor = .systemBackground
        notificationView.layer.cornerRadius = 7.5
        // 影の方向（width=右方向、height=下方向、CGSize.zero=方向指定なし）
        notificationView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        notificationView.layer.shadowColor = UIColor.black.cgColor
        notificationView.layer.shadowOpacity = 0.6
        notificationView.layer.shadowRadius = 4
        notificationView.isHidden = false
        self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
            self.notificationView.isHidden = true
            timer.invalidate()
        }
        /*top.constant = -100
        notificationView.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.top.constant = 20
        } completion: { _ in
            self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
                self.top.constant = 20
                UIView.animate(withDuration: 1.0) {
                    self.top.constant = -100
                    self.notificationView.isHidden = true
                } completion: { _ in
                    timer.invalidate()
                }
            }
        }*/
    }
}
