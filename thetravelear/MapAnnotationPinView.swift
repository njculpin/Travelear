//
//  MapAnnotationPinView.swift
//  Travelear
//
//  Created by Nicholas Culpin on 6/21/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//
//
// This is the annotation pin itself
//

import UIKit
import MapKit

private let mapPinImageDeselected = UIImage(named: "mapPinDeselected.png")!
private let mapPinImageSelected = UIImage(named: "mapPinSelected.png")!
private let pinAnimationTime = 0.300

class MapAnnotationPinView: MKAnnotationView {
        
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        self.image = mapPinImageDeselected
        clusteringIdentifier = MKMapViewDefaultClusterAnnotationViewReuseIdentifier
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false
        self.image = mapPinImageDeselected
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.image = mapPinImageSelected
        } else {
            self.image = mapPinImageDeselected
        }
        
    }
}
