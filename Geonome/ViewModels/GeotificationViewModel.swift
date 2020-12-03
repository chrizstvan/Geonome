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
    var geotifications: [Geotification] = []
    
    //Loading and saving func
    func loadAllGeotifications(mapView: MKMapView, mainView: UIViewController) {
        geotifications.removeAll()
        let allGeotifications = Geotification.allGeotifications()
        allGeotifications.forEach { add(geotification: $0, mapView: mapView, view: mainView) }
    }
    
    func saveAllGeotifications() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(geotifications)
            UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems)
        } catch {
            print("error encoding geotifications")
        }
    }
    
    // Functions that update the model/associated views with geotification changes
    private func add(geotification: Geotification, mapView: MKMapView, view: UIViewController) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification, mapView: mapView)
        updateGeotificationsCount(view: view)
    }
    
    func remove(geotification: Geotification, mapView: MKMapView, view: UIViewController) {
        guard let index = geotifications.firstIndex(of: geotification) else { return }
        geotifications.remove(at: index)
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification, mapView: mapView)
        updateGeotificationsCount(view: view)
    }
    
    // Map overlay functions
    private func addRadiusOverlay(forGeotification geotification: Geotification, mapView: MKMapView) {
        mapView.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: Geotification, mapView: MKMapView) {
        // Find exactly one overlay which has the same coordinates & radius to remove
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
    
    // Update title
    private func updateGeotificationsCount(view: UIViewController) {
        view.title = "Geotifications: \(geotifications.count)"
        view.navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20) // new added 11
    }
    
    // add geotification
    func geotificationDidAdd(
        mapView: MKMapView,
        view: UIViewController,
        controller: AddGeoficationViewController,
        locationManager: CLLocationManager,
        coordinate: CLLocationCoordinate2D,
        radius: Double,
        identifier: String,
        note: String,
        eventType: Geotification.EventType
    ) {
        controller.dismiss(animated: true, completion: nil)
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance) // new added 9
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        add(geotification: geotification, mapView: mapView, view: view)
        startMonitoring(geotification: geotification, view: view, locationManager: locationManager)     // new added 10
        saveAllGeotifications()
    }
    
    // new added 6
    func region(with geotification: Geotification) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: geotification.coordinate,
                                      radius: geotification.radius,
                                      identifier: geotification.identifier)
        // 2
        region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    // new added 7
    func startMonitoring(geotification: Geotification, view: UIViewController, locationManager: CLLocationManager) {
        // 1
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            view.showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
          Your geotification is saved but will only be activated once you grant
          Geotify permission to access the device location.
          """
            view.showAlert(withTitle:"Warning", message: message)
        }
        // 3
        let fenceRegion = region(with: geotification)
        // 4
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    // new added 8
    func stopMonitoring(geotification: Geotification, locationManager: CLLocationManager) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
}
