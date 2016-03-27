//
//  ChatFileCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 23.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class ChatFileCell: ChatMovableDateCell {
    var progressObject: ChatProgressProtocol? {
        didSet {
            progressObject?.updateProgress = { [weak self] (progress: Float) -> Void in
                self?.updateProgress(CGFloat(progress))
            }

            progressObject?.updateEta = { [weak self] (eta: CFTimeInterval, bytesPerSecond: OCTToxFileSize) -> Void in
                self?.updateEta(String(timeInterval: eta))
                self?.updateBytesPerSecond(bytesPerSecond)
            }
        }
    }

    var state: ChatFileCellModel.State = .WaitingConfirmation

    var startLoadingHandle: (Void -> Void)?
    var cancelHandle: (Void -> Void)?
    var pauseOrResumeHandle: (Void -> Void)?
    var openHandle: (Void -> Void)?

    /// Override in subclass.
    func updateProgress(progress: CGFloat) {}

    /// Override in subclass.
    func updateEta(eta: String) {}

    /// Override in subclass.
    func updateBytesPerSecond(bytesPerSecond: OCTToxFileSize) {}

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let fileModel = model as? ChatFileCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        state = fileModel.state
        startLoadingHandle = fileModel.startLoadingHandle
        cancelHandle = fileModel.cancelHandle
        pauseOrResumeHandle = fileModel.pauseOrResumeHandle
        openHandle = fileModel.openHandle
    }
}
