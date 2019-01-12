//  Class: MapViewController.swift
//
//  Created by: Kalen Rose
//
// Purpose: The controller for the view dedicated for displaying the map, directions, and a
// picker view for changing between campuses

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource {
    
    //Object for retrieving the data from the selected map preferences
    var mapPreferences : MapPreferences!
    
    //Object for calling methods to populate map polylines and tableview direction
    var mapKitHelper : MapKitHelper! = MapKitHelper()
    
    //For checking if the location selection was the same from the previous selection
    var currentSelection : String!
    
    //String array for storing the sheridan campuses
    var data = [String]()
    
    //Obligatory location manager for the mapview
    let locationManager = CLLocationManager()
    
    //IBOutlet for connecting to the mapview on the view
    @IBOutlet var mapView : MKMapView!
    
    //IBOutlet for connecting to the pickerview on the view
    @IBOutlet var pickerView: UIPickerView!
    
    //IBOutlet for connecting to the tableview on the view
    @IBOutlet var tableView: UITableView!
    
    //IBOutlet for connecting to a view that acts as a container
    @IBOutlet var view1 : UIView!
    
    //Obligatory viewDidLoad method to set everything up
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up the data array
        data = ["davis", "trafalgar", "hmc"]
        
        //Default current selection is Davis campus
        currentSelection = "davis"
        
        //Setting up the mapView
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        
        //If they are enabled by user, set up the locationManager
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            //Setting up the sourceCoordinates based on the locationManager
            let sourceCoordinates = locationManager.location?.coordinate
            
            //Setting up the mapKitHelper fields
            mapKitHelper.mapView = mapView
            mapKitHelper.tableView = tableView
            mapKitHelper.initLocation = CLLocation(latitude: (sourceCoordinates?.latitude)!,
                                                   longitude: (sourceCoordinates?.longitude)!)
            mapKitHelper.mapPreferences = mapPreferences;
            mapKitHelper.radius = 10000
            
            //Centering the map based on initial location, and creating a new pin
            mapKitHelper.centerMapOnLocation(mapKitHelper.initLocation)
            mapKitHelper.createPin("Current location", mapKitHelper.initLocation.coordinate)
            
            //Getting the routes based on the curerntSelection (default value)
            mapKitHelper.loadRoutes(destination: currentSelection)
            
            //Setting up the map type
            mapKitHelper.setMapType(mapView: mapView);
        }
        
        //Create the borders for all of the views specified in the array
        setupViews([mapView, tableView, view1])
    }
    
    //mapView method for rendering a circle and polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //If the overlay is a circle, render the yellow circle and return it
        //Otherwise, it will be a polyline with a colour specified in the preferences
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay as! MKCircle)
            circle.strokeColor = UIColor.yellow
            circle.fillColor = UIColor(red: 255, green: 255, blue: 0, alpha: 0.1)
            circle.lineWidth = 2.0
            return circle
        }else{
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            
            renderer.strokeColor = mapPreferences.polylineColour
            renderer.lineWidth = 3.0
            return renderer
        }
    }
    
    //Used for creating the border for multiple views
    func setupViews(_ views: [UIView]){
        for view in views{
            view.layer.masksToBounds=true
            view.layer.borderWidth=3
            view.layer.borderColor = UIColor.black.cgColor
            view.layer.cornerRadius = 20
        }
    }
    
    //Obligatory didRecieveMemoryWarning method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //pickerView method for when the user changes the pickerView option
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = self.data[row]
        if(selected != currentSelection){
            currentSelection = selected
            _ = mapKitHelper.loadRoutes(destination: currentSelection)
        }
    }
    
    //tableView method for setting the amount of rows the table has, based on the number of route steps
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapKitHelper.routeSteps.count
    }
    
    //tableView method for setting the height for each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    //tableView method for setting the text of each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        tableCell.textLabel?.text = mapKitHelper.routeSteps[indexPath.row] as? String
        
        return tableCell
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
    //pickerView method for setting the number of components (only one is needed)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}


