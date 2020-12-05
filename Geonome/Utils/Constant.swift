//
//  Constant.swift
//  Geonome
//
//  Created by Chris Stev on 03/12/20.
//  Copyright © 2020 Setel. All rights reserved.
//

import Foundation

struct PreferencesKeys {
  static let savedItems = "savedItems"
}

struct Constant {
    static let errorTitle = "Error"
    static let addGeotificationSegue = "addGeotification"
    static let annotationIdentifier = "myGeotification"
    static let locationNotAuthMessages = """
    Your geotification is saved but will only be activated once you grant
    Geotify permission to access the device location.
    """
    static let monitoringNotAvailableMessages = "Geofencing is not supported on this device!"
    static let statusOutside = "Outside Area"
    static let statusUnknown = "Unknown"
}
