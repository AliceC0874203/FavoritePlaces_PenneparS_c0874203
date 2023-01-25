//
//  MapViewController.swift
//  favoritePlaces_Pennapar_c0874203
//
//  Created by Alice’z Poy on 2023-01-24.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    // create location manager
    var locationMnager = CLLocationManager()
    var destination = CLLocationCoordinate2D()
    var selectedPin:MKPlacemark? = nil
    var resultSearchController:UISearchController? = nil
    var currentLocation = CLLocation()
    var context: NSManagedObjectContext?
    var selectedPlace: Place? {
        didSet {
            destination = CLLocationCoordinate2D(latitude: selectedPlace?.longitude ?? 0, longitude: selectedPlace?.longitude ?? 0)
        }
    }
    var indexPath: IndexPath?
    var places: [Place]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.isZoomEnabled = false
        map.showsUserLocation = false
        locationMnager.delegate = self
        map.delegate = self
        
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        locationMnager.requestWhenInUseAuthorization()
        locationMnager.startUpdatingLocation()
        
        // add addLongPress tap for add markers
        addDoubleTab()
        
        //Setup for searching location
        setUpforSearch()
    }
    
    func setUpforSearch() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as? any UISearchResultsUpdating
        
        let searchBar = resultSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = map
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func addDoubleTab() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        removePin()
        
        // add annotation
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.title = "my favorite"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        destination = coordinate
    }
    
    //MARK: - remove pin from map
    func removePin() {
        map.removeAnnotations(map.annotations)
    }
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        map.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
    }
    
    func addFavoritePlace() {
        
        let context = context ?? (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let indexPath = indexPath, let _places = places {
            CoreDataManager.deletePlace(place: _places[indexPath.row], context: context)
            CoreDataManager.savePlaces(context: context)
            places?.remove(at: indexPath.row)
        }
        
        let place = Place(context: context)
        
        LocationPlaceManager.convertLatLongToAddress(latitude: destination.latitude, longitude: destination.longitude, completion: { [weak self] address in
            guard let strongSelf = self else {
                return
            }
            
            place.address = address
            place.latitude = strongSelf.destination.latitude
            place.longitude = strongSelf.destination.longitude
            CoreDataManager.savePlaces(context: context)
            strongSelf.navigationController?.popViewController(animated: true)
        })
    }
    
    func popUpAddPlace() {
        let alertController = UIAlertController(title: "Your Favorite", message: "A nice place to visit. Do you want to add to favorite list?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default,handler: { action in
            self.addFavoritePlace()
         }))
        present(alertController, animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "my favorite":
            let annotationView = map.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKMarkerAnnotationView()
            annotationView.canShowCallout = true
            annotationView.isDraggable = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            if selectedPlace == nil {
                popUpAddPlace()
            }
            return annotationView
        default:
            return nil
        }
    }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        popUpAddPlace()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState)
    {
        if (newState == MKAnnotationView.DragState.ending)
        {
            let droppedAt = view.annotation?.coordinate
            print("dropped at : ", droppedAt?.latitude ?? 0.0, droppedAt?.longitude ?? 0.0);
            view.setDragState(.none, animated: true)
            destination = droppedAt ?? destination
            popUpAddPlace()
        }
    }
}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        selectedPin = placemark
        dropPin(sender: UITapGestureRecognizer())
    }
}

extension MapViewController: CLLocationManagerDelegate {
    //MARK: - didupdatelocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        currentLocation = userLocation
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "my location", subtitle: "you are here")
        removePin()
        
        if selectedPlace != nil {
            displayLocation(latitude: selectedPlace?.latitude ?? 0, longitude: selectedPlace?.longitude ?? 0, title: "my favorite", subtitle: "you favorite place")
        }
    }
}
