//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Kyle Wilson on 2020-02-11.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var onTheMapNavItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
        loadStudentLocations() //right when view is about to appear we need to load locations just for extra security, instead of loading them in viewDidLoad()
    }
    
    //MARK: LOAD STUDENT LOCATIONS
    
    func loadStudentLocations() {
        mapView.removeAnnotations(mapView.annotations) //remove pins so we can reupdate them
        UdacityClient.getStudentLocations { (result, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                DispatchQueue.main.async {
                    self.errorAlert("Could not load student data", "There was an error in trying to retrieve other students data", "OK", .default)
                }
            }
            
            guard result != nil else {
                DispatchQueue.main.async {
                    self.errorAlert("Could not load student data", "There was an error in trying to retrieve other students data", "OK", .default)
                }
                return
            }
            
            StudentLocations.lastFetched = result!
            var mapPin = [MKPointAnnotation]()
            
            for location in result! {
                let longitude = CLLocationDegrees(location.longitude!)
                let latitude = CLLocationDegrees(location.latitude!)
                let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let mediaURL = location.mediaURL
                let firstName = location.firstName
                let lastName = location.lastName
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                mapPin.append(annotation)
                
            }
            DispatchQueue.main.async {
                self.mapView.addAnnotations(mapPin)
            }
        }
    }
    
    //MARK: ERROR ALERT FUNCTION
    
    func errorAlert(_ title: String?, _ message: String?, _ action: String?, _ style: UIAlertAction.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: action, style: style, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: PIN FUNCTIONS

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let open = view.annotation?.subtitle {
                guard let url = URL(string: open!) else { return }
                openInSafari(url: url)
            }
        }
    }
    
    func openInSafari(url: URL) {
        if url.absoluteString.contains("https://") {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Invalid URL", message: "Could not load URL", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
