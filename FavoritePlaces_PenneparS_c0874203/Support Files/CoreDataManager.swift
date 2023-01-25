//
//  CoreDataManager.swift
//  favoritePlaces_Pennapar_c0874203
//
//  Created by Alice’z Poy on 2023-01-24.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    /// load places deom core data
    /// - Parameter predicate: parameter comming from search bar - by default is nil
    static func loadPlaces(context: NSManagedObjectContext) -> [Place]? {
        let request: NSFetchRequest<Place> = Place.fetchRequest()
        
        do {
            let places = try context.fetch(request)
            return places
        } catch {
            print("Error loading places \(error.localizedDescription)")
            return nil
        }
    }
    
    /// delete places from context
    /// - Parameter Place: Place defined in Core Data
    static func deletePlace(place: Place, context: NSManagedObjectContext) {
        context.delete(place)
    }
    
    /// Save places into core data
    static func savePlaces(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Error saving the places \(error.localizedDescription)")
        }
    }
}
