//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Kyle Wilson on 2020-02-11.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: NEW PIN TAPPED
    
    @IBAction func newPinButtonTapped(_ sender: Any) {
        if UdacityClient.createdAt == "" { //check if the pin has been created yet
            let locationVC = self.storyboard?.instantiateViewController(identifier: "AddLocationViewController") as! AddLocationViewController
            self.navigationController?.pushViewController(locationVC, animated: true)
        } else {
            let alert = UIAlertController(title: "Overwrite Location?", message: "Would you like to overwrite your pin's location?", preferredStyle: .alert)
            let actionContinue = UIAlertAction(title: "Continue", style: .default) { (action) in
                let locationVC = self.storyboard?.instantiateViewController(identifier: "AddLocationViewController") as! AddLocationViewController
                self.navigationController?.pushViewController(locationVC, animated: true)
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(actionContinue)
            alert.addAction(actionCancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: REFRESH TAPPED
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        let mapVC = self.viewControllers![0] as! MapViewController
        mapVC.loadStudentLocations()
        let listVC = self.viewControllers![1] as! ListsTableViewController
        listVC.loadStudentLocations()
        listVC.tableView.reloadData()
    }
    
    //MARK: LOGOUT FUNCTION
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        UdacityClient.logout { (success, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.errorAlert("Could not log out", "Error logging out.", "Dismiss", .cancel)
                }
            }
            
            if success {
                DispatchQueue.main.async {
                    print("logged out")
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorAlert("Could not log out", "Error logging out.", "Dismiss", .cancel)
                }
            }
        }
    }
    
    //MARK: ERROR ALERT
    
    func errorAlert(_ title: String?, _ message: String?, _ action: String?, _ style: UIAlertAction.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: action, style: style, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

