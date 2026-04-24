import Foundation

enum AppRoute: Equatable {
    case splash
    case welcome
    case signUp
    case login
    case science
    case onboardingQ1
    case onboardingQ2
    case onboardingQ3
    case onboardingQ4
    case onboardingQ5
    case scheduleReady
    case dashboard
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var route: AppRoute = .splash

    func navigate(to route: AppRoute) {
        self.route = route
    }

    func navigateBack() {
        switch route {
        case .login, .signUp: route = .welcome
        default: route = .welcome
        }
    }
}
