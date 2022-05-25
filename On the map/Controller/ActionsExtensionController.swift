//
//  ControllerActionsExtension.swift
//  On the map
//
//  Created by Eyvind on 25/5/22.
//

import Foundation
import UIKit

extension UIViewController {
    
    func onUpdateLocation(callback: @escaping () -> Void) {
        _ = RestClient.checkStudentLocation(uniqueKey: RestClient.Auth.accountKey) { isRegistered, error in
            callback()
            if isRegistered {
                let alertVC = UIAlertController(title: "", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { UIAlertAction in
                    self.overwriteLocation()
                }))
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alertVC, animated: true)
            } else {
                self.overwriteLocation()
            }
        }
    }
    
    func overwriteLocation(){
        UpdateLocationController.launch(self)
    }
    
    func showSingleAlert(_ message: String, _ handler: @escaping ((_ action: UIAlertAction) -> Void) = {action in }) {
        let alertVC = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        present(alertVC, animated: true)
    }
}
