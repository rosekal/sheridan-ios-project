//  Class: MapPreferences.swift
//
//  Created by: Kalen Rose
//
// Purpose: Storing all of the user's choices for how the map looks, how it will function,
// and other options.

import UIKit

class MapPreferences: NSObject {
    //Colour object for defining the colour of the polyline on the MapView
    var polylineColour : UIColor!
    
    //String for defining the map type of the MapView
    var mapType : String!
    
    //String for defining the transport type of the MapView
    var transportType : String!
    
    //Constructor method to initialize all of the aforementioned fields
    init(colour polylineColour : UIColor, map mapType: String, transport transportType: String){
        self.polylineColour = polylineColour
        self.mapType = mapType
        self.transportType = transportType
    }
}
