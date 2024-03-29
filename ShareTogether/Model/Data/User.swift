//
//  Firestore.swift
//  ShareTogether
//
//  Created by littlema on 2019/9/26.
//  Copyright © 2019 littema. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct UserInfo: Codable {
    var id: String!
    let name: String
    let email: String
    let phone: String?
    let photoURL: String?
    var groups: [GroupInfo]!
    var fcmToken: String?
}

struct GroupInfo: Codable {
    var id: String!
    let name: String
    let coverURL: String
    var status: Int?
}

struct MemberInfo: Codable {
    var id: String!
    let name: String
    let email: String
    let photoURL: String?
    var status: Int
    var fcmToken: String?
    
    init(userInfo: UserInfo, status: Int) {
        self.id = userInfo.id
        self.name = userInfo.name
        self.email = userInfo.email
        self.photoURL = userInfo.photoURL
        self.status = status
    }
}

struct Activity: Codable {
    var id: String!
    let type: Int
    var status: Int
    let targetMember: MemberInfo
    let pushUser: UserInfo
    let groupInfo: GroupInfo?
    let expense: Expense?
    let time: Timestamp
    
    init(type: Int,
         targetMember: MemberInfo,
         pushUser: UserInfo,
         groupInfo: GroupInfo?,
         expense: Expense?,
         time: Date,
         status: Int) {
        
        self.type = type
        self.targetMember = targetMember
        self.pushUser = pushUser
        self.groupInfo = groupInfo
        self.expense = expense
        self.time = Timestamp(date: time)
        self.status = status
    }
}

struct Note: Codable {
    var id: String!
    let content: String
    let auctorID: String
    var comments: [NoteComment]?
    let time: Timestamp
    
    init(id: String?,
         content: String,
         auctorID: String,
         comments: [NoteComment]?,
         time: Date) {
        
        self.id = id
        self.content = content
        self.auctorID = auctorID
        self.comments = comments
        self.time = Timestamp(date: time)
    }
}

struct NoteComment: Codable {
    var id: String!
    let auctorID: String
    let content: String?
    let mediaID: String?
    let time: Timestamp
    
    init(id: String?,
         auctorID: String,
         content: String?,
         mediaID: String?,
         time: Date) {
        
        self.id = id
        self.auctorID = auctorID
        self.content = content
        self.mediaID = mediaID
        self.time = Timestamp(date: time)
    }
}
