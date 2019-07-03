//
//  GeoVM.swift
//  WeatherTest
//
//  Created by Igor-Macbook Pro on 02/07/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift


class GeoVM {
    
    public static let shared = GeoVM()
    
    let realm = try! Realm()
 
    fileprivate func returnURL(lon : Double, lat : Double) -> String {
        return "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&APPID=e72ca729af228beabd5d20e3b7749713"
    }
    
    public func getWeather(lon : Double, lat : Double, callback : @escaping (WeatherCoordinate) -> ()) {
        Alamofire.request(GeoVM.shared.returnURL(lon: lon, lat: lat), method: .post).responseJSON { (response) in
            guard let data = response.result.value as? Dictionary<String, Any> else {
                return
            }
            
            guard let main = data["main"] as? Dictionary<String, Any> else {
                return
            }
            
            let temp = main["temp_max"] as? Double
            
          //  print(temp)
            if let temp = temp {
                let weatherCoord = WeatherCoordinate()
                weatherCoord.dateUpdated = Date()
                weatherCoord.lat = lat
                weatherCoord.lon = lon
                weatherCoord.temp = temp
                
                callback(weatherCoord)
            }
        }
    }
    
    fileprivate func saveWeather(weather : WeatherCoordinate) {
        try! realm.write {
            realm.add(weather)
        }
    }
    
    public func retrieveWeather() -> [WeatherCoordinate] {
        let result = realm.objects(WeatherCoordinate.self)
        var coordsList = [WeatherCoordinate]()
        
        for res in result {
            coordsList.append(res)
        }
        
        return coordsList
    }
    
    public func deleteObj(weather : WeatherCoordinate) {
        try! realm.write {
            realm.delete(weather)
        }
    }
    
}
