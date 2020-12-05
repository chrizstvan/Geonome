//
//  GeotificationViewController.swift
//  Geonome
//
//  Created by Chris Stev on 02/12/20.
//  Copyright © 2020 Setel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SystemConfiguration.CaptiveNetwork

protocol GeotifViewProtocol: class {
    func setGeofence(mapView: MKMapView, isMaxGeotification: Bool)
    func removeGeofence(mapView: MKMapView, isMaxGeotification: Bool)
    func showNeededAlert(_ view: UIViewController)
}

class GeotificationViewController: UIViewController, Storyboarded {
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var interactor: GeotifInteractorProtocol!
    var geotifVM = [GeotificationViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        determineMyCurrentLocation()
        interactor.loadAllGeotification(mapView: mapView)
    }
    
    func getWiFiName() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    // determineMyCurrentLocation set user location on the map
    private func determineMyCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
      
      mapView.showsUserLocation = true
      mapView.userTrackingMode = .follow
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.addGeotificationSegue {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddGeoficationViewController
            vc.delegate = self
        }
    }
    
    @IBAction func zoomCurrentLocation(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
}

//MARK:- View Delegate
extension GeotificationViewController: GeotifViewProtocol, AddGeotificationDelegate {
    // addGeotificationDelegate handle callbacks when geofication added at add geotification page
    func addGeotificationDelegate(_ geotification: GeotificationViewModel, controller: AddGeoficationViewController) {
        controller.dismiss(animated: true, completion: nil)
        let clampedRadius = min(geotification.radius, locationManager.maximumRegionMonitoringDistance)
        let geotif = GeotificationViewModel(
            geotif: Geotification(
                coordinate: geotification.coordinate,
                radius: clampedRadius,
                identifier: geotification.identifier,
                note: geotification.note
            )
        )
        
        interactor.add(geotif, mapView: mapView)
        interactor.saveAllGeotifications()
    }
    
    // setGeofence handle callbacks when geofance area is finish to set on the map
    func setGeofence(mapView: MKMapView, isMaxGeotification: Bool) {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem?.isEnabled = !isMaxGeotification
        }
    }
    
    // removeGeofence handle callbacks when geofance area is removing from the map
    func removeGeofence(mapView: MKMapView, isMaxGeotification: Bool) {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem?.isEnabled = !isMaxGeotification
        }
    }
    
    // showNeededAlert showing related messages to user
    func showNeededAlert(_ view: UIViewController) {
        
    }
}

//MARK:- Location Delegate
extension GeotificationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedWhenInUse || status == .authorizedAlways)
        mapView.userTrackingMode = .follow
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
}

// MARK: - MapView Delegate
extension GeotificationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is GeotificationViewModel {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constant.annotationIdentifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constant.annotationIdentifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }


    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // showing geotification circle
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        let geotification = view.annotation as! GeotificationViewModel
        interactor.remove(geotification, mapView: mapView)
        interactor.saveAllGeotifications()
    }
}
