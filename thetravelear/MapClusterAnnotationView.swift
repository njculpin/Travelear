//
//  MapClusterAnnotationView.swift
//  Travelear
//
//  Created by Nicholas Culpin on 11/23/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit
import MapKit

class MapClusterAnnotationView: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
        self.canShowCallout = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
    
        if let cluster = annotation as? MKClusterAnnotation {
            
            if cluster.memberAnnotations.count > 0 {
                image = drawCircle(count: cluster.memberAnnotations.count)
                displayPriority = .defaultLow
            }

        }
    }
    
    private func drawCircle(count:Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        return renderer.image { _ in
            UIColor.TravRed().setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).fill()
            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: 3, y: 3, width: 34, height: 34)).fill()
            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                               NSAttributedString.Key.font: UIFont.TravDemiSmall()]
            let text = "\(count)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }
    }
    
}
