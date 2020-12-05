//
//  GeotifViewModel.swift
//  Geonome
//
//  Created by Chris Stev on 05/12/20.
//  Copyright © 2020 Setel. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

final class GeotificationViewModel: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        
        return note
    }
    
    var subtitle: String? {
        "Radius: \(radius)m - \(note) Area"
    }
    
    init(geotif: Geotification) {
        self.coordinate = geotif.coordinate
        self.radius = geotif.radius
        self.identifier = geotif.identifier
        self.note = geotif.note
    }
}

extension GeotificationViewModel {
    class func allGeotifications() -> [GeotificationViewModel] {
        guard let savedData = UserDefaults.standard.data(forKey: PreferencesKeys.savedItems) else {
            return []
        }
        
        let decoder = JSONDecoder()
        if let savedGeotifications = try? decoder.decode(Array.self, from: savedData) as [Geotification] {
            return savedGeotifications.map{GeotificationViewModel(geotif: $0)}
        }
        
        return []
    }
}
