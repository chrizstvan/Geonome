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
        _ geotification: GeotificationViewModel,
        controller: AddGeoficationViewController
    )
}

class AddGeoficationViewController: UITableViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var zoomButton: UIBarButtonItem!
    @IBOutlet weak var areaTextField: UITextField!
    
    var delegate: AddGeotificationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        areaTextField.delegate = self
        tableView.tableFooterView = UIView()
        mapView.showsUserLocation = true
        addButton.isEnabled = false
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        addButton.isEnabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAdd(_ sender: AnyObject) {
        delegate?.addGeotificationDelegate(
            GeotificationViewModel(
                geotif: Geotification(
                    coordinate: mapView.centerCoordinate,
                    radius:  Double(radiusTextField.text!) ?? 0,
                    identifier: NSUUID().uuidString,
                    note: noteTextField.text ?? ""
                )
            ), controller: self
        )
    }
    
    @IBAction func onZoomCurrentLocation(_ sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
}

extension AddGeoficationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addButton.isEnabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
        view.endEditing(true)
        return addButton.isEnabled
    }
}
