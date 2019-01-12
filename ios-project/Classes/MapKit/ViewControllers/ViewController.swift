//  Class: ViewController.swift
//
//  Created by: Kalen Rose
//
// Purpose: The controller for the view dedicated for prompting the user to enter settings
// for the mapview.

import UIKit
import MapKit

class ViewController: UIViewController {
    //An unwind method if the user wants to change the current settings
    @IBAction func unwindToHomeViewContoller(_ sender: UIStoryboardSegue){
        
    }
    
    //IBOutlets for connecting to the views that act as containers
    @IBOutlet var view1 : UIView!
    @IBOutlet var view2 : UIView!
    @IBOutlet var view3 : UIView!
    
    //An IBOutlet for connecting to the segment to choose the polyline colour
    @IBOutlet var colourSegment : UISegmentedControl?
    
    //An IBOutlet for connecting to the segment to choose the type of the map
    @IBOutlet var mapTypeSegment : UISegmentedControl?
    
    //An IBOutlet for connecting to the segment to choose the type of transportation
    @IBOutlet var transportSegment : UISegmentedControl?
    
    //An IBOutlet for connecting to the image that shows a preview of the map type
    @IBOutlet var mapTypeImage : UIImageView?
    
    //An IBOutlet for connecting to the image that shows a preview of the polyline colour
    @IBOutlet var colourImage : UIImageView?
    
    //An IBOutlet for connecting to the button that will bring the user to the next view
    @IBOutlet var goButton : UIButton?
    
    //An IBOutlet for connecting to the button that will bring th euser to the previous view
    @IBOutlet var backButton : UIButton?
    
    //An IBOutlet for connecting to the header label to the label on the view
    @IBOutlet var header : UILabel?
    
    //An array for passing the selected map type to the map preferences, based on the segmnent choice
    var mapTypeArr = ["standard", "satellite", "hybrid"]
    
    //An array for passing the selected colour to the map preferences, based on the segment choice
    var colourArr = ["red", "blue", "green", "yellow", "orange"]
    
    //An array for passing the selected transport type to the map preferences, based on the segment choice
    var transportArr = ["car", "walk"]
    
    //A LocationManager object for requesting access to GPS
    var locationManager = CLLocationManager()
    
    //An IBAction event handler for colour segment on value change, for updating preview image
    @IBAction func colourSegmentOnChange(sender: UISegmentedControl){
        colourImage?.image = UIImage(named: colourArr[sender.selectedSegmentIndex]);
    }
    
    //An IBAction event handler for map type segment on value change, for updating preview image
    @IBAction func mapTypeSegmentOnChange(sender: UISegmentedControl){
        mapTypeImage?.image = UIImage(named: mapTypeArr[sender.selectedSegmentIndex]);
    }
    
    //For checking if the user has enabled the location services
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool{
        if CLLocationManager.locationServicesEnabled(){
            
            //It may be enabled, but we need to check the authorization status.
            switch CLLocationManager.authorizationStatus() {
                
            //If unauthorized, prompt the user to enable it through the settings via alert box
            case .notDetermined, .restricted, .denied:
                
                let alert = UIAlertController(title: "Error", message: "Please allow the application to access your location before using this feature.  \n\nYou can enable it through Settings -> Privacy -> Location Services -> ios-project -> Always", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                return false
                
            //If it's enable, return true which will allow the user to see the next view.
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        }
        
        //Otherwise, don't redirect the user to the next view.
        return false
    }
    
    //Prepare method for passing all of the information into the view containing the map and table
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        let reciever = segue.destination as! MapViewController
        var selectedColour : UIColor!
        
        //Switching on the current selected colour, then converting it to a UIColor object
        switch(colourArr[colourSegment!.selectedSegmentIndex]){
        case "red":
            selectedColour = UIColor.red
            break
        case "blue":
            selectedColour = UIColor.blue
            break
        case "green":
            selectedColour = UIColor.green
            break
        case "yellow":
            selectedColour = UIColor.yellow
            break
        case "orange":
            selectedColour = UIColor.orange
            break
        default:
            break
        }
        
        //Creating the MapPreferences object within the next controller
        reciever.mapPreferences = MapPreferences(colour: selectedColour,
                                                 map: mapTypeArr[mapTypeSegment!.selectedSegmentIndex],
                                                 transport: transportArr[(transportSegment?.selectedSegmentIndex)!])
        
        //Creating the MapKitHelper object within the next controller
        reciever.mapKitHelper = MapKitHelper()
    }
    
    //Required viewDidLoad method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colourImage!.image = UIImage(named: colourArr[0])!
        mapTypeImage!.image = UIImage(named: mapTypeArr[0])!
        
        //Requesting access to current location via GPS, then update the location
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupViews([view1, view2, view3, colourImage!, mapTypeImage!, goButton!, backButton!])
        
        let attrString = NSAttributedString(string: "Get to any Sheridan College campus without hassle.", attributes: [NSAttributedStringKey.strokeColor: UIColor.white, NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.strokeWidth: -3.0, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 24.0)])

        header?.attributedText = attrString
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
    
    //Required didRecieveMemoryWarning method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
