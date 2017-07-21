//
//  Strobe.swift
//  Pods
//
//  Created by tecHind on 30/05/17.
//
//

import UIKit
import AVFoundation


/*!
 @enum Stobe Light Type
 @abstract
 Set the type of light to make the light effect as a strobe light and default light type is normal.
 */
enum Type {
    
    // Enum Cases/Values
    case slow
    case normal
    case fast
    
    // Initialization method
    init() {
        self = .normal
    }
    
    // Return Value Type: Double
    var rawValue: Double {
        switch self {
        case .slow: return 0.7
        case .normal: return 0.5
        case .fast: return 0.3
        }
    }
}

/*!
 @enum Error
 @abstract
 Return error when an error occur, default error type is unknow.
 */
enum SrobeError: Error {
    
    // Enum Values/Cases:
    case targetSimulator
    case toruchNotAvailable
    case unknown
    
    // Initialization method
    init() {
        self = .unknown
    }
    
    // Return Value Type: String
    var description: String {
        switch self {
        case .targetSimulator: return "Application is running on Simulator"
        case .toruchNotAvailable: return "Tourch not aviable on this device to show strobe light. Please run this app on that device who have tourch"
        case .unknown: return "Error unspecified"
        }
    }
}

//-----------------------------------

/*!
 @class Strobe Light
 @abstract
 A Strobe class will turn on the device torach as a torch and strobe light.
 */

class StrobeLights: NSObject {
    
    // MARK: - Properties & Variables
    fileprivate var defaultDevice: AVCaptureDevice!
    fileprivate var timer = Timer()
    
    var isStrobeLightOn: Bool?
    var isLightOn: Bool?
    var type = Type()
    
    //MARK: Shared Instance
    static let sharedInstance : StrobeLights = {
        let instance = StrobeLights()
        return instance
    }()
    
    // Default Initialization Method
    override init() {
        super.init()
        
        isStrobeLightOn = false
        isLightOn = false
        
        if #available(iOS 10.0, *) {
            guard let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .unspecified)
                else {
                    return
            }
            defaultDevice = device
        } else {
            // Fallback on earlier versions
            defaultDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        }
    }
    
    // Deinitialization Method
    deinit {
        timer.invalidate()
    }
}

// MARK: - Custom Methods
extension StrobeLights {
    
    /*
     @method startStrobeLight:error:
     */
    
    func startStrobeLight() throws -> String {
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            throw SrobeError.targetSimulator
        #else
            if defaultDevice.hasTorch {
                if isStrobeLightOn! {
                    if timer.isValid {
                        if timer.isValid { timer.invalidate(); stopTourch(); isLightOn = false }
                    } else {
                        isLightOn = true
                        timer = Timer.scheduledTimer(timeInterval: type.rawValue, target: self, selector: #selector(self.toggleTorch), userInfo: nil, repeats: true)
                    }
                } else {
                    if timer.isValid { timer.invalidate(); stopTourch() }
                    _ = toggleTorch()
                    isLightOn = true
                }
            } else {
                throw SrobeError.toruchNotAvailable
            }
        #endif
        throw SrobeError.unknown
    }
    
    /*
     @method toogleTorch
     @abstract
     Set device torch on and off and return bool value
     @description
     This method will change the device torch mode on or off. If device torch mode is on the method will return ture and if torch mode is off then method will return false.
     */
    
    @objc fileprivate func toggleTorch() -> Bool {
        
        // Check if the default device has torch
        if  defaultDevice.hasTorch {
            // Lock your default device for configuration
            do {
                // unlock your device when done
                defer {
                    defaultDevice.unlockForConfiguration()
                }
                try defaultDevice.lockForConfiguration()
                
                // Toggles the torchMode
                defaultDevice.torchMode = defaultDevice.torchMode == .on ? .off : .on
                
                // Sets the torch intensity to 100%, if torchMode is ON
                if defaultDevice.torchMode == .on {
                    do {
                        try defaultDevice.setTorchModeOnWithLevel(1)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return defaultDevice.torchMode == .on
    }
    
    /*
     @method stopTourch:error:
     @abstract
     Stop the tourch mode of Device Light
     @discussion
     This method sets the tourch mode off if device light is on.
     It invalidate the timer if timer is valid
     It also change the isLightOn variable value from true to false
     */
    func stopTourch() {
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
        #else
            // Invalidate timer, If timer is valid
            if timer.isValid { timer.invalidate() }
            
            if defaultDevice.hasTorch {
                do {
                    // Unlock your device when done & change strobe light status from true to false
                    defer {
                        isLightOn = false
                        defaultDevice.unlockForConfiguration()
                    }
                    try defaultDevice.lockForConfiguration()
                    defaultDevice.torchMode = .off
                } catch {
                    print(error.localizedDescription)
                }
            } else {
            }
        #endif
    }
}

