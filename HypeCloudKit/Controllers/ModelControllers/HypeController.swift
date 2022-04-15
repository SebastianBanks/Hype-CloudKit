//
//  HypeController.swift
//  HypeCloudKit
//
//  Created by Sebastian Banks on 4/11/22.
//

import UIKit
import CloudKit

class HypeController {
    
    static let shared = HypeController()
    
    var hypes: [Hype] = []
    // constant to access our public cloud database
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // Mark: - Crud
    // Create
    func saveHype(with text: String, photo: UIImage?, completion: @escaping (Bool) -> Void) {
        guard let currentUser = UserController.shared.currentUser else { completion(false) ; return }
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .none)
        // Init a hype object
        let newHype = Hype(body: text, hypePhoto: photo, userReference: reference)
        // Package that hype object to a CKRecord
        let hypeRecord = CKRecord(hype: newHype)
        // Saving the hypeRecord to the cloud
        publicDB.save(hypeRecord) { record, error in
            if let error = error {
                // Handling the error if there is one
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            // Unwrapping the record that was saved
            guard let record = record,
                  // Ensuring that we can init a Hype from that record
                  let savedHype = Hype(ckRecord: record)
            else { completion(false) ; return }
            // Add to SoT array
            print("Saved Hype successfully")
            self.hypes.insert(savedHype, at: 0)
            completion(true)

        }
    }
    // Fetch
    func fetchHype(completion: @escaping (Bool) -> Void) {
        // Step 3 - Init the requisite predicate for the query
        let predicate = NSPredicate(value: true)
        // Step 2 - Init the requisite query for the .perform method
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        // Step 1 - Perform a query on the database
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            // Handle the error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            // Unwrap the records
            guard let records = records else { completion(false) ; return }
            print("Fetched all hypes")
            // Compact map through the found records to return non-nil hype objects
            let fetchedHypes = records.compactMap { Hype(ckRecord: $0) }
            // Set source of truth
            self.hypes = fetchedHypes
            completion(true)
        }
    }
    
    func update(_ hype: Hype, completion: @escaping (Bool) -> Void) {
        guard hype.userReference?.recordID == UserController.shared.currentUser?.recordID else { completion(false) ; return }
        let recordToUpdate = CKRecord(hype: hype)
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            guard let record = records?.first else { completion(false) ; return}
            print("Update \(record.recordID.recordName) successfully in CloudKit")
            completion(true)
        }
        publicDB.add(operation)
    }
    
    func delete(_ hype: Hype, completion: @escaping (Bool) -> Void) {
        guard hype.userReference?.recordID == UserController.shared.currentUser?.recordID else { completion(false) ; return }
        let operation = CKModifyRecordsOperation(recordIDsToDelete: [hype.recordID])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, recordIDs, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            guard let recordIDs = recordIDs else { completion(false) ; return }
            print("\(recordIDs) were removed successfully")
            completion(true)
        }
        publicDB.add(operation)
    }
    
    func subscribeToRemoteNotifications(completion: @escaping (Error?) -> Void) {
        
        // Step 3 - Declare the requistie predicate
        let predicate = NSPredicate(value: true)
        // Step 2 - Declare the subscription
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        // Step 4 - Setting the subscription properties
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Choo Choo"
        notificationInfo.alertBody = "Can't stop the Hype train!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        
        // Step 1 - Call the save(subscription) function on the database
        publicDB.save(subscription) { _, error in
            if let error = error {
                completion(error)
            }
            completion(nil)
            
        }
    }
}
