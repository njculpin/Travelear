//
//  CheckHeadphones.swift
//  Travelear
//
//  Created by Nick Culpin on 3/2/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import Foundation
import AVFoundation

class CheckHeadphones {
    
    class func isConnected() -> Bool {
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        for output in outputs {
            if output.portType == AVAudioSession.Port.bluetoothA2DP ||
                output.portType == AVAudioSession.Port.bluetoothHFP ||
                output.portType == AVAudioSession.Port.bluetoothLE ||
                output.portType == AVAudioSession.Port.headphones {
                       return true
                   }
               }
               return false
    }
}
