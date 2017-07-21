//
//  StrobeLight.swift
//  StrobeLight
//
//  Created by Developer on 02/03/17.
//  Copyright © 2017 Developer. All rights reserved.
//

import UIKit

class StrobeLight: UIViewController {
    
    // MARK: - IBOutlet Properties & Variables
    var strobeDevice = StrobeLights()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        strobeDevice.type = .normal
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - IBAction Methods
extension StrobeLight {
    
    @IBAction func actionMethod(sender: UIButton) {
        switch sender.tag {
        case 0:
            strobeDevice.isStrobeLightOn = false
            do {
                _ = try strobeDevice.startStrobeLight()
            } catch let error as SrobeError {
                switch error {
                case .targetSimulator:
                    print(error.description)
                default:
                    print(error.description)
                }
            } catch {
                print(error)
            }
        case 1:
            strobeDevice.isStrobeLightOn = true
            do {
                _ = try strobeDevice.startStrobeLight()
            } catch let error as SrobeError {
                switch error {
                case .targetSimulator:
                    print(error.description)
                default:
                    print(error.description)
                }
            } catch {
                print(error)
            }
        case 2:
          strobeDevice.stopTourch()
        default: break
        }
    }
    
}
