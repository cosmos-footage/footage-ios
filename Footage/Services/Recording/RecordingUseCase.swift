//
//  RecordingUseCase.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import CoreLocation
import Foundation

protocol RecordingUseCase: AnyObject {
    var delegate: RecordingServiceDelegate? { get set }

    func startRecording()
    func stopRecording()
    func process(location: CLLocation)
}

extension RecordingService: RecordingUseCase {}
