//
//  SelectLocationViewController.swift
//  ARoomie
//
//  Created by Yong Ching on 23/01/2017.
//  Copyright © 2017 Yong Ching. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class SelectLocationViewController: UIViewController, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    // MARK: - Properties
    
    // Segue
    var advertisementId: Int?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var camera = GMSCameraPosition()
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // Store GMSGeocoder as an instance variable.
    let geocoder = GMSGeocoder()
    var currentLat: Double = 0
    var currentLng: Double = 0
    
    // Buttons
    var pinButton = UIButton()
    var searchButton = UIButton()
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: 2.921410, longitude: 101.632876)
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        // Initialize the location manager
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            currentLocation = locationManager.location
        }
        
        if let _ = advertisementId {
            initializeAdvertisement()
            
        } else {
            
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                currentLocation = locationManager.location
                
                camera = GMSCameraPosition.camera(withLatitude: (currentLocation?.coordinate.latitude)!,
                                                  longitude: (currentLocation?.coordinate.longitude)!,
                                                  zoom: zoomLevel)
                
            } else {
                camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                                  longitude: defaultLocation.coordinate.longitude,
                                                  zoom: zoomLevel)
            }
            
            // Create a map
            mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
            mapView.delegate = self
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // Add the map to the view, hide it until we've got a location update.
            view.addSubview(mapView)
            //mapView.isHidden = true
            
            // Add pin button
            pinButton.setImage(UIImage(named: "ic_pickup_pin"), for: UIControlState())
            pinButton.frame = CGRect(x: view.frame.width / 2 - 15, y: view.frame.height / 2 - 30, width: 30, height: 30)
            view.addSubview(pinButton)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - GMSMapVieDelegate
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapView.clear()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        
        //print("CAMERA: \(cameraPosition.target)")
        currentLat = Double(cameraPosition.target.latitude).roundTo(places: 6)
        currentLng = Double(cameraPosition.target.longitude).roundTo(places: 6)
        
        print("lat \(currentLat)")
        print("lng \(currentLng)")
        
        geocoder.reverseGeocodeCoordinate(cameraPosition.target) { (response, error) in
            guard error == nil else {
                return
            }
            
            if let result = response?.firstResult() {
                let marker = GMSMarker()
                marker.position = cameraPosition.target
                marker.title = result.lines?[0]
                marker.snippet = result.lines?[1] ?? ""
                marker.opacity = 0
                marker.map = mapView
                mapView.selectedMarker = marker
            }
        }
    }
    
    // MARK: - GMSAutocompleteViewControllerDelegate
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        //print("Place: \(place.coordinate)")
        
        let updatedCamera = GMSCameraUpdate.setTarget(place.coordinate)
        mapView.animate(with: updatedCamera)
        currentLat = Double(place.coordinate.latitude).roundTo(places: 6)
        currentLng = Double(place.coordinate.longitude).roundTo(places: 6)
        
        print("lat \(currentLat)")
        print("lng \(currentLng)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: \(error)")
        dismiss(animated: true, completion: nil)
    }
    
    // User cancelled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    // For advertisement update
    func initializeAdvertisement() {
        
        if let id = self.advertisementId {
            
                self.navigationItem.title = "Edit Location"
            APIManager.shared.getAdvertisement(byId: id, completionHandler: { json in
                
                if json != nil {
                    self.currentLat = json["lat"].doubleValue
                    self.currentLng = json["lng"].doubleValue
                    self.camera = GMSCameraPosition.camera(withLatitude: self.currentLat,
                                                           longitude: self.currentLng,
                                                           zoom: self.zoomLevel)
                    // Create a map
                    self.mapView = GMSMapView.map(withFrame: self.view.bounds, camera: self.camera)
                    self.mapView.delegate = self
                    self.mapView.isMyLocationEnabled = true
                    self.mapView.settings.myLocationButton = true
                    self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.view.addSubview(self.mapView)
                    
                    // Add pin button
                    self.pinButton.setImage(UIImage(named: "ic_pickup_pin"), for: UIControlState())
                    self.pinButton.frame = CGRect(x: self.view.frame.width / 2 - 15, y: self.view.frame.height / 2 - 30, width: 30, height: 30)
                    self.view.addSubview(self.pinButton)
                }
            })
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true,completion: nil)
    }
    
    @IBAction func searchLocation(_ sender: Any) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SegueNewAdDetails" {
            let controller = segue.destination as! NewAdDetailsTableViewController
            if let id = self.advertisementId {
                controller.advertisementId = id
            }
            controller.lat = String(format: "%.6f", currentLat)
            controller.lng = String(format: "%.6f", currentLng)
        }
    }
}

// Delegate to handle events for the location manager
extension SelectLocationViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    
    /**
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     let location: CLLocation = locations.last!
     //print("Location: \(location)")
     
     let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
     longitude: location.coordinate.longitude,
     zoom: zoomLevel)
     
     if mapView.isHidden {
     mapView.isHidden = false
     mapView.camera = camera
     } else {
     mapView.animate(to: camera)
     }
     }
     */
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
