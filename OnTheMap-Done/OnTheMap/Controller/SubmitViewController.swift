//
//  SubmitViewController.swift
//  OnTheMap
//
//  Created by Kyle Wilson on 2020-02-11.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import MapKit

class SubmitViewController: UIViewController {
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var locationRetrieved: String!
    var urlRetrieved: String!
    
    var location: String = ""
    var coordinate: CLLocationCoordinate2D?
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var student: StudentInformation?
    
    var objectIdHolder: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.layer.cornerRadius = 5
        linkTextField.delegate = self
        print(locationRetrieved!)
        search() //geocodes location that was entered in previous view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: GEOCODE LOCATION
    
    func search() {
        
        guard let location = locationRetrieved else { //checks if the location was retrieved
            self.errorAlert("No Location", "Location was not found or entered. Go back to the previous view.")
            return
        }
        
        let ai = self.startAnActivityIndicator()
        
        CLGeocoder().geocodeAddressString(location) { (placemark, error) in
            
            ai.stopAnimating()
            
            guard error == nil else {
                self.errorAlert("No Location", "Location was not found or entered. Go back to the previous view.")
                return
            }
            
            self.location = location //assign the location to the global location variable so we can access it
            self.coordinate = placemark!.first!.location!.coordinate
            self.pin(coordinate: self.coordinate!)
            self.latitude = (placemark?.first?.location?.coordinate.latitude)!
            self.longitude = (placemark?.first?.location?.coordinate.longitude)!
        }
    }
    
    //MARK: GET USER INFO
    
    func getUserInfo() {
        UdacityClient.getUser() { (success, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.errorAlert("Error", "Error Getting User Info")
                }
            }
            
            if success {
                print("success")
                
                DispatchQueue.main.async {
                    self.student = StudentInformation(uniqueKey: UdacityClient.accountKey, firstName: UdacityClient.firstName, lastName: UdacityClient.lastName, latitude: self.latitude, longitude: self.longitude, mapString: self.location, mediaURL: self.urlRetrieved)
                    print(self.student?.firstName ?? "No First Name")
                    print(self.student?.lastName ?? "No First Name")
                    print(self.student?.latitude ?? 0)
                    print(self.student?.longitude ?? 0)
                    print(self.student?.mapString ?? "No Location")
                    print(self.student?.mediaURL ?? "No URL")
                    print(self.student?.uniqueKey ?? "No Key")
                    
                    
                    if UdacityClient.objectId == "" { //check if user has created a pin already and checks objectId
                        self.postLocation() //post
                    } else { //otherwise
                        self.objectIdHolder = UdacityClient.objectId //assign the objectId to a new variable to check if its working
                        self.updateLocation() //update the location
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    self.errorAlert("Error", "Error Getting User Info")
                }
            }
        }
    }
    
    //MARK: POST LOCATION
    
    func postLocation() {
        UdacityClient.postStudentLocation(student: student!) { (success, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                self.errorAlert("Could not post student location", "There was an error trying to post a pin")
                return
            }
            
            if success {
                print("post success")
                print(self.student?.firstName ?? "")
                print(self.student?.lastName ?? "")
                print(self.student?.latitude ?? 0)
                print(self.student?.longitude ?? 0)
                DispatchQueue.main.async {
                    let vc = self.navigationController?.viewControllers[1]
                    self.navigationController?.popToViewController(vc!, animated: true)
                }
            } else {
                self.errorAlert("Could not post student location", "There was an error trying to post a pin")
            }
        }
    }
    
    //MARK: UPDATE LOCATION
    
    func updateLocation() {
        UdacityClient.updateUserLocation(student: student!) { (success, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                self.errorAlert("Could not update student Location", "There was an error trying to update a pin")
                return
            }
            
            if success {
                print("update success")
                print("Object ID: \(self.objectIdHolder)")
                print("New Latitude: \(self.student?.latitude ?? 0)")
                print("New Longitude: \(self.student?.longitude ?? 0)")
                DispatchQueue.main.async {
                    let vc = self.navigationController?.viewControllers[1]
                    self.navigationController?.popToViewController(vc!, animated: true)
                }
            } else {
                self.errorAlert("Could not update student Location", "There was an error trying to update a pin")
            }
        }
    }
    
    //MARK: ADDING NEW PIN
    
    func pin(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = location
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: true)
            self.mapView.regionThatFits(region)
        }
    }
    
    //MARK: CANCEL
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: SUBMIT
    
    @IBAction func submitTapped(_ sender: Any) {
        urlRetrieved = linkTextField.text
        getUserInfo()
    }
    
    //MARK: ERROR ALERT FUNCTION
    
    func errorAlert(_ title: String?, _ message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(actionOK)
        self.present(alert, animated: true, completion: nil)
    }
}

extension SubmitViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension SubmitViewController {
    func startAnActivityIndicator() -> UIActivityIndicatorView {
        let ai = UIActivityIndicatorView(style: .large)
        self.view.addSubview(ai)
        self.view.bringSubviewToFront(ai)
        ai.center = self.view.center
        ai.hidesWhenStopped = true
        ai.startAnimating()
        return ai
    }
}
