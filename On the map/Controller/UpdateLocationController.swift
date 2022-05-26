//
//  UpdateLocationController.swift
//  On the map
//
//  Created by Eyvind on 24/5/22.
//

import Foundation
import UIKit

class UpdateLocationController : UIViewController, UITextFieldDelegate {
 
    
    @IBOutlet weak var tfLocation: UITextField!
    
    private var isNewPost = true
    
    static func launch(_ isNew: Bool, _ originVC: UIViewController){
        let controller = originVC.storyboard?.instantiateViewController(withIdentifier: "UpdateLocationController") as! UpdateLocationController
        controller.isNewPost = isNew
        originVC.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        tfLocation.text = TestData.location
        if !isNewPost {
            tfLocation.text = RestClient.Auth.lastLocationString
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func onCancel(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        let location = tfLocation.text
        guard let location = location else {
            showSingleAlert("Location is needed")
            return
        }

        if location.isEmpty {
            showSingleAlert("Location is needed")
            return
        } else {
            SubmitLocationController.launch(location: location, isNewPost, self)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
