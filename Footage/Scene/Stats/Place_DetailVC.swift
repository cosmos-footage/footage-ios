//
//  Place_DetailVC.swift
//  footage
//
//  Created by 녘 on 2020/10/03.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit

class Place_DetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var ranking: Array<(key: String, value: Double)> = []
    let cellIdentifier = "placeDetailCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
}


extension Place_DetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ranking.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let place = ranking[indexPath.row].key
        let distance = DistanceTextPresentation(
            meters: ranking[indexPath.row].value,
            style: .decimal2WithKm
        ).text
        cell.textLabel?.text = "\(indexPath.row+1)위.  \(place) - \(distance)"
        cell.textLabel?.font = UIFont(name: "NanumBarunpen", size: 18)
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = false
        return cell
    }
    //
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        tableView.deselectRow(at: indexPath, animated: true)
    //    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
