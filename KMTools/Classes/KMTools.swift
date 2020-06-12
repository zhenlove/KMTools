//
//  KMTools.swift
//  KMTools
//
//  Created by Ed on 2020/6/11.
//

import Foundation
import UIKit
@objc(BackHandler) public protocol BackHandler:NSObjectProtocol {
    func navigationShouldPopOnBack() -> Bool
}

extension UINavigationController:UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let items = navigationBar.items {
            if self.viewControllers.count < items.count {
                return true
            }
        }
        
        var shouldPod = true
        if let vc = self.topViewController as? BackHandler {
            vc.navigationShouldPopOnBack()
        }
        
        if shouldPod {
            DispatchQueue.main.async { [weak self] in
                self?.popViewController(animated: true)
            }
        }else{
            for view in navigationBar.subviews {
                if view.alpha > 0 && view.alpha < 1 {
                    UIView.animate(withDuration: 0.25) {
                        view.alpha = 1
                    }
                }
            }
        }
        return false
    }
}

extension UIViewController:UIGestureRecognizerDelegate {
    
    
    @_dynamicReplacement(for:viewDidAppear(_:))
    func swizzle_viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let vc = navigationController?.topViewController else {
            return true
        }
        
        guard let newVC = vc as? BackHandler else {
            return true
        }
        
        return newVC.navigationShouldPopOnBack()
        
    }
}


extension Date {
    
    /// 小于当前时间
    /// - Parameter dateStr: 指定时间
    /// - Returns: true Or false
    public static func lessThanCurrentDate(_ dateStr:String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateStr)  else {
            return false
        }
        if date < Date() {
            return true
        }
        return false
    }
}


extension Dictionary {
    public static func ToJson(_ data:Data) -> Self? {
        return try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<Key, Value>
    }
}

extension UIColor {
    @objc public static func hex(_ rgbValue:Int) -> UIColor {
        return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0,
                       blue: ((CGFloat)(rgbValue & 0xFF)) / 255.0,
                       alpha: 1.0)
    }
}

extension String {
    public func nsRange(from range: Range<String.Index>?) -> NSRange? {
        if let rag = range,
            let from = rag.lowerBound.samePosition(in: utf16),
            let to = rag.upperBound.samePosition(in: utf16) {
            return NSRange(location: utf16.distance(from: utf16.startIndex, to: from), length: utf16.distance(from: from, to: to))
        }
        return nil
    }
}


extension UIDevice {
    @objc public static func getBottomSafeAreaHeight() -> CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        } else {
            return 0.0
        }
    }
}

extension Bundle{
    @objc public static func bundle(_ name:String) -> Bundle? {
        
        if let path = Bundle.main.path(forResource: name, ofType: "bundle") {
            return Bundle(path: path)
        }
        
        if let resourcePath = Bundle.main.resourcePath {
            return Bundle(path: resourcePath + "/Frameworks/\(name).framework/\(name).bundle")
        }
        
        return nil
    }
}

