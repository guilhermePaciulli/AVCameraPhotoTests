

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    
    var captureSession = AVCaptureSession()
    
    var backCamera: AVCaptureDevice?
    
    var frontCamera: AVCaptureDevice?
    
    var currentDevice: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupCaptureSession()
        self.setupDevice()
        self.setupInputOutput()
        self.setupPreviewLayer()
        self.captureSession.startRunning()
        self.styleCaptureButton()
    }


    func setupCaptureSession() {
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                self.backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                self.frontCamera = device
            }
        }
        self.currentDevice = backCamera
    }

    
    func setupInputOutput() {
        do {
            
            if let oldDevice = self.captureSession.inputs.first, let oldOutput = self.captureSession.outputs.first {
                self.captureSession.removeInput(oldDevice)
                self.captureSession.removeOutput(oldOutput)
            }
            
            let captureDeviceInput = try AVCaptureDeviceInput(device: self.currentDevice!)
            self.captureSession.addInput(captureDeviceInput)
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            self.captureSession.addOutput(photoOutput!)
            
        } catch {
            print(error)
        }
    }

    
    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    @IBAction func invertCamera_TouchUpInside(_ sender: Any) {
        self.captureSession.stopRunning()
        if self.currentDevice?.position == AVCaptureDevice.Position.back {
            self.currentDevice = self.frontCamera
        } else if self.currentDevice?.position == AVCaptureDevice.Position.front  {
            self.currentDevice = self.backCamera
        }
        self.setupInputOutput()
        self.captureSession.startRunning()
    }
    
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Preview_Segue" {
            let previewViewController = segue.destination as! PreviewViewController
            previewViewController.image = self.image
        }
    }
    func styleCaptureButton() {
        self.cameraButton.layer.borderColor = UIColor.white.cgColor
        self.cameraButton.layer.borderWidth = 5
        self.cameraButton.clipsToBounds = true
        self.cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            self.image = UIImage(data: imageData)
            performSegue(withIdentifier: "Preview_Segue", sender: nil)
        }
    }
}

