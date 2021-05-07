//
//  HeroTableViewCell.swift
//  avengers_app
//
//  Created by Mospeng Research Lab Philippines on 8/12/20.
//  Copyright © 2020 Mospeng Research Lab Philippines. All rights reserved.
//

import UIKit

class HeroTableViewCell: UITableViewCell {

    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var heroSpecialSkillLabel: UILabel!
    
    override func awakeFromNib() {
        self.heroImageView.layer.masksToBounds = true
        self.heroImageView.layer.borderWidth = 0.5
        self.heroImageView.layer.cornerRadius = heroImageView.frame.width/2
    }
}
