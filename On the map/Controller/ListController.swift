//
//  ListController.swift
//  On the map
//
//  Created by Eyvind on 19/5/22.
//

import Foundation
import UIKit

class ListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var vLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var vPinLocation: UIBarButtonItem!
    
    @IBOutlet weak var btnReload: UIBarButtonItem!
    
    private var loadTask: URLSessionDataTask? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        tableView.reloadData()
    }
    
    @IBAction func loadData() {
        showLoader(true)
        loadTask?.cancel()
        loadTask = RestClient.loadStudentLocations { students, error in
            self.showLoader(false)
            if error != nil {
                let alertVC = UIAlertController(title: "", message: "Can't load student locations", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alertVC.addAction(UIAlertAction(title: "Try again", style: .default, handler: { UIAlertAction in
                    self.loadData()
                }))
                self.present(alertVC, animated: true)
            } else {
                StudentModel.students = students
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func attemptUpdateLocation() {
        showLoader(true)
        self.onUpdateLocation{ self.showLoader(false) }
    }
    
    @IBAction func logout(_ sender: Any) {
        showLoader(true)
        RestClient.logout { success, error in
            self.dismiss(animated: true)
        }
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
}


extension ListController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentViewCell")!
        
        let student = StudentModel.students[indexPath.row]
        
        if student.firstName != "" {
            cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        } else {
            cell.textLabel?.text = "\(student.latitude), \(student.longitude)"
        }
        cell.imageView?.image = UIImage(systemName: "mappin")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        let toOpen = StudentModel.students[indexPath.row].mediaURL
        if toOpen != "" {
            app.open(URL(string: toOpen)!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
