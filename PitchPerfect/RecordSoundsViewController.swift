//
//  RecordSoundsViewController.swift
//  PitechPerfect
//
//  Created by Hend  on 4/29/19.
//  Copyright © 2019 Hend . All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var lblRecording: UILabel!
    @IBOutlet weak var btnStartRecord: UIButton!
    @IBOutlet weak var btnStopRecord: UIButton!
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btnStopRecord.isEnabled = false
    }

    @IBAction func StartRecording(_ sender: UIButton) {
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
            if granted{
                self.configureUI(RecordStarted: true)
                let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
                let recordingName = "recordedVoice.wav"
                let pathArray = [dirPath, recordingName]
                let filePath = URL(string: pathArray.joined(separator: "/"))
                print(pathArray)
                
                let session = AVAudioSession.sharedInstance()
                try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
                
                try! self.audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
                self.audioRecorder.delegate = self
                self.audioRecorder.isMeteringEnabled = true
                
                self.audioRecorder.prepareToRecord()
                self.audioRecorder.record()
            }
            else{
                self.showAlert("Permission Denied", message: "Permission to use microphone is denied")
                self.btnStopRecord.isEnabled = false
                self.btnStartRecord.isEnabled = false
            }
        })
    }
    
    @IBAction func StopRecording(_ sender: UIButton) {
        configureUI(RecordStarted: false)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
            print("Fisished Recording")
        } else {
            print("Recording was not successful")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording"{
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }else{
            showAlert("Recoring Failed", message: "Something went wrong with your recording.")
        }
    }
    
    func configureUI(RecordStarted: Bool) {
        switch(RecordStarted) {
        case true:
            lblRecording.text = "Recording in progress ..."
            btnStartRecord.isEnabled = false
            btnStopRecord.isEnabled = true
        case false:
            lblRecording.text = "Recording is stopped"
            btnStartRecord.isEnabled = true
            btnStopRecord.isEnabled = false
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
}

