//
// Copyright 2022 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Combine
import SwiftUI

struct RoomChangePermissionsScreenCoordinatorParameters {
    let permissions: RoomPermissions
    let permissionsGroup: RoomRolesAndPermissionsScreenPermissionsGroup
    let roomProxy: JoinedRoomProxyProtocol
    let userIndicatorController: UserIndicatorControllerProtocol
    let analytics: AnalyticsService
}

enum RoomChangePermissionsScreenCoordinatorAction {
    case complete
}

final class RoomChangePermissionsScreenCoordinator: CoordinatorProtocol {
    private let parameters: RoomChangePermissionsScreenCoordinatorParameters
    private var viewModel: RoomChangePermissionsScreenViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let actionsSubject: PassthroughSubject<RoomChangePermissionsScreenCoordinatorAction, Never> = .init()
    var actionsPublisher: AnyPublisher<RoomChangePermissionsScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(parameters: RoomChangePermissionsScreenCoordinatorParameters) {
        self.parameters = parameters
        
        viewModel = RoomChangePermissionsScreenViewModel(currentPermissions: parameters.permissions,
                                                         group: parameters.permissionsGroup,
                                                         roomProxy: parameters.roomProxy,
                                                         userIndicatorController: parameters.userIndicatorController,
                                                         analytics: parameters.analytics)
    }
    
    func start() {
        viewModel.actionsPublisher.sink { [weak self] action in
            MXLog.info("Coordinator: received view model action: \(action)")
            
            guard let self else { return }
            switch action {
            case .complete:
                actionsSubject.send(.complete)
            }
        }
        .store(in: &cancellables)
    }
        
    func toPresentable() -> AnyView {
        AnyView(RoomChangePermissionsScreen(context: viewModel.context))
    }
}
