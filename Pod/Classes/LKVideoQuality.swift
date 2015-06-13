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
    
    public static var titles:[String] {
        let bundle = NSBundle(path:NSBundle(forClass: LKVideoQuality.self).pathForResource("LKMediaManager", ofType: "bundle")!)!
        return list.map { (q:Quality) -> String in
            return NSLocalizedString(q.localizedStringKey, bundle:bundle, comment: "")
        }
    }
    
    public static func index(qualityType:UIImagePickerControllerQualityType) -> Int? {
        for (index, quality) in enumerate(list) {
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
}
