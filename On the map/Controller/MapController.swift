//
//  MapController.swift
//  On the map
//
//  Created by Eyvind on 20/5/22.
//

import Foundation
import UIKit
import MapKit

class MapController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var vLoader: UIActivityIndicatorView!
    @IBOutlet weak var vPinLocation: UIBarButtonItem!
    @IBOutlet weak var btnReload: UIBarButtonItem!
    
    private var loadTask: URLSessionDataTask? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    @IBAction func loadData() {
        print("loadData")
        showLoader(true)
        loadTask?.cancel()
        loadTask = RestClient.loadStudentLocations { students, error in
            self.showLoader(false)
            StudentModel.students = students
            self.loadMarks()
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        showLoader(true)
        RestClient.logout { success, error in
            self.dismiss(animated: true)
        }
    }

    @IBAction func attemptUpdateLocation() {
        showLoader(true)
        self.onUpdateLocation { self.showLoader(false) }
    }
    
    func showLoader(_ isLoading: Bool){
        vLoader.isHidden = !isLoading
        vPinLocation.isEnabled = !isLoading
        btnReload.isEnabled = !isLoading

        if isLoading {
            vLoader.startAnimating()
        } else {
            vLoader.stopAnimating()
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!)
            }
        }
    }
    
    func loadMarks() {
        var annotations = [MKPointAnnotation]()
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        for student in StudentModel.students {
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate

            if first == "" {
                annotation.title = "\(lat.formatted()) \(long.formatted())"
            } else {
                annotation.title = "\(first) \(last)"
            }
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
}
