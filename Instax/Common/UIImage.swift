//
//  UIImage.swift
//  Instax
//
//  Created by mizznoff on 2025/09/23.
//

import Foundation
import UIKit

public extension UIImage {
    #if DEBUG
        static var mockImage: UIImage {
            let url = URL(string: "https://i.gyazo.com/e94eeac7f1939804af6f80de69960b71.jpg")!
            return UIImage(data: try! Data(contentsOf: url))!
        }
    #endif
}
