//
//  VideoViewController.swift
//  LiveTextDetector
//
//  Created by Reed Carson on 5/24/21.
//

import AVKit

public class VideoViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    
    let cameraView = UIView()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureDevice: AVCaptureDevice?
    
    var videoConnection: AVCaptureConnection?
    
//    lazy var dataOutput: AVCaptureVideoDataOutput = {
//        let output = AVCaptureVideoDataOutput()
//        output.setSampleBufferDelegate(self, queue: cameraQueue)
//        output.alwaysDiscardsLateVideoFrames = true
//        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
//        return output
//    }()
    
    let cameraQueue = DispatchQueue(label: "cameraQueue")
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        view.addSubview(cameraView)
        view.backgroundColor = .blue
        cameraView.frame = view.bounds
        
        let testView = UIView()
        testView.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
        testView.backgroundColor = .red
        cameraView.addSubview(testView)
        
        cameraView.backgroundColor = .gray
        
        setUpCamera()
        
       cameraView.layer.addSublayer(previewLayer!)
    }
    
    func setUpCamera() {
        captureSession.sessionPreset = .hd1920x1080
        captureDevice = AVCaptureDevice.default(for: .video)
        
        guard let captureDevice = captureDevice else {
            print("could not get camera")
            return
           // captu"reDevice.activeVideoMinFrameDuration = CMTime(seconds: 0.1, preferredTimescale: .min)
        }

        do {
            try captureDevice.lockForConfiguration()
            captureDevice.focusMode = .continuousAutoFocus
            captureDevice.unlockForConfiguration()
        } catch {
            print("error setting focus \(error)")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                print("could not add input")
            }
        } catch {
            print("Add input error: \(error)")
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: cameraQueue)
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]

        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        } else {
            print("could not add data output")
        }
        
        setUpPreviewLayer()
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    private func setUpPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.connection?.videoOrientation = UIDevice.current.orientation.avCaptureVideoOrientation
    }
    
    override public func viewDidLayoutSubviews() {
        cameraView.frame = view.bounds

        previewLayer?.frame = view.bounds
        previewLayer?.connection?.videoOrientation = UIDevice.current.orientation.avCaptureVideoOrientation
    }
}

extension VideoViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        print("output")
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("drop")
    }
}

extension UIDeviceOrientation {
    var avCaptureVideoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .landscapeRight:
            return .landscapeLeft
        case .landscapeLeft:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
}
