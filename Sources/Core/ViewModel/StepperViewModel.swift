//
//  StepperViewModel.swift
//  SparkStepper
//
//  Created by louis.borlee on 29/11/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import SwiftUI
import SparkTheming

final class StepperViewModel<V>: ObservableObject where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    @Published var text: String = ""
    @Published var textFont: any TypographyFontToken
    @Published var textColor: any ColorToken
    @Published var backgroundColor: any ColorToken
    @Published var borderColor: any ColorToken
    @Published var borderWidth: CGFloat
    @Published var cornerRadius: CGFloat

    @Published var isMinValue: Bool = true
    @Published var isMaxValue: Bool = false

    @Published var dim: CGFloat = 1.0

    private var formattedText: () -> String = { "" }

    var isEnabled: Bool = true {
        didSet {
            self.dim = self.isEnabled ? self.theme.dims.none : self.theme.dims.dim3
            self.backgroundColor = self.isEnabled ? self.theme.colors.base.surface : self.theme.colors.base.onSurface.opacity(self.theme.dims.dim5)
        }
    }

    var theme: any Theme {
        didSet {
            self.textFont = self.theme.typography.body1
            self.textColor = self.theme.colors.base.onSurface
            self.backgroundColor = self.isEnabled ? self.theme.colors.base.surface : self.theme.colors.base.onSurface.opacity(self.theme.dims.dim5)
            self.borderColor = self.theme.colors.base.outline
            self.borderWidth = self.theme.border.width.small
            self.cornerRadius = self.theme.border.radius.medium
            self.dim = self.isEnabled ? self.theme.dims.none : self.theme.dims.dim3
        }
    }
    @Published var value: V {
        didSet {
            guard oldValue != self.value else { return }
            self.text = self.formattedText()
            self.checkMinMaxValue()
        }
    }
    var bounds: ClosedRange<V>
    var step: V.Stride

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

    func increment() {
        self.value = min(bounds.upperBound, self.value.advanced(by: self.step))
    }

    func decrement() {
        self.value = max(bounds.lowerBound, self.value.advanced(by: -self.step))
    }

    private func checkMinMaxValue() {
        self.isMinValue = self.value <= self.bounds.lowerBound
        self.isMaxValue = self.value >= self.bounds.upperBound
    }

    func setFormat<F>(_ format: F?) where F : ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
        self.formattedText = { [weak self] in
            guard let self else { return "" }
            if let format {
                return format.format(self.value)
            } else {
                return "\(self.value)"
            }
        }
        self.text = self.formattedText()
    }
}
