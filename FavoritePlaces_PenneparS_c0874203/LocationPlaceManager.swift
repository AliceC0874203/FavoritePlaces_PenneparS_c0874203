//
//  LocationPlaceManager.swift
//  favoritePlaces_Pennapar_c0874203
//
//  Created by Alice’z Poy on 2023-01-24.
//

import Foundation
import CoreLocation

class LocationPlaceManager {
    
    static func convertLatLongToAddress(latitude:Double,longitude:Double, completion: @escaping (_ address: String?)-> Void) {
        
        var address = ""
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Street address
            if let street = placeMark.thoroughfare {
                print(street)
                address += "\(street)" + ", "
            }
            // City
            if let city = placeMark.locality {
                print(city)
                address += "\(city)" + ", "
            }
            // State
            if let state = placeMark.administrativeArea {
                print(state)
                address += "\(state)" + ", "
            }
            // Zip code
            if let zipCode = placeMark.postalCode {
                print(zipCode)
                address += "\(zipCode)" + ", "
            }
            // Country
            if let country = placeMark.country {
                print(country)
                address += "\(country)" + ", "
            }
            
            completion(address)
        })
    }
}
