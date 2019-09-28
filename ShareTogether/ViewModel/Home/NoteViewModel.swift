//
//  ActiveViewModel.swift
//  ShareTogether
//
//  Created by littlema on 2019/8/29.
//  Copyright © 2019 littema. All rights reserved.
//

import Foundation
import UIKit

class NoteViewModel: NSObject {
    
    private var notes = [Note]() {
        didSet {
            print(notes.count)
        }
    }
    
    var notebookCellViewModel = [NotebookCellViewModel]() {
        didSet {
            reloadTableViewHandler?()
        }
    }
    
    var reloadTableViewHandler: (() -> Void)?
    
    func fectchData() {
        
        FirestoreManager.shared.getNotes { [weak self] result in
            switch result {
                
            case .success(let notes):
                self?.notes = notes
                self?.processData()
            case .failure(let error):
                LKProgressHUD.showFailure(text: error.localizedDescription)
            }
        }
        
    }
    
    func processData() {
        
        var notebookCellViewModel = [NotebookCellViewModel]()
        
        for note in notes {
            
            let user = CurrentInfoManager.shared.getMemberInfo(uid: note.auctorID)
            let viewModel = NotebookCellViewModel(userImageURL: user?.photoURL,
                                                  userName: user?.name ?? "",
                                                  content: note.content,
                                                  commentCount: note.comments?.count ?? 0,
                                                  time: note.time.toNowFormat)
            notebookCellViewModel.append(viewModel)
        }
        
        self.notebookCellViewModel = notebookCellViewModel
 
    }
    
    func getViewModel(indexPath: IndexPath) -> NotebookCellViewModel {
        return notebookCellViewModel[indexPath.row]
    }
    
    func getNote(index: Int) -> Note {
        return notes[index]
    }
    
}
