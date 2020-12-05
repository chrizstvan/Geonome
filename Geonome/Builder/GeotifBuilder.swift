//
//  GeotifBuilder.swift
//  Geonome
//
//  Created by Chris Stev on 05/12/20.
//  Copyright © 2020 Setel. All rights reserved.
//

import UIKit

final class GeotifBuilder {
    func build() -> UIViewController {
        let view = GeotificationViewController.instantiate()
        let interactor = GeotifInteractor()
        let presenter = GeotifPresenter()
        
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        view.locationManager = interactor.locationManager
        
        return view
    }
}
