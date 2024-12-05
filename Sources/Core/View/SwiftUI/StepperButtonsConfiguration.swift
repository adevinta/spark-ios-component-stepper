//
//  StepperButtonsConfiguration.swift
//
//
//  Created by louis.borlee on 03/12/2024.
//

import SwiftUI
import SparkButton

public extension EnvironmentValues {
    public var stepperButtonsConfiguration: StepperViewButtonsConfiguration {
        get { self[StepperViewButtonsConfigurationKey.self] }
        set { self[StepperViewButtonsConfigurationKey.self] = newValue }
    }
}

public struct StepperViewButtonsConfigurationKey: EnvironmentKey {
    public static let defaultValue = StepperViewButtonsConfiguration()
}

public struct StepperViewButtonsConfiguration  {
    let leading: StepperViewButtonConfiguration
    let trailing: StepperViewButtonConfiguration

    public init(leading: StepperViewButtonConfiguration = .init(icon: .init(systemName: "minus")),
                trailing: StepperViewButtonConfiguration = .init(icon: .init(systemName: "plus"))) {
        self.leading = leading
        self.trailing = trailing
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
