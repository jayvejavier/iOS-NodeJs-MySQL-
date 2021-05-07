//
//  Hero.swift
//  avengers_app
//
//  Created by Mospeng Research Lab Philippines on 8/12/20.
//  Copyright © 2020 Mospeng Research Lab Philippines. All rights reserved.
//

import Foundation

struct Hero: Decodable {
    let id: Int
    let name, special_skill, image: String
}
