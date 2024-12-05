//
//  StepperView.swift
//  SparkStepper
//
//  Created by louis.borlee on 29/11/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import SwiftUI
import SparkTheming
import SparkButton
@_spi(SI_SPI) import SparkCommon

/// The SwiftUI version for the stepper
public struct StepperView<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    @Binding private var value: V

    private var viewModel: StepperViewModel<V>

    @Environment (\.isEnabled) private var isEnabled

    public init(
        theme: any Theme,
        value: Binding<V>,
        step: V.Stride,
        in bounds: ClosedRange<V>
    ) {
        self._value = value
        self.viewModel = .init(
                theme: theme,
                value: value.wrappedValue,
                step: step,
                in: bounds
        )
    }

    public init<F>(
        theme: any Theme,
        value: Binding<F.FormatInput>,
        step: F.FormatInput.Stride = 1,
        in bounds: ClosedRange<F.FormatInput>,
        format: F
    ) where F : ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
        self._value = value
        self.viewModel = .init(
                theme: theme,
                value: value.wrappedValue,
                step: step,
                in: bounds,
                format: format
        )
    }

    public var body: some View {
        StepperControlInternal(
            value: self.$value,
            viewModel: self.viewModel
        )
        .update(isEnabled: self.isEnabled)
    }
}

private struct StepperControlInternal<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    @Environment (\.stepperButtonsConfiguration) private var buttonsConfiguration

    @Binding private var value: V
    @ObservedObject private var viewModel: StepperViewModel<V>

    init(value: Binding<V>,
         viewModel: StepperViewModel<V>) {
        _value = value
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            self.viewModel.backgroundColor.color
            HStack(spacing: 0) {
                leadingButton()
                separator()
                spacer()
                Text(self.viewModel.text)
                    .frame(minWidth: 40)
                spacer()
                separator()
                trailingButton()
            }
        }
        .border(
            width: self.viewModel.borderWidth,
            radius: self.viewModel.cornerRadius,
            colorToken: self.viewModel.borderColor
        )
        .onChange(of: self.viewModel.value, perform: { value in
            self.value = value
        })
        .compositingGroup()
        .opacity(self.viewModel.dim)
    }

    func update(isEnabled: Bool) -> Self {
        DispatchQueue.main.async {
            self.viewModel.isEnabled = isEnabled
        }
        return self
    }

    @ViewBuilder
    private func spacer() -> some View {
        Spacer(minLength: self.viewModel.theme.layout.spacing.medium)
    }

    @ViewBuilder
    private func separator() -> some View {
        self.viewModel.borderColor.color
            .frame(width: self.viewModel.borderWidth)
    }

    @ViewBuilder
    private func leadingButton() -> some View {
        IconButtonView(
            theme: self.viewModel.theme,
            intent: self.buttonsConfiguration.leading.intent,
            variant: self.buttonsConfiguration.leading.variant,
            size: .medium,
            shape: .square) {
                self.viewModel.decrement()
            }
            .image(self.buttonsConfiguration.leading.icon, for: .normal)
            .disabled(self.viewModel.isMinValue)
    }

    @ViewBuilder
    private func trailingButton() -> some View {
        IconButtonView(
            theme: self.viewModel.theme,
            intent: self.buttonsConfiguration.trailing.intent,
            variant: self.buttonsConfiguration.trailing.variant,
            size: .medium,
            shape: .square) {
                self.viewModel.increment()
            }
            .image(self.buttonsConfiguration.trailing.icon, for: .normal)
            .disabled(self.viewModel.isMaxValue)
    }
}
