//
//  HeroesTableViewController.swift
//  avengers_app
//
//  Created by Mospeng Research Lab Philippines on 8/12/20.
//  Copyright © 2020 Mospeng Research Lab Philippines. All rights reserved.
//

import UIKit
import SVProgressHUD

class HeroesTableViewController: UITableViewController {
    
    var heroes = [Hero]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.init(red: 0, green: 0, blue: 50.2, alpha: 1)]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Fetching...")
        fetchHeroes()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = heroes.count
        navigationItem.title = count == 1 ? "\(heroes.count) Avenger" : "\(heroes.count) Avengers"
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HeroTableViewCell
        let hero = heroes[indexPath.row]
        cell.heroNameLabel.text = hero.name
        cell.heroSpecialSkillLabel.text = hero.special_skill
        
        APIService.shared.downloadImage(using: hero.image) { image in
            if let heroImage = image  {
                cell.heroImageView.image =  heroImage
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Delete post")
            let hero = self.heroes[indexPath.row]
            APIService.shared.deletePost(id: hero.id) { (err) in
                if let err = err {
                    print("Failed to delete hero: ", err)
                    return
                }
                print("Successfully deleted hero from server")
//                self.fetchHeroes() // OR you can use:
                self.heroes.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    fileprivate func fetchHeroes() {
        APIService.shared.fetchHeroes { (res) in
            switch res {
            case .failure(let err):
                print("Failed to fetch heroes: ", err)
                SVProgressHUD.dismiss()
            case .success(let heroes):
                print(heroes)
                
                self.heroes = heroes
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }

}

