//
//  AddGeoficationViewController.swift
//  Geonome
//
//  Created by Chris Stev on 02/12/20.
//  Copyright © 2020 Setel. All rights reserved.
//

import UIKit
import MapKit

protocol AddGeotificationDelegate {
    func addGeotificationDelegate(
      _ controller: AddGeoficationViewController,
      didAddCoordinate coordinate: CLLocationCoordinate2D,
      radius: Double,
      identifier: String,
      note: String,
      eventType: Geotification.EventType
    )
}

class AddGeoficationViewController: UITableViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var zoomButton: UIBarButtonItem!
    
    var delegate: AddGeotificationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [addButton, zoomButton]
        tableView.tableFooterView = UIView()
        addButton.isEnabled = false
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        addButton.isEnabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAdd(_ sender: AnyObject) {
        print("add tapped")
        let coordinate = mapView.centerCoordinate
        let radius = Double(radiusTextField.text!) ?? 0
        let identifier = NSUUID().uuidString
        let note = noteTextField.text
        let eventType: Geotification.EventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
        delegate?.addGeotificationDelegate(self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note!, eventType: eventType)
    }
    
    @IBAction func onZoomCurrentLocation(_ sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
    
}
