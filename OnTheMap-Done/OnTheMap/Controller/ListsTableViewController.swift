//
//  ListsTableViewController.swift
//  OnTheMap
//
//  Created by Kyle Wilson on 2020-02-11.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import MapKit

class ListsTableViewController: UITableViewController {
    
    var result = [StudentLocation]()
    @IBOutlet var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        result = StudentLocations.lastFetched
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    
    //MARK: LOAD STUDENTS
    
    func loadStudentLocations() {
        UdacityClient.getStudentLocations { (result, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                self.errorAlert("Could not load student data", "There was an error in trying to retrieve other students data", "OK", .default)
            }
            
            guard result != nil else {
                self.errorAlert("Could not load student data", "There was an error in trying to retrieve other students data", "OK", .default)
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
                annotation.title = "\(String(describing: firstName)) \(String(describing: lastName))"
                annotation.subtitle = mediaURL
                mapPin.append(annotation)
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
    
    //MARK: TABLEVIEW DELEGATES AND DATA
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DataViewCell
        let student = self.result[indexPath.row]
        cell.name.text = "\(student.firstName) \(student.lastName)"
        cell.url.text = student.mediaURL
        if let url = URL(string: cell.url.text!) {
            if url.absoluteString.contains("https://") {
                cell.imageView?.image = UIImage(named: "icon")
            } else {
                cell.imageView?.image = nil
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.result[indexPath.row].mediaURL
        if let url = URL(string: url!) {
            UIApplication.shared.open(url)
        }
    }

}
