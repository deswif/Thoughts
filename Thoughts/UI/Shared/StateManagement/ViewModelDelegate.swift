//
//  ViewModeled.swift
//  Thoughts
//
//  Created by Max Steshkin on 16.09.2023.
//

import Combine

protocol ViewModelDelegate {
    associatedtype VM: ViewModel
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func createViewModel() -> VM
    
    func events(for viewModel: VM) -> VM.E
    
    func applyState(from viewModel: VM, state: VM.S)
}

extension ViewModelDelegate {
    
    func loadViewModel() {
        cancellables.forEach { $0.cancel() }
        
        let viewModel = createViewModel()
        let events = events(for: viewModel)
        let state = viewModel.transform(events: events)
        applyState(from: viewModel, state: state)
    }
}
