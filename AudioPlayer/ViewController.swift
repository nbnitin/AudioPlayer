//
//  ViewController.swift
//  AudioPlayer
//
//  Created by Nitin on 05/06/20.
//  Copyright © 2020 Nitin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    //variable
    var audioPlayer = AVAudioPlayer()
    var isPaused = false
    var updater : CADisplayLink! = nil
    var filePath : String = ""
    var audioSession : AVAudioSession!
    var animateView : AudioPowerVisualizerView = AudioPowerVisualizerView()
    var animateViewRect : AudioPowerVisualizerView = AudioPowerVisualizerView()

    
   
    @IBOutlet weak var btnPlay: UIBarButtonItem!
    @IBOutlet weak var btnPause: UIBarButtonItem!
    @IBOutlet weak var btnRestart: UIBarButtonItem!
    
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var imgAlbum: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareSongAndSession()
        
        slider.minimumValue = 0.00
        
        //slider handling
        slider.addTarget(self, action: #selector(playAudioWithSlider), for: .valueChanged)
        // Add a gesture recognizer to the slider
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        slider.addGestureRecognizer(tapGestureRecognizer)
        slider.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopMusic), name: Notification.Name("stopMusic"), object: nil)
        
        audioPlayer.isMeteringEnabled = true

        
        setupAnimationView(frame: CGRect(x: self.view.frame.width / 2 - 50, y: self.view.frame.height / 4 - 100, width: 100, height: 100), v: animateView, isRequireColorAnimation: true, radius: 50,backgroundColor:.white,animationTypes: .Scale)
        
        setupAnimationView(frame: CGRect(x: self.view.frame.width / 2 - 100, y: lblTotalTime.frame.origin.y - 100, width: 100, height: 100), v: animateViewRect, isRequireColorAnimation: false, radius: 10,backgroundColor:.white,animationTypes: .Rotate)
        
    }
    
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {

        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)

        let positionOfSlider: CGPoint = slider.frame.origin
        let widthOfSlider: CGFloat = slider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)

        slider.setValue(Float(newValue), animated: true)
        playAudio(currentTime: TimeInterval(slider.value))

    }
    
    private func setupAnimationView(frame:CGRect,v:AudioPowerVisualizerView,isRequireColorAnimation:Bool,radius:CGFloat,backgroundColor:UIColor,animationTypes:AnimationTypes){
        v.frame = frame
        v.player = audioPlayer
        v.requireColorAnimation = isRequireColorAnimation
        v.layer.cornerRadius = radius
        v.backgroundColor = backgroundColor
        v.animationType = animationTypes
        v.start()
        self.view.addSubview(v)
    }
    
    //Mark:- stopping current music
    @objc func stopMusic(){
        audioPlayer.stop()
        animateViewRect.stop()
        animateView.stop()
    }
    
    //Mark:- creating session for audio player with given audio file url
    func prepareSongAndSession(){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: filePath))
            audioPlayer.prepareToPlay()
            setTotalTime()
            setCurrentTime()
            slider.value = 0
            

            audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setCategory(.soloAmbient)
            } catch let sessionError {
                print(sessionError)
            }
        } catch let audioPlayerSession {
            print(audioPlayerSession)
        }
        
        playAudio()
        
    }
    
    //Mark:- pauses audio
    @objc func pauseAudio(){
        if ( isPaused ) {
            isPaused = false
            audioPlayer.play()
        
        } else {
            audioPlayer.pause()
            isPaused = true
            
        }
        
        btnPause.isEnabled = false
        btnPlay.isEnabled = true
        animateView.stop()
        animateViewRect.stop()

    }
    
    //Mark:- change audio timming with change in slider
    @objc func playAudioWithSlider(){
        playAudio(currentTime: TimeInterval(slider.value))
    }
    
    //Makr:- plays audio
    @objc func playAudio(currentTime:TimeInterval = 0.0){
        audioPlayer.currentTime = currentTime
        audioPlayer.play()
        updater = CADisplayLink(target: self, selector: #selector(trackAudio))
        updater.add(to: RunLoop.current, forMode: .default)
        slider.maximumValue = Float(audioPlayer.duration)
        setCurrentTime()
        btnPause.isEnabled = true
        btnPlay.isEnabled = false
        animateView.start()
        animateViewRect.start()
    }
    
    //Mark:- update time and slider value
    @objc func trackAudio() {
        slider.value = Float(audioPlayer.currentTime)
        setCurrentTime()
    }
    
    //Mark:- play button action
    @IBAction func btnPlayAction(_ sender: Any) {
        playAudio(currentTime: TimeInterval(slider.value))
        btnPause.isEnabled = true
        btnPlay.isEnabled = false
    }
    
    //Mark:- pause button action
    @IBAction func btnPauseAction(_ sender: Any) {
        pauseAudio()
        btnPause.isEnabled = false
        btnPlay.isEnabled = true
    }
    
    //Mark:- restart button action
    @IBAction func btnRestartAction(_ sender: Any) {
        
        if audioPlayer.isPlaying || isPaused {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            audioPlayer.play()
            
        } else {
            audioPlayer.play()
        }
        
    }
    
    //Mark:- sets current time
    func setCurrentTime() {
        let cmTime = CMTimeMakeWithSeconds(audioPlayer.currentTime, preferredTimescale: 1)
        let seconds = CMTimeGetSeconds(cmTime)
        let secondsString = String(format:"%02d",Int(seconds) % 60)
        let minutesString = String(format:"%01d",Int(seconds) / 60)
        self.lblCurrentTime.text = "\(minutesString):\(secondsString)"
    }
    
    //Mark:- sets total time
    func setTotalTime() {
        let cmTime = CMTimeMakeWithSeconds(audioPlayer.duration, preferredTimescale: 1)
        let seconds = CMTimeGetSeconds(cmTime)
        let secondsString = String(format:"%02d",Int(seconds) % 60)
        let minutesString = String(format:"%01d",Int(seconds) / 60)
        self.lblTotalTime.text = "\(minutesString):\(secondsString)"
    }
      
   

}

