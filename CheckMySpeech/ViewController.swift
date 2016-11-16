//
//  ViewController.swift
//  CheckMySpeech
//
//  Created by Nneoma Oradiegwu on 10/29/16.
//  Copyright © 2016 Nneoma Oradiegwu. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var btnMicrophone: UIButton!
    @IBOutlet weak var imView: UIImageView!
    @IBOutlet weak var recordText: UITextView!
    @IBOutlet weak var imView2: UIImageView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        btnMicrophone.isEnabled = false
        
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.btnMicrophone.isEnabled = isButtonEnabled
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func microphonePressed(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            self.recordText.text = "Tap to record"
            recognitionRequest!.endAudio()
            btnMicrophone.isEnabled = false
            btnMicrophone.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            self.recordText.text = "Recording"
            btnMicrophone.setTitle("Stop Recording", for: .normal)
        }
    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btnMicrophone.isEnabled = true
        } else {
            btnMicrophone.isEnabled = false
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                switch result!.bestTranscription.formattedString.lowercased() {
                    case "yellow":
                        self.imView.image = nil
                        self.imView2.image = nil
                        self.view.backgroundColor = UIColor.yellow
                    case "pink":
                        self.imView.image = nil
                        self.imView2.image = nil
                        self.view.backgroundColor = UIColor.magenta
                    case "blue":
                        self.imView.image = nil
                        self.imView2.image = nil
                        self.view.backgroundColor = UIColor.blue
                    case "south shore fine arts academy":
                        self.imView.image = nil
                        self.imView2.backgroundColor = UIColor.blue
                        self.view.backgroundColor = UIColor.white
                    case "go cats":
                        self.imView2.image = nil
                        self.imView.image = UIImage(named: "Northwestern-Wildcats-NCAA")
                    case "go cat":
                        self.imView2.image = nil
                        self.imView.image = UIImage(named: "Northwestern-Wildcats-NCAA")
                default: self.imView.image = UIImage(named: "question.jpg")
                }
                print(result!.bestTranscription.formattedString)
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.btnMicrophone.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        print("Say something, I'm listening!")
        
    }

}

