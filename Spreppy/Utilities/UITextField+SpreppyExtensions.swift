//
//  UITextField+SpreppyExtensions.swift
//  Spreppy
//
//  Created by Russell Blickhan on 11/8/21.
//

import Combine
import Foundation
import UIKit

extension UITextField {
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self)
            .map { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }
}
