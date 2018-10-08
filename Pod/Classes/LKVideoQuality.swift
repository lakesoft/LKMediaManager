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
        let type: UIImagePickerController.QualityType
        let localizedStringKey: String
        
        init(type: UIImagePickerController.QualityType,localizedStringKey: String) {
            self.type = type
            self.localizedStringKey = localizedStringKey
        }
    }
    
    public static let list = [
        Quality(type:UIImagePickerController.QualityType.typeHigh, localizedStringKey:"VideoQuality.High"),
        Quality(type:UIImagePickerController.QualityType.typeMedium, localizedStringKey:"VideoQuality.Medium"),
        Quality(type:UIImagePickerController.QualityType.typeLow, localizedStringKey:"VideoQuality.Low"),
        Quality(type:UIImagePickerController.QualityType.type640x480, localizedStringKey:"VideoQuality.640x480"),
        Quality(type:UIImagePickerController.QualityType.typeIFrame960x540, localizedStringKey:"VideoQuality.IFrame960x540"),
        Quality(type:UIImagePickerController.QualityType.typeIFrame1280x720, localizedStringKey:"VideoQuality.IFrame1280x720"),
    ]
    
    static let bundle = Bundle(path:Bundle(for: LKVideoQuality.self).path(forResource: "LKMediaManager", ofType: "bundle")!)!

    public static let DefaultQualityType = UIImagePickerController.QualityType.type640x480
    
    public static var title:String {
        return NSLocalizedString("VideoQuality.title", bundle:bundle, comment: "")
    }
    
    public static var typeNames:[String] {
        return list.map { (q:Quality) -> String in
            return NSLocalizedString(q.localizedStringKey, bundle:self.bundle, comment: "")
        }
    }
    
    public static func typeName(_ index:Int) -> String? {
        if index < list.count {
            return NSLocalizedString(list[index].localizedStringKey, bundle:bundle, comment: "")
        }
        return nil
    }

    public static func index(_ qualityType:UIImagePickerController.QualityType) -> Int? {
        for (index, quality) in list.enumerated() {
            if quality.type == qualityType {
                return index
            }
        }
        return nil
    }
    
    public static func qualityType(_ index:Int) -> UIImagePickerController.QualityType? {
        if index < list.count {
            return list[index].type
        }
        return nil
    }
    
    public static let userDefaultsKey = "LKVideoQuality.qualityType"
    public static func defaultQualityType() -> UIImagePickerController.QualityType {
        if let value = UserDefaults.standard.object(forKey: userDefaultsKey) as?Int {
            if let qualityType = UIImagePickerController.QualityType(rawValue: value) {
                return qualityType
            }
        }
        return DefaultQualityType
    }
    public static func saveDefaultQualityType(_ qualityType:UIImagePickerController.QualityType) {
        UserDefaults.standard.set(qualityType.rawValue, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }

    public static func defaultIndex() -> Int {
        if let index = index(defaultQualityType()) {
            return index
        }
        if let index = index(DefaultQualityType) {
            return index
        }
        return 0
    }
    
    public static func defaultTypeName() -> String {
        if let typeName = typeName(defaultIndex()) {
            return typeName
        }
        return ""
    }
    
    public static func saveIndex(_ index:Int) {
        if let qualityType = qualityType(index) {
            saveDefaultQualityType(qualityType)
        }
    }
}
