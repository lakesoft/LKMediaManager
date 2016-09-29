//
//  LKVideoQuality.swift
//  Pods
//
//  Created by Hiroshi Hashiguchi on 2015/06/13.
//
//

import UIKit

open class LKVideoQuality: NSObject {
       
    public struct Quality {
        let type: UIImagePickerControllerQualityType
        let localizedStringKey: String
        
        init(type: UIImagePickerControllerQualityType,localizedStringKey: String) {
            self.type = type
            self.localizedStringKey = localizedStringKey
        }
    }
    
    open static let list = [
        Quality(type:UIImagePickerControllerQualityType.typeHigh, localizedStringKey:"VideoQuality.High"),
        Quality(type:UIImagePickerControllerQualityType.typeMedium, localizedStringKey:"VideoQuality.Medium"),
        Quality(type:UIImagePickerControllerQualityType.typeLow, localizedStringKey:"VideoQuality.Low"),
        Quality(type:UIImagePickerControllerQualityType.type640x480, localizedStringKey:"VideoQuality.640x480"),
        Quality(type:UIImagePickerControllerQualityType.typeIFrame960x540, localizedStringKey:"VideoQuality.IFrame960x540"),
        Quality(type:UIImagePickerControllerQualityType.typeIFrame1280x720, localizedStringKey:"VideoQuality.IFrame1280x720"),
    ]
    
    static let bundle = Bundle(path:Bundle(for: LKVideoQuality.self).path(forResource: "LKMediaManager", ofType: "bundle")!)!

    open static let DefaultQualityType = UIImagePickerControllerQualityType.type640x480
    
    open static var title:String {
        return NSLocalizedString("VideoQuality.title", bundle:bundle, comment: "")
    }
    
    open static var typeNames:[String] {
        return list.map { (q:Quality) -> String in
            return NSLocalizedString(q.localizedStringKey, bundle:self.bundle, comment: "")
        }
    }
    
    open static func typeName(_ index:Int) -> String? {
        if index < list.count {
            return NSLocalizedString(list[index].localizedStringKey, bundle:bundle, comment: "")
        }
        return nil
    }

    open static func index(_ qualityType:UIImagePickerControllerQualityType) -> Int? {
        for (index, quality) in list.enumerated() {
            if quality.type == qualityType {
                return index
            }
        }
        return nil
    }
    
    open static func qualityType(_ index:Int) -> UIImagePickerControllerQualityType? {
        if index < list.count {
            return list[index].type
        }
        return nil
    }
    
    open static let userDefaultsKey = "LKVideoQuality.qualityType"
    open static func defaultQualityType() -> UIImagePickerControllerQualityType {
        if let value = UserDefaults.standard.object(forKey: userDefaultsKey) as?Int {
            if let qualityType = UIImagePickerControllerQualityType(rawValue: value) {
                return qualityType
            }
        }
        return DefaultQualityType
    }
    open static func saveDefaultQualityType(_ qualityType:UIImagePickerControllerQualityType) {
        UserDefaults.standard.set(qualityType.rawValue, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }

    open static func defaultIndex() -> Int {
        if let index = index(defaultQualityType()) {
            return index
        }
        if let index = index(DefaultQualityType) {
            return index
        }
        return 0
    }
    
    open static func defaultTypeName() -> String {
        if let typeName = typeName(defaultIndex()) {
            return typeName
        }
        return ""
    }
    
    open static func saveIndex(_ index:Int) {
        if let qualityType = qualityType(index) {
            saveDefaultQualityType(qualityType)
        }
    }
}
