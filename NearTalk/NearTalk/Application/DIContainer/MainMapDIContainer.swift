//
//  MainMapDIContainer.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/21.
//

import UIKit

final class MainMapDIContainer {
    
    struct Dependencies {
        
    }
    
    private let dependencies: Dependencies
    
    // MARK: - Storages
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - UseCases
//    func makeFetchChatRoomsInfoUseCase() -> MainMapUseCase {
//        return FetchChatRoomsInfoUseCase(mainMapRepository: self.makeFetchC)
//    }
    
//    func makeUploadChatRoomInfoUseCase() -> MainMapUseCase {
//        return UploadChatRoomInfoUseCase(mainMapRepository: <#T##MainMapRepository#>)
//    }
    
    // MARK: - Repositories
    // func makeMainMapRepositories()
    
    // MARK: - MainMap Scene
    // func makeMainMapViewModel() -> MainMapViewModel {
    //     return DefaultMainMapViewModel(useCases: MainMapUseCase, actions: )
    // }
    
//    func makeMainMapViewController() -> MainMapViewController {
//        return MainMapViewController.create(with: self.makeMainMapViewModel())
//    }
    
    // MARK: - Flow Coordinators
    func makeMainMapFlowCoordinator() {
        
    }
}
