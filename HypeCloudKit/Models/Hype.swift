//
//  Hype.swift
//  HypeCloudKit
//
//  Created by Sebastian Banks on 4/11/22.
//

import Foundation
import CloudKit
import UIKit

struct HypeStrings {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let userReferenceKey = "userReference"
    fileprivate static let photoAssetKey = "photoAsset"
}

class Hype {
    
    var body: String
    var timestamp: Date
    var hypePhoto: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoData: Data?
    
    var recordID: CKRecord.ID
    var userReference: CKRecord.Reference?
    var photoAsset: CKAsset? {
        get {
            let tempDiretory = NSTemporaryDirectory()
            let tempDeirectoryURL = URL(fileURLWithPath: tempDiretory)
            let fileURL = tempDeirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print(error)
            }
            
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(body: String, timestamp: Date = Date(), hypePhoto: UIImage? = nil, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference?) {
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
        self.userReference = userReference
        self.hypePhoto = hypePhoto
    }
}

extension Hype {
    
    // Taking a CKRcord and pulling out the values found to initialize out Hype model
    
    convenience  init?(ckRecord: CKRecord) {
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
              let timestamp = ckRecord[HypeStrings.timestampKey] as? Date
        else { return nil }
        
        let userReference = ckRecord[HypeStrings.userReferenceKey] as? CKRecord.Reference
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[HypeStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could not transform asset to data")
            }
        }
        
        self.init(body: body, timestamp: timestamp, hypePhoto: foundPhoto, recordID: ckRecord.recordID, userReference: userReference)
    }
}

extension Hype: Equatable {
    static func == (lhs: Hype, rhs: Hype) -> Bool {
        return lhs.recordID == rhs.recordID
    }
    
    
}

extension CKRecord {
    
    // Packaging our Hype model properties to be stored in a CKRecord and saved to the cloud
    
    convenience init(hype: Hype) {
        self.init(recordType: HypeStrings.recordTypeKey, recordID: hype.recordID)
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp,
            HypeStrings.userReferenceKey : hype.userReference,
            HypeStrings.photoAssetKey : hype.photoAsset
        ])
//        self.setValue(hype.body, forKey: HypeStrings.bodyKey)
//        self.setValue(hype.timestamp, forKey: HypeStrings.timestampKey)
    }
}


