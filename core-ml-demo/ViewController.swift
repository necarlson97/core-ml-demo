//
//  ViewController.swift
//  core-ml-demo
//
//  Created by Brooke Sullivan on 11/28/18.
//  Copyright © 2018 NC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var picLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Placeholder text while we run the ML
        picLabel.text = "Looking at image..."
        
        // Get image from storyboard
        let img = picView.image!
        // Scale image to a more digestible size
        let scaledImage = img.scaleImage(224, 224)!
        // Get pixel buffer from scaled image
        let imgBuffer = scaledImage.getBuffer()
    
        // Create and run the ML Model on our image buffer
        let model = MobileNet()
        let result = try? model.prediction(image: imgBuffer!)
        
        // Set the image label as the class label predicted by the ML
        picLabel.text = result?.classLabel
        
    }
    
    

}

extension UIImage {
    func scaleImage(_ newWidth: CGFloat, _ newHeight: CGFloat) -> UIImage? {
        let scaledSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func getBuffer() -> CVPixelBuffer? {
        let image = self
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

