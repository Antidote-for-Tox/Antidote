//
//  Theme.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import Yaml

enum ErrorTheme: ErrorType {
    case CannotParseFile(String)
}

struct Theme {
    let loginBackground: UIColor!

    init(yamlString: String) throws {
        guard
            let dictionary = Yaml.load(yamlString).value?.dictionary,
            let colors = dictionary[.String(Constants.ColorsKey)],
            let values = dictionary[.String(Constants.ValuesKey)]
            else {
                throw ErrorTheme.CannotParseFile
        }

        loginBackground = UIColor.redColor()
    }

    private func parse(yamlString: String) {

    }

    private struct Constants {
        static let ColorsKey = "colors"
        static let ValuesKey = "values"
    }
}
