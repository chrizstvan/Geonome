//
//  GeotificationViewModel.swift
//  Geonome
//
//  Created by Chris Stev on 03/12/20.
//  Copyright © 2020 Setel. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

final class GeotificationViewModel {
    var mapView: MKMapView?
    var view: UIViewController?
    var locationManager: CLLocationManager?
    var geotifications: [Geotification] = []
    
    // Loading all geotification data feom user default
    func loadAllGeotifications() {
        geotifications.removeAll()
        let allGeotifications = Geotification.allGeotifications()
        allGeotifications.forEach { add($0) }
    }
    
    // Saving all geotification to user default
    func saveAllGeotifications() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(geotifications)
            UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems)
        } catch {
            print("error encoding geotifications")
        }
    }
    
    // add is functions that update the model/associated views with geotification changes
    private func add(_ geotification: Geotification) {
        guard let mapView = self.mapView else { return }
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification, mapView: mapView)
        updateGeotificationsCount()
    }
    
    // remove handle removing geotification data, radius and annotation
    func remove(_ geotification: Geotification) {
        guard let index = geotifications.firstIndex(of: geotification), let mapView = self.mapView
            else { return }
        geotifications.remove(at: index)
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    // addRadiusOverlay handle draw radius to map view
    private func addRadiusOverlay(forGeotification geotification: Geotification, mapView: MKMapView) {
        mapView.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    // removeRadiusOverlay handle remove overlay from map view
    private func removeRadiusOverlay(forGeotification geotification: Geotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let mapView = self.mapView else { return }
        let overlays = mapView.overlays
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                mapView.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    // updateGeotificationsCount handle updating title text and validate geotification number
    private func updateGeotificationsCount() {
        guard let view = self.view else { return }
        view.navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20) // for this case
    }
    
    // region define location boundaries based on geotification
    private func region(with geotification: Geotification) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate,
                                      radius: geotification.radius,
                                      identifier: geotification.identifier)
        
        return region
    }
    
    // startMonitoring handle start of monitoring for area that user has define it before
    private func startMonitoring(geotification: Geotification) {
        guard let view = self.view, let locationManager = self.locationManager else { return }
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            view.showAlert(withTitle: Constant.errorTitle, message: Constant.monitoringNotAvailableMessages)
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = Constant.locationNotAuthMessages
            view.showAlert(withTitle:"Warning", message: message)
        }
        
        let fenceRegion = region(with: geotification)
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    // stopMonitoring handle start of monitoring for area that user has define it before
    func stopMonitoring(geotification: Geotification) {
        guard let locationManager = self.locationManager else { return }
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
}

extension GeotificationViewModel: AddGeotificationDelegate {
    func addGeotificationDelegate(
        _ controller: AddGeoficationViewController,
        didAddCoordinate coordinate: CLLocationCoordinate2D,
        radius: Double,
        identifier: String,
        note: String
    ) {
        guard let locationManager = self.locationManager else { return }
        controller.dismiss(animated: true, completion: nil)
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note)
        add(geotification)
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
}
