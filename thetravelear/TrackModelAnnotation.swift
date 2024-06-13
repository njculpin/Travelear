//
//  TrackModelAnnotation.swift
//  Travelear
//
//  Created by Nicholas Culpin on 6/21/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//
//
// This is annotation pin text
//

import UIKit
import MapKit

class TrackModelAnnotation: NSObject, MKAnnotation {
    
    var track: Track

    init(track:Track){
        self.track = track
        super.init()
    }

    var title: String? {
        let title = track.name
        return title
    }
    
    var coordinate: CLLocationCoordinate2D {
        let lat = track.latitude
        let long = track.longitude
        let coord = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        return coord
    }
    
}
