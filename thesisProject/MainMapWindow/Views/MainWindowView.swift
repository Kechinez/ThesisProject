//
//  MapView.swift
//  thesisProject
//
//  Created by Nikita Kechinov on 21.03.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import UIKit
import GoogleMaps

class MainWindowView: UIView {
    var mapView: GMSMapView?
    
    
    init(viewController: MapViewController, frame: CGRect) {
        super.init(frame: frame)
        
        if let navigationVC = viewController.navigationController {
            let addPlaceButton = UIBarButtonItem(title: "New spot", style: .plain, target: viewController, action: #selector(MapViewController.addNewPlace))
            navigationVC.navigationItem.rightBarButtonItem = addPlaceButton
        }
        
        mapView = GMSMapView(frame: CGRect(x: 0, y: 60, width: frame.size.width, height: frame.size.height - 80))
        let camera = GMSCameraPosition.camera(withTarget: viewController.userCurrentLocation!, zoom: 16.0)//(withLatitude: 61.690201, longitude: 27.272632, zoom: 14.0)
        mapView!.camera = camera
        mapView!.delegate = viewController
        self.addSubview(mapView!)
        mapView!.isMyLocationEnabled = true
        
        
        let searchTextField = UITextField(frame: CGRect(x: 10, y: 10, width: frame.size.width - 20, height: 40))
        searchTextField.borderStyle = .roundedRect
        searchTextField.placeholder = "find place"
        searchTextField.font = UIFont.systemFont(ofSize: 18)
        self.addSubview(searchTextField)
        searchTextField.delegate = viewController
        
        self.backgroundColor = #colorLiteral(red: 0.3647058824, green: 0.6549019608, blue: 0.04705882353, alpha: 1)
    
        
        let signoutBarButton = UIBarButtonItem(title: "Sign out", style: .plain, target: viewController, action: #selector(MapViewController.signoutMethod))
        viewController.navigationItem.leftBarButtonItem = signoutBarButton
        
        let addNewPlaceBarButton = UIBarButtonItem(title: "New spot", style: .plain, target: viewController, action: #selector(MapViewController.addNewPlace))
        viewController.navigationItem.rightBarButtonItem = addNewPlaceBarButton
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
