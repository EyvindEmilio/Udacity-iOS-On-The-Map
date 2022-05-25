//
//  SubmitLocationController.swift
//  On the map
//
//  Created by Eyvind on 24/5/22.
//

import Foundation
import UIKit
import MapKit

class SubmitLocationController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tfLinkToShare: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var vLoader: UIActivityIndicatorView!
    var locationStr: String = ""
    var coordinate: CLLocationCoordinate2D? = nil
    
    static func launch(location:String, _ originVC: UIViewController){
        let controller = originVC.storyboard?.instantiateViewController(withIdentifier: "SubmitLocationController") as! SubmitLocationController
        
        controller.locationStr = location
        originVC.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.leftBarButtonItems?.append(UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: nil))
        
        search()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func search() {
        showLoader(true)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationStr
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: { [self] response, _ in
           showLoader(false)
           guard let response = response else {
               showSingleAlert("No Location found, please enter another location",{action in
                   self.navigationController?.popViewController(animated: true)
               })
               return
           }
           print(response.mapItems)
            
            if response.mapItems.count == 0 {
                showSingleAlert("No Location found, please enter another location",{action in
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                btnSubmit.isEnabled = true
                self.addPin(response.mapItems[0].placemark)
            }
        })
    }
    
    func showLoader(_ isLoading: Bool){
        btnSubmit.isEnabled = !isLoading
        tfLinkToShare.isEnabled = !isLoading
        vLoader.isHidden = !isLoading

        if isLoading {
            vLoader.startAnimating()
        } else{
            vLoader.stopAnimating()
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func addPin(_ placeMark: MKPlacemark){
        self.coordinate = CLLocationCoordinate2D(latitude: placeMark.coordinate.latitude, longitude: placeMark.coordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        annotation.subtitle = locationStr
        
        var region = MKCoordinateRegion(center: coordinate!, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        region.center = coordinate!
        mapView.setRegion(region, animated: true)
        
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func submit(_ sender: Any) {
        let link = tfLinkToShare.text
        guard let link = link else {
            showSingleAlert("Link to Share is needed")
            return
        }
        
        guard let coordinate = self.coordinate else {
            showSingleAlert("Coordinate is invalid")
            return
        }
        
        if link.isEmpty {
            showSingleAlert("Link to Share is needed")
            return
        }
        
        showLoader(true)
        
        RestClient.postLocation(uniqueKey: RestClient.Auth.accountKey, firstName: "Emi", lastName: "Emi", mapString: locationStr, mediaURL: link, latitude: coordinate.latitude, longitude: coordinate.longitude) { isSuccess, error in
            self.showLoader(false)
            if !isSuccess {
                self.showSingleAlert("Can't post location")
                return
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
