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
    
    dynamic var lat = Double()
    dynamic var lon = Double()
    dynamic var dateUpdated = Date()
    dynamic var temp = Double()
    
}
