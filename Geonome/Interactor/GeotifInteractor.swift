//
//  GeotifInteractor.swift
//  Geonome
//
//  Created by Chris Stev on 05/12/20.
//  Copyright © 2020 Setel. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol GeotifInteractorProtocol {
    func loadAllGeotification(mapView: MKMapView)
    func add(_ geotification: GeotificationViewModel, mapView: MKMapView)
    func remove(_ geotification: GeotificationViewModel, mapView: MKMapView)
    func saveAllGeotifications()
}

final class GeotifInteractor: GeotifInteractorProtocol {
    var geotifications = [GeotificationViewModel]()
    var presenter: GeotifPresenterProtocol!
    var locationManager = CLLocationManager()
    var isMaxGeotif: Bool {
        // Core Location restricts the number of registered geofences to a maximum of 20 per app
        geotifications.count >= 20
    }
    
    // loadAllGeotification handle load data at firstime apps launch
    func loadAllGeotification(mapView: MKMapView) {
        let allGeotif = GeotificationViewModel.allGeotifications()
        allGeotif.forEach { add($0, mapView: mapView) }
    }
    
    // add handle adding geofencing area to the map
    func add(_ geotification: GeotificationViewModel, mapView: MKMapView) {
        geotifications.append(geotification)
        presenter.addAnnotationAndRadiusOverlay(
            geotif: geotification,
            mapView: mapView,
            isMaxGeotifications: isMaxGeotif
        )
        
        startMonitoring(geotification: geotification)
    }
    
    // remove handle removing geofencing area from map
    func remove(_ geotification: GeotificationViewModel, mapView: MKMapView) {
        guard let index = geotifications.firstIndex(of: geotification) else {
            return
        }
        
        geotifications.remove(at: index)
        presenter.removeAnnotationAndRadiusOverlay(
            geotif: geotification,
            mapView: mapView,
            isMaxGeotifications: isMaxGeotif
        )
        
        stopMonitoring(geotification: geotification)
    }
    
    // saveAllGeotifications handle saving all geotification to user default
    func saveAllGeotifications() {
        let geotifModels = geotifications.map { geotifVM in
            Geotification(
                coordinate: geotifVM.coordinate,
                radius: geotifVM.radius,
                identifier: geotifVM.identifier,
                note: geotifVM.note
            )
        }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(geotifModels)
            UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems)
        } catch {
            print("error encoding geotifications")
        }
    }
}

extension GeotifInteractor {
    // region define location boundaries based on geotification
    private func region(with geotification: GeotificationViewModel) -> CLCircularRegion {
        let region = CLCircularRegion(
            center: geotification.coordinate,
            radius: geotification.radius,
            identifier: geotification.identifier
        )
        
        return region
    }
    
    // startMonitoring handle start of monitoring for area that user has define it before
    private func startMonitoring(geotification: GeotificationViewModel) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            presenter.presentAlert(
                title: Constant.errorTitle,
                messages: Constant.monitoringNotAvailableMessages
            )
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = Constant.locationNotAuthMessages
            presenter.presentAlert(title: "Warning", messages: message)
        }
        
        let fenceRegion = region(with: geotification)
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    // stopMonitoring handle start of monitoring for area that user has define it before
    func stopMonitoring(geotification: GeotificationViewModel) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
}
