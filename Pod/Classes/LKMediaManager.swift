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
    func stringByAppendingPathComponent(path: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(path)
    }
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
}


public class LKMediaManager: NSObject {
    
    public enum MediaType: String {
        case BIN = "application/octet-stream"
        case JPEG = "image/jpeg"
        case PNG = "image/png"
        case GIF = "image/gif"
        case MOV = "video/quicktime"
    }
    
    public static let sharedManager = LKMediaManager()
    
    override init() {
        super.init()
        self.setup()
    }
    
    // MARK: Properties
    public var mediaPath:String {
        get {
            let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            return dir.stringByAppendingPathComponent("LKMediaManager")
        }
    }
   
    
    // MARK: - API (Media)
    public func restoreData(filename:String) -> NSData? {
        let filePath = mediaPath.stringByAppendingPathComponent(filename)
        if let data = NSData(contentsOfFile:filePath) {
            return data
        }
        return nil
    }
    
    public func removeMedia(filename:String) -> Bool {
        let filePath = mediaPath.stringByAppendingPathComponent(filename)
        return removeFile(filePath)
    }
    
    public func mediaSize(filename:String) -> UInt64 {
        let filePath = mediaPath.stringByAppendingPathComponent(filename)
        var error: NSError?
        do {
            let attr:NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
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

    public func mimeType(filename:String) -> String {
        var mimeType = MediaType.BIN
        let ext = filename.pathExtension.lowercaseString
        
        if ["jpeg", "jpg"].containsObject(ext) {
            mimeType = .JPEG
        } else if ["png"].containsObject(ext) {
            mimeType = .PNG
        } else if ["gif"].containsObject(ext) {
            mimeType = .GIF
        } else if ["mov"].containsObject(ext) {
            mimeType = .MOV
        }
        
        return mimeType.rawValue
    }
    
    // MARK: -  API (Media/Image)
    public func restoreImage(filename:String) -> UIImage? {
        if let data = restoreData(filename) {
            return UIImage(data:data)
        }
        return nil
    }
    
    public func saveImage(image:UIImage, metadata:Dictionary<String,String>, quality:CGFloat, filename:String) -> Bool {
        let filePath = mediaPath.stringByAppendingPathComponent(filename)
        let data = convertImageToData(image, metadata: metadata, quality: quality)
        if data.writeToFile(filePath, atomically: true) {
            return true
        } else {
            NSLog("failed to save: %@", filename)
            return false
        }
    }
    
    // MARK: -  API (Media/Video)
    public func saveVideo(url:NSURL, filename:String) -> Bool {
        let filePath = mediaPath.stringByAppendingPathComponent(filename)
        let videoPath = url.path
        let fm = NSFileManager.defaultManager()
        
        if fm.fileExistsAtPath(filePath) {
            var error: NSError?
            do {
                try fm.removeItemAtPath(filePath)
            } catch let error1 as NSError {
                error = error1
                NSLog("[ERROR] failed to remove the video file (%@) : %@", filePath, error!.description)
            }
        }
        
        var error: NSError?
        do {
            try fm.copyItemAtPath(videoPath!, toPath: filePath)
            return true
        } catch let error1 as NSError {
            error = error1
            NSLog("[ERROR] failed to save the video file (%@) : %@", filePath, error!.description);
            return false
        }
    }
    
    public func videoThumbnail(url:NSURL, width:CGFloat) -> UIImage? {
        // gen thumbnail
        // http://stackoverflow.com/questions/5719135/uiimagepickercontroller-thumbnail-of-video-which-is-pick-up-from-library

        let asset = AVURLAsset(URL: url, options: nil)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, 600)
        var error: NSError?
        var actualTime:CMTime = CMTimeMake(0, 0)
        
        let imageRef: CGImage!
        do {
            imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime:&actualTime)
        } catch let error1 as NSError {
            error = error1
            imageRef = nil
        }
        
        if error != nil {
            NSLog("[ERROR] failed to create a thumbnail image (%@) : %@", url, error!.description)
            return nil
        } else {
            let image = UIImage(CGImage: imageRef)
            return adjustOrientationImage(image, toWidth:width)
        }
    }
    
    // MARK: - Privates
    func createDirectory(path:String) -> Bool {
        var result = true
        let fm = NSFileManager.defaultManager()
        if !fm.fileExistsAtPath(path) {
            var error: NSError?
            do {
                try fm.createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
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
    
    func removeFile(filePath:String) -> Bool {
        var result = true
        let fm = NSFileManager.defaultManager()
        if fm.fileExistsAtPath(filePath) {
            var error: NSError?
            do {
                try fm.removeItemAtPath(filePath)
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
        createDirectory(mediaPath)
    }
    
    func convertImageToData(image:UIImage, metadata:Dictionary<String,String>, quality:CGFloat) -> NSData {
        let imageData = NSMutableData()
        let dest = CGImageDestinationCreateWithData(imageData as CFMutableDataRef, kUTTypeJPEG, 1, nil)

        CGImageDestinationSetProperties(dest!, [kCGImageDestinationLossyCompressionQuality as String:quality])
    
        CGImageDestinationAddImage(dest!, image.CGImage!, metadata as CFDictionaryRef);
        CGImageDestinationFinalize(dest!);
        
        return imageData
    }
    
    func adjustOrientationImage(image:UIImage, toWidth:CGFloat) -> UIImage {

        let imageRef = image.CGImage
        let width = CGFloat(CGImageGetWidth(imageRef))
        let height = CGFloat(CGImageGetHeight(imageRef))
        
        var bounds = CGRectMake(0, 0, width, height)
        
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
        case .Up:              // EXIF: 1
            transform = CGAffineTransformIdentity
            break;
            
        case .UpMirrored:      // EXIF: 2
            transform = CGAffineTransformMakeTranslation(width, 0.0)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
            break
            
        case .Down:            // EXIF: 3
            transform = CGAffineTransformMakeTranslation(width, height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
            
        case .DownMirrored:    // EXIF: 4
            transform = CGAffineTransformMakeTranslation(0.0, height)
            transform = CGAffineTransformScale(transform, 1.0, -1.0)
            break
            
        case .LeftMirrored:    // EXIF: 5
            tmp = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = tmp
            transform = CGAffineTransformMakeTranslation(height, width)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0)
            break
            
        case .Left:            // EXIF: 6
            tmp = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = tmp
            transform = CGAffineTransformMakeTranslation(0, width)
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0)
            break
            
        case .RightMirrored:   // EXIF: 7
            tmp = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = tmp
            transform = CGAffineTransformMakeScale(-1.0, 1.0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0)
            break
            
        case .Right:           // EXIF: 8
            tmp = bounds.size.height;
            bounds.size.height = bounds.size.width
            bounds.size.width = tmp
            transform = CGAffineTransformMakeTranslation(height, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0)
            break
            
        }

        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        
        if image.imageOrientation == .Right || image.imageOrientation == .Left {
                CGContextScaleCTM(context, -scale, scale)
                CGContextTranslateCTM(context, -height, 0)
        } else {
            CGContextScaleCTM(context, scale, -scale)
            CGContextTranslateCTM(context, 0, -height)
        }
        
        CGContextConcatCTM(context, transform)
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage
    }

}
