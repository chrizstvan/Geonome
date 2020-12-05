//
//  GeotifPresenter.swift
//  Geonome
//
//  Created by Chris Stev on 05/12/20.
//  Copyright © 2020 Setel. All rights reserved.
//

import Foundation
import MapKit

protocol GeotifPresenterProtocol {
    func addAnnotationAndRadiusOverlay(
        geotif: GeotificationViewModel,
        mapView: MKMapView,
        isMaxGeotifications: Bool
    )
    
    func removeAnnotationAndRadiusOverlay(
        geotif: GeotificationViewModel,
        mapView: MKMapView,
        isMaxGeotifications: Bool
    )
    
    func presentAlert(title: String, messages: String)
}

final class GeotifPresenter: NSObject, GeotifPresenterProtocol {
    weak var view: GeotifViewProtocol?
    
    // addAnnotationAndRadiusOverlay presenting overlay and annotation to map
    func addAnnotationAndRadiusOverlay(
        geotif: GeotificationViewModel,
        mapView: MKMapView,
        isMaxGeotifications: Bool
    ) {
        mapView.addAnnotation(geotif)
        mapView.addOverlay(
            MKCircle(
                center: geotif.coordinate,
                radius: geotif.radius
            )
        )
        
        view?.setGeofence(mapView: mapView, isMaxGeotification: isMaxGeotifications)
    }
    
    // removeAnnotationAndRadiusOverlay remove overlay and annotation from map
    func removeAnnotationAndRadiusOverlay(
        geotif: GeotificationViewModel,
        mapView: MKMapView,
        isMaxGeotifications: Bool
    ) {
        mapView.removeAnnotation(geotif)
        let overlays = mapView.overlays
        
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else {
                continue
            }
            
            let coord = circleOverlay.coordinate
            if coord.latitude == geotif.coordinate.latitude
                && coord.longitude == geotif.coordinate.longitude
                && circleOverlay.radius == geotif.radius {
                mapView.removeOverlay(circleOverlay)
                break
            }
        }
        
        view?.removeGeofence(mapView: mapView, isMaxGeotification: isMaxGeotifications)
    }
    
    // presentAlert showing alert to related view
    func presentAlert(title: String, messages: String) {
        view?.showNeededAlert(title: title, messages: messages)
    }
}


