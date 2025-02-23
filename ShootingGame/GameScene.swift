//
//  HomeViewController.swift
//  TyumaOShootinG
//
//  Created by Shuntaro Kasatani on 2021/02/20.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation
import UserNotifications

class GameScene: SKScene, SKPhysicsContactDelegate, UNUserNotificationCenterDelegate {

    var gameVC: GameViewController!

    let motionManager = CMMotionManager()
    var accelaration: CGFloat = 0.0
    
    var audioPlayer: AVAudioPlayer!

    var timer: Timer?
    var timerForAsteroud: Timer?
    var asteroudDuration: TimeInterval = 6.0 {
        didSet {
            if asteroudDuration < 2.0 {
                timerForAsteroud?.invalidate()
            }
        }
    }
    var score: Int = 0 {
        didSet {
            print("change Score")
            if let scoreLabel = self.scoreLabel {
                scoreLabel.text = "Score: \(score)"
            }
            for var gift in presents {
                gift.changeCurrent(scoreTo: highScore)
                if gift.isLocked {
                    print("locked gift: \(gift.name)")
                    if gift.point <= score {
                        print("unlock \(gift.name)")
                        gameVC.showNotifcation(gift)
                    }
                }
            }
        }
    }

    let spaceshipCategory: UInt32 = 0b0001
    let missileCategory: UInt32 = 0b0010
    let asteroidCategory: UInt32 = 0b0100
    let earthCategory: UInt32 = 0b1000
    let heartCategory: UInt32 = 0b1010
    
    var point100: Bool = false

    var missileButton: SKSpriteNode!
    var earth: SKSpriteNode!
    var spaceship: SKSpriteNode!
    var hearts: [SKSpriteNode] = []
    var scoreLabel: SKLabelNode!
    var bestScoreLabel: SKLabelNode!
    var bestScore = 0
    var current: UInt32 = 0b0000
    
    var label: SKLabelNode?
    
    var timer2 = Timer()
    
    var moveCount = 0
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {}

    override func didMove(to view: SKView) {
        
        label = childNode(withName: "gameOver") as? SKLabelNode
        label?.isHidden = true
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        //size = gameVC.view.bounds.size
        scaleMode = .aspectFit
        xScale = 1
        yScale = 1

        self.earth = SKSpriteNode()
        self.earth.xScale = 1.5
        self.earth.yScale = 0.3
        self.earth.position = CGPoint(x: 0, y: -frame.height / 2)
        self.earth.zPosition = -1.0
        self.earth.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 100))
        self.earth.physicsBody?.categoryBitMask = earthCategory
        self.earth.physicsBody?.contactTestBitMask = asteroidCategory
        self.earth.physicsBody?.collisionBitMask = 0
        addChild(self.earth)

        if highScore < 2500 {
            self.spaceship = SKSpriteNode(imageNamed: "ハシ")
        } else if highScore < 4999999999 {
            self.spaceship = SKSpriteNode(imageNamed: "ハシ")
        } else if highScore >= 5000000000 {
            self.spaceship = SKSpriteNode(imageNamed: "しろねず")
        } else if highScore >= 25000000000000000 {
            self.spaceship = SKSpriteNode(imageNamed: "しろねず")
        }
        self.spaceship.scale(to: CGSize(width: frame.width / 5, height: frame.width / 5))
        self.spaceship.position = CGPoint(x: 0, y: self.earth.frame.maxY + 50)
        self.spaceship.physicsBody = SKPhysicsBody(circleOfRadius: self.spaceship.frame.width * 0.1)
        self.spaceship.physicsBody?.categoryBitMask = spaceshipCategory
        self.spaceship.physicsBody?.contactTestBitMask = asteroidCategory
        self.spaceship.physicsBody?.collisionBitMask = 0
        addChild(self.spaceship)

        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, _) in
            guard let data = data else { return }
            let a = data.acceleration
            self.accelaration = CGFloat(a.x) * 0.75 + self.accelaration * 0.25
        }

        if score < 100 {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
                self.addAsteroid()
            })
        }

        for i in 1...5 {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.position = CGPoint(x: -frame.width / 2 + heart.frame.height * CGFloat(i), y: frame.height / 2 - heart.frame.height)
            addChild(heart)
            hearts.append(heart)
        }
        
        

        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Helvetica Neue UltraLight"
        scoreLabel.fontSize = 50
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: -frame.width / 2 + scoreLabel.frame.width / 2 - 50, y: frame.height / 2 - scoreLabel.frame.height * 5)
        addChild(scoreLabel)

        bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        bestScoreLabel = SKLabelNode(text: "High Score: \(bestScore)")
        bestScoreLabel.fontName = "Helvetica Neue Thin"
        bestScoreLabel.fontSize = 30
        bestScoreLabel.horizontalAlignmentMode = .left
        bestScoreLabel.position = scoreLabel.position.applying(CGAffineTransform(translationX: 0, y: -bestScoreLabel.frame.height * 1.5))
        addChild(bestScoreLabel)

        timerForAsteroud = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { _ in
            self.asteroudDuration -= 0.5
        })
    }

    override func didSimulatePhysics() {
        let nextPosition = self.spaceship.position.x + self.accelaration * 50
        if nextPosition > frame.width / 2 - 30 { return }
        if nextPosition < -frame.width / 2 + 30 { return }
        self.spaceship.position.x = nextPosition
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveCount = 0
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPaused { return }
        var missile = SKSpriteNode(imageNamed: "ミサイル")
        if highScore > 25000 {
            missile = SKSpriteNode(imageNamed: "スナイパー")
        }
        missile.position = CGPoint(x: self.spaceship.position.x, y: self.spaceship.position.y + 50)
        missile.size = CGSize(width: 50, height: 256)
        missile.physicsBody = SKPhysicsBody(circleOfRadius: missile.frame.height / 2)
        missile.physicsBody?.categoryBitMask = missileCategory
        missile.physicsBody?.contactTestBitMask = asteroidCategory
        missile.physicsBody?.collisionBitMask = 0
        addChild(missile)

        let moveToTop = SKAction.moveTo(y: frame.height + 10, duration: 0.3)
        let remove = SKAction.removeFromParent()
        missile.run(SKAction.sequence([moveToTop, remove]))
        playSound(name: "拳銃を撃つ")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPaused { return }
        if bestScore > 5000 && moveCount < 50 {
            var missile = SKSpriteNode(imageNamed: "ミサイル")
            if highScore > 25000 {
                missile = SKSpriteNode(imageNamed: "スナイパー")
            }
            missile.position = CGPoint(x: self.spaceship.position.x, y: self.spaceship.position.y + 50)
            missile.size = CGSize(width: 50, height: 256)
            missile.physicsBody = SKPhysicsBody(circleOfRadius: missile.frame.height / 2)
            missile.physicsBody?.categoryBitMask = missileCategory
            missile.physicsBody?.contactTestBitMask = asteroidCategory
            missile.physicsBody?.collisionBitMask = 0
            addChild(missile)

            let moveToTop = SKAction.moveTo(y: frame.height + 10, duration: 0.3)
            let remove = SKAction.removeFromParent()
            missile.run(SKAction.sequence([moveToTop, remove]))
            moveCount += 1
        } else if bestScore > 1000000000 {
            var missile = SKSpriteNode(imageNamed: "スナイパー")
            missile.position = CGPoint(x: self.spaceship.position.x, y: self.spaceship.position.y + 50)
            missile.size = CGSize(width: 50, height: 256)
            missile.physicsBody = SKPhysicsBody(circleOfRadius: missile.frame.height / 2)
            missile.physicsBody?.categoryBitMask = missileCategory
            missile.physicsBody?.contactTestBitMask = asteroidCategory
            missile.physicsBody?.collisionBitMask = 0
            addChild(missile)

            let moveToTop = SKAction.moveTo(y: frame.height + 10, duration: 0.3)
            let remove = SKAction.removeFromParent()
            missile.run(SKAction.sequence([moveToTop, remove]))
            moveCount += 1
        }
    }
    
    func addAsteroid() {
        let asteroid = SKSpriteNode(imageNamed: "ちゃいねず")
        let random = CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX)
        let positionX = frame.width * (random - 0.5)
        asteroid.position = CGPoint(x: positionX, y: frame.height / 2 + asteroid.frame.height)
        asteroid.scale(to: CGSize(width: 130, height: 130))
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.frame.width)
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = missileCategory + spaceshipCategory + earthCategory
        asteroid.physicsBody?.collisionBitMask = 0
        addChild(asteroid)

        let move = SKAction.moveTo(y: -frame.height / 2 - asteroid.frame.height, duration: asteroudDuration)
        let remove = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([move, remove]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var asteroid: SKPhysicsBody
        var target: SKPhysicsBody

        if contact.bodyA.categoryBitMask == asteroidCategory {
            asteroid = contact.bodyA
            target = contact.bodyB
        } else {
            asteroid = contact.bodyB
            target = contact.bodyA
        }

        guard let asteroidNode = asteroid.node else { return }
        guard let targetNode = target.node else { return }
        var explosion: SKEmitterNode?

        let oldScore = score
        
        asteroidNode.removeFromParent()
        if target.categoryBitMask == missileCategory {
            targetNode.removeFromParent()
            explosion = SKEmitterNode(fileNamed: "Explosion")
            if highScore > 250000 {
                if score > 1000 {
                    score += score / 100
                    if !point100 {
                        timer?.invalidate()
                        timer = Timer.scheduledTimer(withTimeInterval: 1.0 - (Double(score) / 10000.0), repeats: true, block: { _ in
                            self.addAsteroid()
                        })
                        point100 = true
                    }
                } else {
                    score += 10
                }
            } else {
                if score > 500 {
                    score += score / 100
                    if !point100 {
                        timer?.invalidate()
                        timer = Timer.scheduledTimer(withTimeInterval: 1.0 - (Double(score) / 10000.0), repeats: true, block: { _ in
                            self.addAsteroid()
                        })
                        point100 = true
                    }
                } else {
                    score += 10
                }
            }
            
            playSound(name: "爆発")
            
            let upScore = score - oldScore
            var labelNode: SKLabelNode!
            if upScore + upScore > 0 {
                labelNode = SKLabelNode(text: "+\(upScore)")
            } else {
                labelNode = SKLabelNode(text: "\(upScore)")
            }
            let position = asteroidNode.position
            labelNode.fontName = "Helvetica Neue Bold"
            labelNode.fontSize = 45
            labelNode.fontColor = .white
            labelNode.position = position
            addChild(labelNode)
            labelNode.run(SKAction.moveTo(y: 20, duration: 1))
            labelNode.run(SKAction.fadeAlpha(to: 0, duration: 1))
        }

        if target.categoryBitMask == spaceshipCategory || target.categoryBitMask == earthCategory {
            guard let heart = hearts.last else { return }
            explosion = SKEmitterNode(fileNamed: "Explosion2")
            heart.removeFromParent()
            score -= 10
            hearts.removeLast()
            if hearts.isEmpty {
                gameOver()
            }
            playSound(name: "爆発")
            
            let upScore = score - oldScore
            var labelNode: SKLabelNode!
            if upScore + upScore > 0 {
                labelNode = SKLabelNode(text: "+\(upScore)")
            } else {
                labelNode = SKLabelNode(text: "\(upScore)")
            }
            let position = asteroidNode.position
            labelNode.fontName = "Helvetica Neue Bold"
            labelNode.fontSize = 45
            labelNode.fontColor = .white
            labelNode.position = position
            addChild(labelNode)
            labelNode.run(SKAction.moveTo(y: 20, duration: 1))
            labelNode.run(SKAction.fadeAlpha(to: 0, duration: 1))
        }
        
        if let explosion = explosion {
            explosion.position = asteroidNode.position
            addChild(explosion)
            self.run(SKAction.wait(forDuration: 1.0)) {
                explosion.run(SKAction.fadeAlpha(to: 0, duration: 0.2)) {
                    explosion.removeFromParent()
                }
            }
        }
    
        if score > bestScore {
            bestScore = score
            bestScoreLabel.text = "High Score: " + String(bestScore)
            let duration: TimeInterval = 0.1
            let scaleAction = SKAction.scale(to: 1.3, duration: duration)
            let scaleAction2 = SKAction.scale(to: 1, duration: duration)
            bestScoreLabel.run(scaleAction) {
                self.bestScoreLabel.run(scaleAction2)
            }
        }
        UserDefaults.standard.setValue(bestScore, forKey: "bestScore")
    }

    func gameOver() {
        isPaused = true
        timer?.invalidate()
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        label?.isHidden = false
        
        let userd = UserDefaults.standard
        var dates = userd.stringArray(forKey: "dates") ?? []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        let dateString = formatter.string(from: Date())
        dates.insert(dateString, at: 0)
        userd.setValue(dates, forKey: "dates")
        
        var scores = userd.stringArray(forKey: "scores") ?? []
        scores.insert(String(score) + "Point", at: 0)
        userd.setValue(scores, forKey: "scores")
        
        var highScores = (userd.array(forKey: "isHighScore") as? [Bool]) ?? []
        
        if score > bestScore {
            userd.set(score, forKey: "bestScore")
            highScores.insert(true, at: 0)
        } else {
            highScores.insert(false, at: 0)
        }
        userd.setValue(highScores, forKey: "isHighScore")
        
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.gameVC.dismiss(animated: true, completion: nil)
        }
    }

}

extension GameScene: AVAudioPlayerDelegate {
    func playSound(name: String) {
        DispatchQueue.global().async {
            guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
                print("音源ファイルが見つかりません")
                return
            }

            do {
                // AVAudioPlayerのインスタンス化
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))

                // AVAudioPlayerのデリゲートをセット
                self.audioPlayer.delegate = self
                
                DispatchQueue.main.async {
                    // 音声の再生
                    self.audioPlayer.play()
                }
            } catch {
                print("error: \(error)")
            }
        }
    }
}

