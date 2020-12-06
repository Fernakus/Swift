//
//  ReminderInfoVC.swift
//  ReminderApplication
//
//  Created by Matt Ferlaino on 2020-12-05.
//

/*
 * Imports
 */
import UIKit
import RealmSwift

/*
 * Classes
 */
class ReminderInfoVC: UIViewController, UITextFieldDelegate {
    // Outlets
    @IBOutlet var reminderTitle: UILabel!
    @IBOutlet var reminderBody: UILabel!
    @IBOutlet var reminderDate: UILabel!
    
    // Variables
    private var reminderObj: Reminder?
    private let realm = try! Realm()
    public var completeionHandler: ((String, String, Date) -> Void)?
    public var deletionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Delete Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteButton))
        
        reminderTitle.text = "Reminder Title"
        reminderDate.text = "Reminder Date"
        reminderBody.text = "Reminder Body"
    }
    
    // Delete Reminders From Realm
    @objc private func deleteButton() {
        // Unwrap
        guard let reminderObj = self.reminderObj else {
            return
        }

        // Delete From Realm
        realm.beginWrite()
        realm.delete(reminderObj)
        try! realm.commitWrite()
        deletionHandler?()
        
        navigationController?.popToRootViewController(animated: true)
    }
}
