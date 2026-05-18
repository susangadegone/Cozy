import Foundation

enum AppRoute: Equatable {
    case splash
    case welcome
    case signUp
    case login
    case science
    case onboardingName
    case onboardingQ1
    case onboardingQ2
    case onboardingQ3
    case cleanlinessType
    case cleanlinessGoal
    case onboardingQ4
    case onboardingQ5
    case scheduleReady
    case recap
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
        case .onboardingQ1:  route = .onboardingName
        case .onboardingQ2:  route = .onboardingQ1
        case .onboardingQ3:     route = .onboardingQ1
        case .cleanlinessType:  route = .onboardingQ3
        case .cleanlinessGoal:  route = .cleanlinessType
        case .onboardingQ4:     route = .cleanlinessGoal
        case .onboardingQ5:  route = .onboardingQ4
        case .scheduleReady: route = .onboardingQ5
        case .login, .signUp: route = .welcome
        case .science:        route = .signUp
        default:              route = .onboardingName
        }
    }
}
