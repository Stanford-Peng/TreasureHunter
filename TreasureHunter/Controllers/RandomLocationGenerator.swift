//
//  RandomLocationGenerator.swift
//  TreasureHunter
//
//  Created by Stanford on 11/11/20.
//

import Foundation
import CoreLocation
//reference:https://gist.github.com/inorganik/fcaa143eba6178fb672c5c335a11c564
//https://gis.stackexchange.com/questions/334297/generate-coordinates-with-minimum-maximum-distance-from-given-coordinates
struct randomLocations {

    // create random locations (lat and long coordinates) around user's location
    func getMockLocationsFor(location: CLLocation, count: Int, minDistanceKM:Int, maxDistanceKM:Int) throws -> [CLLocation] {
        if (minDistanceKM > maxDistanceKM){
            throw "Error in randomLocations"
        }
        
        // earth radius in km
        let EARTH_RADIUS = Double(6371)
        // 1 degree in meters
        let DEGREE = (EARTH_RADIUS * 2 * Double.pi / 360) * 1000
        
        //random distance within range in meters
        let max = Double(maxDistanceKM) * 1000.0
        let min = Double(minDistanceKM) * 1000.0
        let r = min + (max-min) * sqrt(Double.random(in: 0.0 ..< 1.0))
        
        //random angle
        let theta = Double.random(in: 0.0 ..< 1.0) * 2 * Double.pi
        
        let dy = r * sin(theta)
        let dx = r * cos(theta)
        
        // arc/radius = radian
        let newLatitude = location.coordinate.latitude + dy/DEGREE
        let newLongitude = location.coordinate.longitude + dx/DEGREE
        
//        func getBase(number: Double) -> Double {
//            return round(number * 1000)/1000
//        }
//        func randomCoordinate() -> Double {
//            return Double(arc4random_uniform(140)) * 0.0001
//        }
//
//        let baseLatitude = getBase(number: location.coordinate.latitude - 0.007)
//        // longitude is a little higher since I am not on equator, you can adjust or make dynamic
//        let baseLongitude = getBase(number: location.coordinate.longitude - 0.008)
        
        var items = [CLLocation]()
        for _ in 0..<count {
            let location = CLLocation(latitude: newLatitude, longitude: newLongitude)
            items.append(location)

        }
        
        return items
    }
}

extension String:Error{
    
}
