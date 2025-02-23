//
//  PresentViewController.swift
//  TyumaOShootinG
//
//  Created by Shuntaro Kasatani on 2021/02/21.
//

import UIKit

private let reuseIdentifier = "Cel"

protocol GiftDelegate {
    func didChangeScore(_ gift: Gift, point score: Int, isLocked flag: Bool)
}

extension GiftDelegate {
    func didChangeScore(_ gift: Gift, point score: Int, isLocked flag: Bool) {}
}

public struct Gift {
    let name: String
    let image: UIImage?
    let lockImage: UIImage
    let point: Int
    var isLocked: Bool
    init(
        _ name: String,
        image: UIImage?,
        lockImage: UIImage = UIImage(named: "lock")!,
        score point: Int,
        isLocked: Bool
    ) {
        self.name = name
        self.image = image
        self.point = point
        self.lockImage = lockImage
        self.isLocked = isLocked
    }
    init(
        _ name: String,
        image: UIImage?,
        lockImage: UIImage = UIImage(named: "lock")!,
        score point: Int,
        currentScore currentPoint: Int
    ) {
        self.name = name
        self.image = image
        self.point = point
        self.lockImage = lockImage
        if point <= currentPoint {
            isLocked = false
        } else {
            isLocked = true
        }
    }
    mutating func changeCurrent(scoreTo score: Int) {
        if point <= score {
            isLocked = false
        } else {
            isLocked = true
        }
    }
}

var highScore: Int {
    return UserDefaults.standard.integer(forKey: "bestScore")
}

public let presents: [Gift] = [
    Gift("ようこそ", image: UIImage(systemName: "smiley"), score: 0, currentScore: highScore),
    Gift("初めての一発", image: UIImage(named: "smile"), score: 5, currentScore: highScore),
    Gift("50発までの連射", image: UIImage(named: "ミサイル"), score: 5000, currentScore: highScore),
    Gift("カスタム背景色", image: UIImage(named: "brush"), score: 10000, currentScore: highScore),
    Gift("ピーちゃん?", image: UIImage(named: "P"), score: 50000, currentScore: highScore),
    Gift("制限なしの連射", image: UIImage(named: "ミサイル"), score: 1000000000, currentScore: highScore),
    Gift("スナイパーライフル", image: UIImage(named: "スナイパー"), score: 120000000000, currentScore: highScore),
    Gift("しろねず", image: UIImage(named: "しろねず"), score: 250000000000000, currentScore: highScore),
    Gift("ブラックホール", image: UIImage(named: "blackhole"), score: 800000000000000, currentScore: highScore)
]

public func unlockedGift(_ gift: Gift, score: Int) -> Bool {
    return gift.point <= score
}

class PresentViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var allGifts: [Gift] = []
    var locked: [Gift] = []
    var notLocked: [Gift] = []
    var gifts: [[Gift]] = []
    
    var preVC: HomeViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Section")

        // Do any additional setup after loading the view.
        allGifts = presents
        locked = allGifts.filter { gift in
            return gift.isLocked
        }
        notLocked = allGifts.filter { gift in
            return !gift.isLocked
        }
        gifts.append(notLocked)
        gifts.append(locked)
        collectionView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        let controller = segue.destination as! GiftController
        // Pass the selected gift to the new view controller.
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            let gift = gifts[indexPath.section][indexPath.row]
            controller.image = gift.image
            controller.titleString = gift.name
            controller.highScore = gift.point
            controller.lock = gift.isLocked
            controller.preVC = preVC
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return gifts.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return gifts[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let gift = gifts[indexPath.section][indexPath.row]
    
        // Configure the cell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = gift.name
        }
        if let imageView = cell.viewWithTag(2) as? UIImageView {
            imageView.tintColor = .label
            if gift.isLocked {
                imageView.image = gift.lockImage
            } else {
                imageView.image = gift.image
            }
        }
        if let highScoreLabel = cell.viewWithTag(3) as? UILabel {
            highScoreLabel.text = "\(gift.point)のハイスコアが必要"
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Section", for: indexPath)
        if let label = header.viewWithTag(1) {
            label.removeFromSuperview()
        }
        header.backgroundColor = .systemGray
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(label)
        
        // レイアウト設定
        let leading = NSLayoutConstraint(item: header, attribute: .leading, relatedBy: .equal, toItem: label, attribute: .leading, multiplier: 1, constant: -10)
        let center = NSLayoutConstraint(item: header, attribute: .centerY, relatedBy: .equal, toItem: label, attribute: .centerY, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: header, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: label, attribute: .trailing, multiplier: 1, constant: 10)
        header.addConstraints([leading, center, trailing])
        
        if indexPath.section == 0 {
            label.text = "アンロックした特典"
        } else if indexPath.section == 1 {
            label.text = "ロックされている特典"
        }
        label.tag = 1

        return header
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("set Cell Size")
        return CGSize(width: (view.frame.width - 45) / 2, height: (view.frame.width - 45) / 2 * 0.7)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        print("set Edge Insets")
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        print("set Header Size")
        return CGSize(width: 100.0, height: 50.0)
    }

    @IBAction func dismissTrue(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
