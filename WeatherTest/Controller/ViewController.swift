//
//  ViewController.swift
//  WeatherTest
//
//  Created by Igor-Macbook Pro on 02/07/2019.
//  Copyright © 2019 Igor-Macbook Pro. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var latCoords = [Double]()
    var longCoords = [Double]()
    
    var prevSpan = Double()
    
    let queue = DispatchQueue(label: "fds", qos: .userInteractive, attributes: .concurrent)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        configurePolygon()
        getWeatherData()
    }
    
    private func addAnnotation(title : String, lat : Double, lon : Double) {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(exactly: lat)!, CLLocationDegrees(exactly: lon)!)
        mapView.addAnnotation(annotation)
    }
    
    private func getWeatherData() {
        let center = mapView.region.center
        var fitCounter = 0
        
        let maxLatCoordOne = center.latitude + mapView.region.span.latitudeDelta / 2
        let maxLatCoordTwo = center.latitude - mapView.region.span.latitudeDelta / 2
        
        let maxLonCoordOne = center.longitude + mapView.region.span.longitudeDelta / 2
        let maxLonCoordTwo = center.longitude - mapView.region.span.longitudeDelta / 2
        
        
        let weatherObjects = GeoVM.shared.retrieveWeather()
        
        for obj in weatherObjects {
            if obj.lat < maxLatCoordOne, obj.lat < maxLatCoordTwo, obj.lon < maxLonCoordOne, obj.lon < maxLonCoordTwo, obj.dateUpdated.timeIntervalSince1970 + 30 * 60 * 1000 > Date().timeIntervalSince1970 {
                fitCounter += 1
            }
            if obj.dateUpdated.timeIntervalSince1970 + 30 * 60 * 1000 < Date().timeIntervalSince1970 {
                GeoVM.shared.deleteObj(weather: obj)
            }
        }
        
        if fitCounter > 15 {
            for obj in weatherObjects {
                addAnnotation(title: String(describing: obj.temp), lat: obj.lat, lon: obj.lon)
            }
        }
        else {
            showWeatherAPI()
        }
    }
    
    private func configurePolygon() {
        var points = [CLLocationCoordinate2D]()
        
        let ratioLong = mapView.region.span.longitudeDelta / 180
        let ratioLat = mapView.region.span.latitudeDelta / 180
        
        let stepLong = 180 / 5 * ratioLong
        let stepLat = 90 / 5 * ratioLat
        
        let maxLatCoordOne = mapView.region.center.latitude + mapView.region.span.latitudeDelta / 2
        let maxLatCoordTwo = mapView.region.center.latitude - mapView.region.span.latitudeDelta / 2
        
        let maxLonCoordOne = mapView.region.center.longitude + mapView.region.span.longitudeDelta / 2
        let maxLonCoordTwo = mapView.region.center.longitude - mapView.region.span.longitudeDelta / 2
    
        for i in Int(-5 / ratioLong) ... Int(5 / ratioLong) {
            for j in -1 ... 1 {
                points.append(CLLocationCoordinate2DMake(CLLocationDegrees(exactly: Double(i * 36) * ratioLong)!, CLLocationDegrees(exactly: Double(j * 180))!))
                if (Double(i * 36) * ratioLong) + stepLong / 2 < maxLonCoordOne, (Double(i * 36) * ratioLong) + stepLong / 2 > maxLonCoordTwo {
                    if j == 0 {
                        if i > 0 {
                            longCoords.append((Double(i * 36) * ratioLong) + stepLong / 2)
                        }
                        else {
                            longCoords.append((Double(i * 36) * ratioLong) - stepLong / 2)
                        }
                    }
                }
            }
            let polyline = MKPolyline(coordinates: points, count: points.count)
            
            mapView.addOverlay(polyline)
            points = []
        }
        
        for i in Int(-5 / ratioLat) ... Int(5 / ratioLat) {
            for j in -1 ... 1 {
                points.append(CLLocationCoordinate2DMake(CLLocationDegrees(exactly: Double(j * 90))!, CLLocationDegrees(exactly: Double(i * 36) * ratioLat)!))
                if j == 0 {
                    if (Double(i * 36) * ratioLat) + stepLat / 2 < maxLatCoordOne, (Double(i * 36) * ratioLat) + stepLat / 2 > maxLatCoordTwo {
                        if i > 0 {
                            latCoords.append((Double(i * 36) * ratioLat) + stepLat / 2)
                        }
                        else {
                            latCoords.append((Double(i * 36) * ratioLat) - stepLat / 2)
                        }
                    }
                }
            }
            let polyline = MKPolyline(coordinates: points, count: points.count)
            
            mapView.addOverlay(polyline)
            points = []
        }
        
    }
    
    private func showWeatherAPI() {
        print(latCoords.count * longCoords.count)
        queue.sync { [unowned self] in
            for lat in self.latCoords {
                for lon in self.longCoords {
                    GeoVM.shared.getWeather(lon: lon, lat: lat, callback: { (weatherCoord) in
                        self.addAnnotation(title: "\(weatherCoord.temp)", lat: lat, lon: lon)
                        print(self.mapView.annotations.count)
                    })
                }
            }
        }
    }
}

extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.black
            renderer.lineWidth = 0.2
            
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        latCoords = []
        longCoords = []
        configurePolygon()
        getWeatherData()
    }
}
