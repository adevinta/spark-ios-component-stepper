//
//  StepperControlViewModel.swift
//  SparkStepper
//
//  Created by louis.borlee on 29/11/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import SwiftUI
import SparkTheming

final class StepperControlViewModel<V>: ObservableObject where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    @Published private(set) var text: String = ""
    @Published private(set) var textFont: any TypographyFontToken
    @Published private(set) var textColor: any ColorToken

    @Published private(set) var backgroundColor: any ColorToken

    @Published private(set) var borderColor: any ColorToken
    @Published private(set) var borderWidth: CGFloat
    @Published private(set) var cornerRadius: CGFloat

    @Published private(set) var isMinValue: Bool = true
    @Published private(set) var isMaxValue: Bool = false

    @Published private(set) var dim: CGFloat = 1.0

    @Published private(set) var value: V {
        didSet {
            guard oldValue != self.value else { return }
            self.text = self.formattedText()
            self.checkMinMaxValue()
        }
    }
    var bounds: ClosedRange<V> {
        didSet {
            guard self.bounds != oldValue else { return }
            self.checkMinMaxValue()
        }
    }
    var step: V.Stride

    var isEnabled: Bool = true {
        didSet {
            guard self.isEnabled != oldValue else { return }
            self.resetDim()
            self.resetBackgroundColor()
        }
    }

    var theme: any Theme {
        didSet {
            self.resetTheme()
        }
    }

    private var formattedText: () -> String = { "" }

    private(set) var interval: TimeInterval = 0.5

    init(
        theme: any Theme,
        value: V,
        step: V.Stride,
        in bounds: ClosedRange<V>
    ) {
        self.theme = theme
        self.value = value
        self.step = step
        self.bounds = bounds

        self.textFont = self.theme.typography.body1
        self.textColor = self.theme.colors.base.onSurface

        self.backgroundColor = self.theme.colors.base.surface

        self.borderColor = self.theme.colors.base.outline
        self.borderWidth = self.theme.border.width.small
        self.cornerRadius = self.theme.border.radius.medium

        self.formattedText = { [weak self] in
            guard let self else { return "" }
            return "\(self.value)"
        }

        self.text = self.formattedText()
        self.checkMinMaxValue()
    }

    init<F>(
        theme: any Theme,
        value: F.FormatInput,
        step: F.FormatInput.Stride,
        in bounds: ClosedRange<F.FormatInput>,
        format: F
    ) where F : ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
        self.theme = theme
        self.value = value
        self.step = step
        self.bounds = bounds

        self.textFont = self.theme.typography.body1
        self.textColor = self.theme.colors.base.onSurface

        self.backgroundColor = self.theme.colors.base.surface

        self.borderColor = self.theme.colors.base.outline
        self.borderWidth = self.theme.border.width.small
        self.cornerRadius = self.theme.border.radius.medium

        self.formattedText = { [weak self] in
            guard let self else { return "" }
            return format.format(self.value)
        }

        self.text = self.formattedText()
        self.checkMinMaxValue()
    }

    @discardableResult
    func increment() -> V {
        self.value = min(self.bounds.upperBound, self.value.advanced(by: self.step))
        return self.value
    }

    @discardableResult
    func decrement() -> V {
        self.value = max(self.bounds.lowerBound, self.value.advanced(by: -self.step))
        return self.value
    }

    private func checkMinMaxValue() {
        let isMinValue = self.value <= self.bounds.lowerBound
        if isMinValue != self.isMinValue {
            self.isMinValue = isMinValue
        }

        let isMaxValue = self.value >= self.bounds.upperBound
        if isMaxValue != self.isMaxValue {
            self.isMaxValue = isMaxValue
        }
    }

    func removeFormat() {
        self.formattedText = { [weak self] in
            guard let self else { return "" }
            return "\(self.value)"
        }
        let newText = self.formattedText()
        guard newText != self.text else { return }
        self.text = newText
    }

    func setFormat<F>(_ format: F)  where F : ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
        self.formattedText = { [weak self] in
            guard let self else { return "" }
            return format.format(self.value)
        }
        let newText = self.formattedText()
        guard newText != self.text else { return }
        self.text = newText
    }

    func setValue(_ value: V) {
        guard self.value != value else { return }
        self.value = value
    }

    private func resetTheme() {
        self.textFont = self.theme.typography.body1
        self.textColor = self.theme.colors.base.onSurface
        self.resetBackgroundColor()
        self.borderColor = self.theme.colors.base.outline
        self.borderWidth = self.theme.border.width.small
        self.cornerRadius = self.theme.border.radius.medium
        self.resetDim()
    }

    private func resetBackgroundColor() {
        self.backgroundColor = self.isEnabled ? self.theme.colors.base.surface : self.theme.colors.base.onSurface.opacity(self.theme.dims.dim5)
    }

    private func resetDim() {
        self.dim = self.isEnabled ? self.theme.dims.none : self.theme.dims.dim3
    }

    func getDecrementAccessibilityLabel() -> String {
        return "Value: \(self.text), Decrement"
    }

    func getIncrementAccessibilityLabel() -> String {
        return "Value: \(self.text), Increment"
    }

    func resetInterval() {
        self.interval = 0.5
    }

    func updateInterval() {
        self.interval = max(0.035, self.interval * 0.85)
    }
}
