//
//  AudioPowerVisualizerView.swift
//  AudioPlayer
//
//  Created by Nitin on 08/06/20.
//  Copyright © 2020 Nitin. All rights reserved.
//

import UIKit
import AVFoundation

enum AnimationTypes {
    case Rotate
    case Scale
    
}

class AudioPowerVisualizerView: UIView {
    
    // Configuration Settings
    private let updateInterval = 0.05
    private let animatioтDuration = 0.05
    private let colorAnimatioтDuration = 2.0
    
    private let maxPowerDelta: CGFloat = 30
    private let minScale: CGFloat = 0.9
    
    // Internal Timer to schedule updates from player
    private var timer: Timer?
    
    // Ingected Player to get power Metrics
    weak var player: AVAudioPlayer!
    
    //
    var requireColorAnimation : Bool = true
    
    var animationType : AnimationTypes!
    
    // Start scheduled player meters updates
    func start() {
        timer = Timer.scheduledTimer(timeInterval: updateInterval,
                                     target: self,
                                     selector: #selector(self.updateMeters),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    // Stop scheduled timer, reset self transfrom
    func stop() {
        guard timer != nil, timer!.isValid else {
            return
        }
        
        timer?.invalidate()
        timer = nil
        transform = .identity
    }
    
    // Animate self transform depends on player meters
    @objc private func updateMeters() {
        player.updateMeters()
        let power = averagePowerFromAllChannels()
        
        UIView.animate(withDuration: animatioтDuration, delay: 0, usingSpringWithDamping: power, initialSpringVelocity: 0.2, options: .curveEaseIn, animations: {
            self.animate(to: power)
        }, completion: {_ in
            if !self.player.isPlaying {
                self.stop()
            }
        })
        if ( requireColorAnimation && player.isPlaying ) {
            UIView.animate(withDuration: TimeInterval(power), animations: {
                let red = power
                let green = Float.random(in: 0...255)
                let blue = Float.random(in: 0...255)
                self.backgroundColor = UIColor(red: CGFloat(red / 255), green: CGFloat(green / 255), blue: CGFloat(blue / 255), alpha: 1)
            })
        }
    }
    
    // Calculate average power from all channels
    private func averagePowerFromAllChannels() -> CGFloat {
        var power: CGFloat = 0.0
        (0..<player.numberOfChannels).forEach { (index) in
            power = power + CGFloat(player.averagePower(forChannel: index))
        }
        return power / CGFloat(player.numberOfChannels)
    }
    
    // Apply scale transform depends on power
    private func animate(to power: CGFloat) {
        let powerDelta = (maxPowerDelta + power) * 2 / 100
        let compute: CGFloat = minScale + powerDelta
        var scale: CGFloat = CGFloat.maximum(compute, minScale)
        
        switch animationType {
        case .Scale:
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            break
        case .Rotate:
            let rotationAngle = 10 * scale
            self.transform = CGAffineTransform(rotationAngle: rotationAngle)
            break
        default:
            print("")
        }
        
    }
    
}
