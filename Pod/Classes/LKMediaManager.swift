//
//  LKMediaManager.swift
//  LKMediaManager
//
//  Created by Hiroshi Hashiguchi on 2015/05/19.
//  Copyright (c) 2015年 Hiroshi Hashiguchi. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation
import MobileCoreServices
import ImageIO

extension String {
    func stringByAppendingPathComponent(_ path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
}


open class LKMediaManager: NSObject {
    
    public enum MediaType: String {
        case BIN = "application/octet-stream"
        case JPEG = "image/jpeg"
        case PNG = "image/png"
        case GIF = "image/gif"
        case MOV = "video/quicktime"
    }
    
    open static let sharedManager = LKMediaManager()
    
    override init() {
        super.init()
        self.setup()
    }
    
    // MARK: Properties
    open var mediaPath:String {
        get {
            let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return dir.stringByAppendingPathComponent("LKMediaManager")
        }
    }
   
    
    // MARK: - API (Media)
    open func restoreData(_ filename:String) -> Data? {
        let filePath = mediaPath.stringByAppendingPathComponent(filename)
        if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
            return data
        }
        return nil
    }
    
    open func removeMedia(_ filename:String) -> Bool {
        let filePath = mediaPath.stringByAppendingPathComponent(filename)
        return removeFile(filePath)
    }
    
    open func mediaSize(_ filename:String) -> UInt64 {
        let filePath = mediaPath.stringByAppendingPathComponent(filename)
        var error: NSError?
        do {
            let attr:NSDictionary = try FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            if error != nil {
                NSLog("[ERROR] failed to get size (%@) : %@", filePath, error!.description)
                return 0
            }
            return UInt64(attr.fileSize())
        } catch let error1 as NSError {
            error = error1
        }
        return 0
    }

    open func mimeType(_ filename:String) -> String {
        var mimeType = MediaType.BIN
        let ext = filename.pathExtension.lowercased()
        
        if ["jpeg", "jpg"].contains(ext) {
            mimeType = .JPEG
        } else if ["png"].contains(ext) {
            mimeType = .PNG
        } else if ["gif"].contains(ext) {
            mimeType = .GIF
        } else if ["mov"].contains(ext) {
            mimeType = .MOV
        }
        
        return mimeType.rawValue
    }
    
    // MARK: -  API (Media/Image)
    open func restoreImage(_ filename:String) -> UIImage? {
        if let data = restoreData(filename) {
            return UIImage(data:data)
        }
        return nil
    }
    
    open func saveImage(_ image:UIImage, metadata:Dictionary<String,String>, quality:CGFloat, filename:String) -> Bool {
        let filePath = mediaPath.stringByAppendingPathComponent(filename)
        let data = convertImageToData(image, metadata: metadata, quality: quality)
        if (try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])) != nil {
            return true
        } else {
            NSLog("failed to save: %@", filename)
            return false
        }
    }
    
    // MARK: -  API (Media/Video)
    open func saveVideo(_ url:URL, filename:String) -> Bool {
        let filePath = mediaPath.stringByAppendingPathComponent(filename)
        let videoPath = url.path
        let fm = FileManager.default
        
        if fm.fileExists(atPath: filePath) {
            var error: NSError?
            do {
                try fm.removeItem(atPath: filePath)
            } catch let error1 as NSError {
                error = error1
                NSLog("[ERROR] failed to remove the video file (%@) : %@", filePath, error!.description)
            }
        }
        
        var error: NSError?
        do {
            try fm.copyItem(atPath: videoPath, toPath: filePath)
            return true
        } catch let error1 as NSError {
            error = error1
            NSLog("[ERROR] failed to save the video file (%@) : %@", filePath, error!.description);
            return false
        }
    }
    
    open func videoThumbnail(_ url:URL, width:CGFloat, sec: Float64 = 0.0) -> UIImage? {
        // gen thumbnail
        // http://stackoverflow.com/questions/5719135/uiimagepickercontroller-thumbnail-of-video-which-is-pick-up-from-library

        let asset = AVURLAsset(url: url, options: nil)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(sec, Int32(NSEC_PER_SEC))
        var error: NSError?
        var actualTime:CMTime = CMTimeMake(0, 0)
        
        let imageRef: CGImage!
        do {
            imageRef = try imageGenerator.copyCGImage(at: time, actualTime:&actualTime)
        } catch let error1 as NSError {
            error = error1
            imageRef = nil
        }
        
        if error != nil {
            print("[ERROR] failed to create a thumbnail image (%@) : %@", url, error!.description)
            return nil
        } else {
            let image = UIImage(cgImage: imageRef)
            return adjustOrientationImage(image, toWidth:width)
        }
    }
    
    // MARK: - Privates
    func createDirectory(_ path:String) -> Bool {
        var result = true
        let fm = FileManager.default
        if !fm.fileExists(atPath: path) {
            var error: NSError?
            do {
                try fm.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
                result = true
            } catch let error1 as NSError {
                error = error1
                result = false
            }
            if !result {
                NSLog("[ERROR] %@", error!.description);
            }
        }
        return result;
    }
    
    func removeFile(_ filePath:String) -> Bool {
        var result = true
        let fm = FileManager.default
        if fm.fileExists(atPath: filePath) {
            var error: NSError?
            do {
                try fm.removeItem(atPath: filePath)
                result = true
            } catch let error1 as NSError {
                error = error1
                result = false
            }
            if !result {
                NSLog("[ERROR] %@", error!.description);
            }
        }
        return result
    }
    
    func setup() {
        _ = createDirectory(mediaPath)
    }
    
    func convertImageToData(_ image:UIImage, metadata:Dictionary<String,String>, quality:CGFloat) -> Data {
        let imageData = NSMutableData()
        let dest = CGImageDestinationCreateWithData(imageData as CFMutableData, kUTTypeJPEG, 1, nil)

        let properties = [kCGImageDestinationLossyCompressionQuality as String:quality]
        CGImageDestinationSetProperties(dest!, properties as CFDictionary)
    
        CGImageDestinationAddImage(dest!, image.cgImage!, metadata as CFDictionary);
        CGImageDestinationFinalize(dest!);
        
        return imageData as Data
    }
    
    func adjustOrientationImage(_ image:UIImage, toWidth:CGFloat) -> UIImage {

        let imageRef = image.cgImage
        let width = CGFloat((imageRef?.width)!)
        let height = CGFloat((imageRef?.height)!)
        
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        if toWidth > 0.0 {
            if bounds.size.width > toWidth || bounds.size.height > toWidth {
                let ratio = width / height
                
                if ratio > 1.0 {
                    bounds.size.width = toWidth
                    bounds.size.height = toWidth / ratio
                } else {
                    bounds.size.width = toWidth * ratio
                    bounds.size.height = toWidth
                }
            }
        }
        
        let scale = bounds.size.width / width
        var transform:CGAffineTransform
        var tmp:CGFloat
        
        switch (image.imageOrientation) {
        case .up:              // EXIF: 1
            transform = CGAffineTransform.identity
            break;
            
        case .upMirrored:      // EXIF: 2
            transform = CGAffineTransform(translationX: width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            break
            
        case .down:            // EXIF: 3
            transform = CGAffineTransform(translationX: width, y: height)
            transform = transform.rotated(by: CGFloat(M_PI))
            break
            
        case .downMirrored:    // EXIF: 4
            transform = CGAffineTransform(translationX: 0.0, y: height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
            break
            
        case .leftMirrored:    // EXIF: 5
            tmp = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = tmp
            transform = CGAffineTransform(translationX: height, y: width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: 3.0 * CGFloat(M_PI) / 2.0)
            break
            
        case .left:            // EXIF: 6
            tmp = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = tmp
            transform = CGAffineTransform(translationX: 0, y: width)
            transform = transform.rotated(by: 3.0 * CGFloat(M_PI) / 2.0)
            break
            
        case .rightMirrored:   // EXIF: 7
            tmp = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = tmp
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(M_PI) / 2.0)
            break
            
        case .right:           // EXIF: 8
            tmp = bounds.size.height;
            bounds.size.height = bounds.size.width
            bounds.size.width = tmp
            transform = CGAffineTransform(translationX: height, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI) / 2.0)
            break
            
        }

        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        
        if image.imageOrientation == .right || image.imageOrientation == .left {
                context?.scaleBy(x: -scale, y: scale)
                context?.translateBy(x: -height, y: 0)
        } else {
            context?.scaleBy(x: scale, y: -scale)
            context?.translateBy(x: 0, y: -height)
        }
        
        context?.concatenate(transform)
        
        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height));
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage!
    }

}
