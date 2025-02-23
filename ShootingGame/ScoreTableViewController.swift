//
//  ScoreTableViewController.swift
//  TyumaOShootinG
//
//  Created by Shuntaro Kasatani on 2021/02/21.
//

import UIKit

class ScoreTableViewController: UITableViewController {
    
    var dates: [String] = []
    var points: [String] = []
    var isHighScore: [Bool] = []
    
    var preVC: HomeViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.rowHeight = 30
        tableView.allowsSelection = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        dates = UserDefaults.standard.stringArray(forKey: "dates") ?? []
        points = UserDefaults.standard.stringArray(forKey: "scores") ?? []
        isHighScore = (UserDefaults.standard.array(forKey: "isHighScore") as? [Bool]) ?? []
        preVC?.kousin()
        return dates.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath)

        // Configure the cell...
        let dateLabel = cell.viewWithTag(1) as! UILabel
        let pointLabel = cell.viewWithTag(2) as! UILabel
        let highScore = cell.viewWithTag(3) as! UILabel
        dateLabel.text = dates[indexPath.row]
        pointLabel.text = points[indexPath.row]
        if isHighScore[indexPath.row] {
            highScore.text = "ハイスコア更新!"
            highScore.isHidden = false
        } else {
            highScore.text = ""
            highScore.isHidden = true
        }

        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ScoreTableViewController {
    @IBAction func reset(_ sender: Any) {
        let alert = UIAlertController (
            title: "ハイスコアをリセット",
            message: "ハイスコアをリセットしてもよろしいですか? スコアの履歴、獲得した特典もリセットされます。",
            preferredStyle: .alert
        )
        alert.addAction (
            UIAlertAction (
                title: "リセット",
                style: .destructive,
                handler: { _ in
                    let ud = UserDefaults.standard
                    ud.removeObject(forKey: "dates")
                    ud.removeObject(forKey: "scores")
                    ud.removeObject(forKey: "isHighScore")
                    ud.removeObject(forKey: "bestScore")
                    let color: UIColor = .systemTeal
                    ud.setValue(color, forKey: "color")
                    self.preVC?.kousin()
                    self.dismiss(animated: true)
                }
            )
        )
        alert.addAction (
            UIAlertAction (
                title: "キャンセル",
                style: .cancel,
                handler: nil
            )
        )
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissTrue(_ sender: Any) {
        dismiss(animated: true)
    }
}
