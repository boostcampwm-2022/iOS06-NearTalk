//
//  CaptureQRViewController.swift
//  NearTalk
//
//  Created by 고병학 on 2022/12/14.
//

import AVFoundation
import UIKit
import RxSwift

class QRCodeReaderViewController: UIViewController {
    private let captureSession = AVCaptureSession()
    private let scanResult: PublishSubject<String>
    
    init(scanResult: PublishSubject<String>) {
        self.scanResult = scanResult
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetting()
    }
}

extension QRCodeReaderViewController {
    
    private func basicSetting() {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            fatalError("No video device found")
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let output = AVCaptureMetadataOutput()
            captureSession.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            setVideoLayer()
            setGuideCrossLineView()
            captureSession.startRunning()
        } catch {
            print("error")
        }
    }
    
    private func setVideoLayer() {
        let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = view.layer.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(videoLayer)
    }
    
    private func setGuideCrossLineView() {
        let guideCrossLine = UIImageView()
        guideCrossLine.image = UIImage(systemName: "plus")
        guideCrossLine.tintColor = .green
        guideCrossLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guideCrossLine)
        NSLayoutConstraint.activate([
            guideCrossLine.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideCrossLine.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            guideCrossLine.widthAnchor.constraint(equalToConstant: 30),
            guideCrossLine.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}

extension QRCodeReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(
        _ captureOutput: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject, let stringValue = readableObject.stringValue else {
                return
            }
            
            if stringValue.hasPrefix("neartalk:") {
                scanResult.onNext(stringValue)
                self.captureSession.stopRunning()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
