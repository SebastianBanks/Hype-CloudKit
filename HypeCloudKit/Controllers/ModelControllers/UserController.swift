//
//  UserController.swift
//  HypeCloudKit
//
//  Created by Sebastian Banks on 4/13/22.
//

import Foundation
import CloudKit
import UIKit

class UserController {
    // Shared Instance
    static let shared = UserController()
    // Source of Truth
    var currentUser: User?
    // Database constant
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func createUser(with username: String, bio: String, profilePhoto: UIImage?, completion: @escaping (Bool) -> Void) {
        // Fetching the CKUserIdentity recordID, creating a reference to use with our user object
        fetchAppleUserReference { (refernce) in
            // Ensure we get the reference back
            guard let refernce = refernce else { completion(false) ; return }
            // Init a newUser with the reference
            let newUser = User(username: username, bio: bio, profilePhoto: profilePhoto, appleUserReference: refernce)
            // Create the CKRecord to be saved from the newUser
            let record = CKRecord(user: newUser)
            // Call the .save method to save the newly created CKRecord
            self.publicDB.save(record) { record, error in
                // Handle the error
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                // Unwrap the record that was saved, ensure we can init a user from that record
                guard let record = record,
                      let savedUser = User(ckRecord: record)
                else { completion(false) ; return }
                // Set the current user and complete true
                self.currentUser = savedUser
                print("Created user: \(record.recordID.recordName) successfully")
                completion(true)
            }
        }
    }
    
    func fetchUser(completion: @escaping (Bool) -> Void) {
        
        // Step 4 - Fetch and unwrap the appleUserRef to use in our predicate
        fetchAppleUserReference { (reference) in
            guard let reference = reference else { completion(false) ; return }
            // Step 3 - Define the predicate
            // Takes an array of arguments and passes them into the format, the first item in the array is being passed into the %K which is the key, the secound item in the array is being passed into the %@ which is the value.
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserReferenceKey, reference])
            // Step 2 - Init the query
            let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
            // Step 1 - perform query
            self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                
                guard let record = records?.first,
                      let foundUser = User(ckRecord: record)
                else { completion(false) ; return }
                
                self.currentUser = foundUser
                print("Fetch User: \(record.recordID.recordName) successfully")
                completion(true)

            }

        }
        
        
    }
    
    private func fetchAppleUserReference(completion: @escaping (CKRecord.Reference?) -> Void) {
        CKContainer.default().fetchUserRecordID { recordID, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            
            guard let recordID = recordID else { completion(nil) ; return }
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            completion(reference)
        }
    }
    
    func update(_ user: User) {
        
    }
    
    func delete(_ user: User) {
        
    }
}
