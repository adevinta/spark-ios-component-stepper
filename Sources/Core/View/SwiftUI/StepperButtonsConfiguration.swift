//
//  StepperButtonsConfiguration.swift
//  SparkStepper
//
//  Created by louis.borlee on 11/12/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import SwiftUI
import SparkButton

public extension EnvironmentValues {
    var stepperButtonsConfiguration: StepperViewButtonsConfiguration {
        get { self[StepperViewButtonsConfigurationKey.self] }
        set { self[StepperViewButtonsConfigurationKey.self] = newValue }
    }
}

public struct StepperViewButtonsConfigurationKey: EnvironmentKey {
    public static let defaultValue = StepperViewButtonsConfiguration()
}

public struct StepperViewButtonsConfiguration  {
    let decrement: StepperViewButtonConfiguration
    let increment: StepperViewButtonConfiguration

    public init(decrement: StepperViewButtonConfiguration = .init(icon: .init(systemName: "minus")),
                increment: StepperViewButtonConfiguration = .init(icon: .init(systemName: "plus"))) {
        self.decrement = decrement
        self.increment = increment
    }
}

public struct StepperViewButtonConfiguration  {
    let icon: Image
    let intent: ButtonIntent
    let variant: ButtonVariant

    public init(icon: Image,
                intent: ButtonIntent = .neutral,
                variant: ButtonVariant = .ghost) {
        self.icon = icon
        self.intent = intent
        self.variant = variant
    }
}

public extension View {
    func stepperButtonsConfiguration(_ configuration: StepperViewButtonsConfiguration) -> some View {
        environment(\.stepperButtonsConfiguration, configuration)
    }
}
