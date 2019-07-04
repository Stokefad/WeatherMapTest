//
//  WeatherCoordinate.swift
//  WeatherTest
//
//  Created by Igor-Macbook Pro on 03/07/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import Foundation
import RealmSwift


class WeatherCoordinate : Object {
    
    @objc dynamic var lon = Double()
    @objc dynamic var lat = Double()
    @objc dynamic var dateUpdated = Date()
    @objc dynamic var temp = Double()
    @objc dynamic var span = Double()
    @objc dynamic var weather = String()
    
}
