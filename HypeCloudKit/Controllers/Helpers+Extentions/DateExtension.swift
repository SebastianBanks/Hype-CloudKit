//
//  DateExtension.swift
//  HypeCloudKit
//
//  Created by Sebastian Banks on 4/11/22.
//

import Foundation

extension Date {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
