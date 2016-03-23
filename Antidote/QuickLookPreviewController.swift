//
//  QuickLookPreviewController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 23.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import QuickLook

protocol QuickLookPreviewControllerDataSource: QLPreviewControllerDataSource {
    weak var previewController: QuickLookPreviewController? { get set }
}

class QuickLookPreviewController: QLPreviewController {
    var dataSourceStorage: QuickLookPreviewControllerDataSource?
}
