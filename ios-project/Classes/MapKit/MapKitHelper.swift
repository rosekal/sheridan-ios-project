//  Class: MapKitHelper.swift
//
//  Created by: Kalen Rose
//
// Purpose: Handling the core mapkit functionalities, as well as getting the directions for
// the table view.

import UIKit
import MapKit
import CoreLocation

class MapKitHelper: NSObject {
    //Referenced MapView object that will be used to manipulate MapView on the View
    var mapView : MKMapView!
    
    //Referenced TableView object that will be used to manipulate MapView on the View
    var tableView: UITableView!
    
    //A mutable array for containing all of the direction steps
    var routeSteps = [""] as NSMutableArray
    
    //Storing the user's location (obtained via GPS)
    var initLocation : CLLocation!
    
    //A double to store the radius (for centering map)
    var radius : Double! = 0
    
    //MapPreferences object that will be used to set the settings of the MapView
    var mapPreferences : MapPreferences!
    
    //Function to obtain all of the polylines and direction steps based on the destination
    func loadRoutes(destination: String){
        
        //Removing all existing objects from MapView
        self.routeSteps.removeAllObjects()
        let overlays = self.mapView.overlays
        self.mapView.removeOverlays(overlays)

        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        //Creating a new pin for initial location
        createPin("Current location", initLocation.coordinate)
        
        //More specific string for passing into CLGeocoder
        var verboseDestination : String!
        
        //Converting the one-word campus into a larger description
        switch(destination){
        case "davis":
            verboseDestination = "Sheridan College Davis Brampton Ontario"
            break
        case "trafalgar":
            verboseDestination = "Sheridan College Trafalgar Oakville Ontario"
            break
        case "hmc":
            verboseDestination = "Sheridan College HMC Mississauga Ontario"
            break
        default:
            break
        }
        
        
        var directions : MKDirections!
        
        //Creating a new CLGeocoder object and passing the dest string into the appropriate method
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(verboseDestination) { (placemarks, error) in
            if error != nil{
                print("error", error!)
            }
            
            //Setting the first placemark
            if let placemark = placemarks?.first{
                
                //Getting the coordinates of the destination, and creating the pin for it
                let coordinates : CLLocationCoordinate2D = (placemark.location?.coordinate)!
                let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                self.createPin(placemark.name!, newLocation.coordinate)
                
                
                //Creating the direction request, and setting the source/destination for it.
                let request = MKDirectionsRequest()
                let sourceCoordinate = self.initLocation.coordinate
                request.source = MKMapItem(placemark: MKPlacemark(
                    coordinate: sourceCoordinate, addressDictionary: nil))
                
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
                
                request.requestsAlternateRoutes = false
                
                //Change the transport type based on the map preferences
                switch(self.mapPreferences.transportType){
                case "car":
                    request.transportType = .automobile
                    break;
                case "walk":
                    request.transportType = .walking
                    break;
                case .none:
                    break;
                case .some(_):
                    break;
                }
                
                directions = MKDirections(request: request)
                
                //Getting the route lines and directions
                directions.calculate(completionHandler: {response, error in
                    for route in (response?.routes)!{
                        //Adding the polyline onto the mapview
                        self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                        
                        //If there's a toll required, let the user know.
                        for advise in (route.advisoryNotices){
                            if advise == "Toll required."{
                                self.routeSteps.add("Requires taking a tolled highway.")
                            }
                        }
                        
                        //Updating the tableview with directions
                        for step in route.steps {
                            self.routeSteps.add(step.instructions)
                            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                            self.tableView.reloadData()
                        }
                    }
                    
                    directions = MKDirections(request: request)
                    
                    //For calculating the ETA.
                    directions.calculateETA(completionHandler: {response, error in
                        
                        //Formatting the output
                        let formatter = DateFormatter()
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.dateFormat = "hh:mm:ss a"
                        formatter.amSymbol = "AM"
                        formatter.pmSymbol = "PM"
                        
                        //Obtaining the ETA
                        let expectedArrival = formatter.string(from: (response?.expectedArrivalDate)!)
                        
                        //Appending the very last row (arrived at location) with the ETA
                        let lastRouteStep = self.routeSteps[(self.routeSteps.count - 1)]
                        self.routeSteps[(self.routeSteps.count - 1)] = "\(lastRouteStep) at \(expectedArrival)"
                        self.tableView.reloadData()
                    })
                })
            }
        }
    }

    //Function for centering the map based on a location
    func centerMapOnLocation(_ location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  radius * 2.0, radius * 2.0)
        
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Function for creating a pin on the mapView
    func createPin(_ title: String, _ coordinate: CLLocationCoordinate2D){
        //Creating the pin
        let dropPin = MKPointAnnotation()
        
        //Customizing the pin
        dropPin.title = title
        dropPin.coordinate = coordinate
        
        //Dropping the pin on the MapView
        self.mapView.addAnnotation(dropPin)
        self.mapView.selectAnnotation(dropPin, animated: true)
    }
    
    //Function for setting the map type of the MapView
    func setMapType(mapView: MKMapView){
        
        //Switching the mapType in MapPreferences, then configuring the MapView accordingly
        switch(mapPreferences.mapType){
        case "hybrid":
            self.mapView.mapType = .hybrid
            break;
        case "satellite":
            self.mapView.mapType = .satellite
            break;
        case "standard":
            self.mapView.mapType = .standard
            break;
        case .none:
            break;
        case .some(_):
            break;
        }
    }
}







