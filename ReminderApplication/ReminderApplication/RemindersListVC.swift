 //
//  RemindersListVC.swift
//  ReminderApplication
//
//  Created by Matt Ferlaino on 2020-12-03.
//

/*
 * Imports
 */
import UIKit
import RealmSwift
import UserNotifications

/*
 * Structures
 */
struct ReminderStruct {
     let title: String
     let body: String
     let date: Date
     let identifier: String
}

/*
 * Classes
 */
class Reminder: Object {
    @objc dynamic var reminderTitle: String = ""
    @objc dynamic var reminderBody: String = ""
    @objc dynamic var reminderID: String = ""
    @objc dynamic var reminderDate: Date = Date()
}

class RemindersListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Outlets
    @IBOutlet var table: UITableView!
    
    // Variables
    private var remindersList = [Reminder]()
    private var reminderStructsList = [ReminderStruct]()
    private let realm = try! Realm()
    
    // Load main View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask user for permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound], completionHandler: {success, error in})
        
        table.delegate = self
        table.dataSource = self
    }

    // Add a new reminder button
    @IBAction func addButton() {
        // Create new VC instance
        guard let vc = storyboard?.instantiateViewController(identifier: "AddReminderVC") as? AddReminderVC else {
            return
        }
        
        // Adding to VC Instance
        vc.title = "New Reminder"
        vc.navigationItem.largeTitleDisplayMode = .never
        
        vc.finish = {title, body, date in
            DispatchQueue.main.async{
                // Switch View
                self.navigationController?.popToRootViewController(animated: true)
                
                // Create Reminder Structure
                let reminderStruct = ReminderStruct(title: title, body: body, date: date, identifier: "id_\(title)")
                self.reminderStructsList.append(reminderStruct)
                
                // Create Reminder Object
                let reminder = Reminder()
                reminder.reminderTitle = title
                reminder.reminderBody = body
                reminder.reminderDate = date
                reminder.reminderID = "id_\(title)"
                self.remindersList.append(reminder)

                // Refresh Realm & Table
                self.refresh()
                
                // Create Notification
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = title
                notificationContent.body = body
                notificationContent.sound = .default
                
                // Create Notification Trigger, Request & add to Notification Center
                let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date), repeats: false)
                
                let request = UNNotificationRequest(identifier: "requestID", content: notificationContent, trigger: notificationTrigger)
            
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil {
                        print("User declined allowing reminder access.")
                    }
                })
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Refresh
    func refresh() {
        remindersList = realm.objects(Reminder.self).map({$0})
        self.table.reloadData()
    }
    
    // ReminderList VC Cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Format Date
       let date = reminderStructsList[indexPath.row].date
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "MMM. d yyyy @ h:mm a"
       
       // Format Cell
       let aCell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
       aCell.detailTextLabel?.text = dateFormatter.string(from: date)
       aCell.textLabel?.text = reminderStructsList[indexPath.row].title
         
       return aCell
    }
    
    // Grab Cell
    func tableView(_ tableView: UITableView, didSelectRowAt index: IndexPath) {
        tableView.deselectRow(at: index, animated: true)
        
        // Adding to VC Instance
        guard let vc = storyboard?.instantiateViewController(identifier: "reminderInfoVC") as? ReminderInfoVC else {
            return
        }
        
        // Switch View
        vc.title = "Reminder Information"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completeionHandler = {title, body, date in
            DispatchQueue.main.async{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Size
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderStructsList.count
    }
    
    // Count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func addition(_ first: Int, by: Int) -> Int {
        return 1
    }
}
