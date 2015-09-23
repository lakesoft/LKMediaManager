//
//  LKVideoQuality.swift
//  Pods
//
//  Created by Hiroshi Hashiguchi on 2015/06/13.
//
//

import UIKit

public class LKVideoQuality: NSObject {
       
    public struct Quality {
        let type: UIImagePickerControllerQualityType
        let localizedStringKey: String
        
        init(type: UIImagePickerControllerQualityType,localizedStringKey: String) {
            self.type = type
            self.localizedStringKey = localizedStringKey
        }
    }
    
    public static let list = [
        Quality(type:UIImagePickerControllerQualityType.TypeHigh, localizedStringKey:"VideoQuality.High"),
        Quality(type:UIImagePickerControllerQualityType.TypeMedium, localizedStringKey:"VideoQuality.Medium"),
        Quality(type:UIImagePickerControllerQualityType.TypeLow, localizedStringKey:"VideoQuality.Low"),
        Quality(type:UIImagePickerControllerQualityType.Type640x480, localizedStringKey:"VideoQuality.640x480"),
        Quality(type:UIImagePickerControllerQualityType.TypeIFrame960x540, localizedStringKey:"VideoQuality.IFrame960x540"),
        Quality(type:UIImagePickerControllerQualityType.TypeIFrame1280x720, localizedStringKey:"VideoQuality.IFrame1280x720"),
    ]
    
    static let bundle = NSBundle(path:NSBundle(forClass: LKVideoQuality.self).pathForResource("LKMediaManager", ofType: "bundle")!)!

    public static let DefaultQualityType = UIImagePickerControllerQualityType.Type640x480
    
    public static var title:String {
        return NSLocalizedString("VideoQuality.title", bundle:bundle, comment: "")
    }
    
    public static var typeNames:[String] {
        return list.map { (q:Quality) -> String in
            return NSLocalizedString(q.localizedStringKey, bundle:self.bundle, comment: "")
        }
    }
    
    public static func typeName(index:Int) -> String? {
        if index < list.count {
            return NSLocalizedString(list[index].localizedStringKey, bundle:bundle, comment: "")
        }
        return nil
    }

    public static func index(qualityType:UIImagePickerControllerQualityType) -> Int? {
        for (index, quality) in list.enumerate() {
            if quality.type == qualityType {
                return index
            }
        }
        return nil
    }
    
    public static func qualityType(index:Int) -> UIImagePickerControllerQualityType? {
        if index < list.count {
            return list[index].type
        }
        return nil
    }
    
    public static let userDefaultsKey = "LKVideoQuality.qualityType"
    public static func defaultQualityType() -> UIImagePickerControllerQualityType {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey(userDefaultsKey) as?Int {
            if let qualityType = UIImagePickerControllerQualityType(rawValue: value) {
                return qualityType
            }
        }
        return DefaultQualityType
    }
    public static func saveDefaultQualityType(qualityType:UIImagePickerControllerQualityType) {
        NSUserDefaults.standardUserDefaults().setObject(qualityType.rawValue, forKey: userDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
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
    
    public static func saveIndex(index:Int) {
        if let qualityType = qualityType(index) {
            saveDefaultQualityType(qualityType)
        }
    }
}
