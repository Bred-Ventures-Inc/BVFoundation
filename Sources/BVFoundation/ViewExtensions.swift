//
//  UIExtensions.swift
//  Fat Burn
//
//  Created by TealShift Schwifty on 7/7/22.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
public extension String {
    var toUIColor: UIColor {
        guard self.count == 6 else { return .white }
        let scanner = Scanner(string: self)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else {return .white}
        let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
        let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
        let b = CGFloat(hexNumber & 0x0000ff)       / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
#endif

extension Binding {
    /// When the `Binding`'s `wrappedValue` changes, the given closure is executed.
    /// - Parameter closure: Chunk of code to execute whenever the value changes.
    /// - Returns: New `Binding`.
    public func onUpdate(_ closure: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                wrappedValue = newValue
                closure(newValue)
            }
        )
    }
}

public extension View {
    func frame(square: Double, alignment: Alignment = .center) -> some View {
        self.frame(width: square, height: square, alignment: alignment)
    }
    func frame(size: CGSize, align: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: align)
    }
    
    /// Animatable-sized font
    func animFont(size: Double, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        self.modifier(AnimatableCustomFontModifier(size: size, weight: weight, design: design))
    }
    
    /// Animatable-integer text
    func animatedText(number: Int, max: Int) -> some View {
        self.modifier(AnimatableNumberModifier(max: max, number: Double(number)))
    }
    
    /// Binding sync shortcut to circumvent the new annoying Xcode 14 warning when `@Published` vars are bound to view states.
    /// This is the warning: "Publishing changes from within view updates is not allowed, this will cause undefined behaviour"
    @available(tvOS 14.0, iOS 15.0, watchOS 8.0, *)
    func sync(_ published: Binding<Bool>, with binding: Binding<Bool>) -> some View {
        self.onChange(of: published.wrappedValue) { newValue in
            binding.wrappedValue = newValue
        }.onChange(of: binding.wrappedValue) { newValue in
            published.wrappedValue = newValue
        }
    }
}

// A modifier that animates a font through various sizes.
struct AnimatableCustomFontModifier: ViewModifier, Animatable {
    var size: Double
    let weight: Font.Weight
    let design: Font.Design

    var animatableData: Double {
        get { size }
        set { size = newValue }
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: design))
            .minimumScaleFactor(0.1)
    }
}

struct AnimatableNumberModifier: AnimatableModifier {
    let max: Int
    var number: Double
    
    var animatableData: Double {
        get { number }
        set { number = newValue }
    }
    
    func body(content: Content) -> some View {
        Text(String(repeating: "9", count: String(max).count)).lineLimit(1)
            .opacity(0)
            .overlay(
                Text("\(Int(number))")
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
            )
    }
}

public extension GeometryProxy {
    /// The largest square size that fits
    var squareFit: Double {
        min(size.width, size.height)
    }
    /// Width divided by height
    var aspectRatio: Double {
        size.width / size.height
    }
}

public extension Int {
    func counting(_ thing: String, pluralSuffix: String = "s") -> String {
        "\(self) \(thing)\(self == 1 ? "" : pluralSuffix)"
    }
}

/// Wrapper for DispatchQueue.main.async
/// - Parameters:
///   - time: Seconds to wait before execution
///   - completion: Work to execute on main
public func mainThread(after time: TimeInterval? = nil, completion: @escaping () -> ()) {
    if let time = time {
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: completion)
    } else {
        DispatchQueue.main.async(execute: completion)
    }
}

public extension Int {
    var abbreviated: String {
        if self >= 1000 && self < 10000 {
            return String(format: "%.1fk", Double(self/100)/10).replacingOccurrences(of: ".0", with: "")
        }
        
        if self >= 10000 && self < 1000000 {
            return "\(self/1000)k"
        }
        
        if self >= 1000000 && self < 10000000 {
            return String(format: "%.1fm", Double(self/100000)/10).replacingOccurrences(of: ".0", with: "")
        }
        
        if self >= 10000000 {
            return "\(self/1000000)m"
        }
        
        return String(self)
    }
}

public extension Image {
    @ViewBuilder
    func aspectFit(square: Double? = nil) -> some View {
        if let square = square {
            self.resizable().aspectRatio(contentMode: .fit).frame(square: square)
        } else {
            self.resizable().aspectRatio(contentMode: .fit)
        }
    }
}

