//
//  ViewController.swift
//  FavoritePlaces_PenneparS_c0874203
//
//  Created by Alice’z Poy on 2023-01-24.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    // create places
    var places = [Place]()
    
    // create the context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadPlaces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPlaces()
    }
    
    //MARK: - Core data interaction functions
    func loadPlaces() {
        places = CoreDataManager.loadPlaces(context: context) ?? [Place]()
        tableView.reloadData()
    }
    
    private func openMapView(indexPath: IndexPath) {
        let mapViewController:MapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController ?? MapViewController()
        mapViewController.selectedPlace = places[indexPath.row]
        mapViewController.places = places
        mapViewController.indexPath = indexPath
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "place_cell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.address
        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataManager.deletePlace(place: places[indexPath.row], context: context)
            CoreDataManager.savePlaces(context: context)
            places.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openMapView(indexPath: indexPath)
    }
}
