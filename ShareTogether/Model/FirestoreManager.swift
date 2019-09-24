//
//  FirestoreManager.swift
//  ShareTogether
//
//  Created by littlema on 2019/9/13.
//  Copyright © 2019 littema. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase
import MapKit

extension GeoPoint: GeoPointType {}
extension Timestamp: TimestampType {}

enum FirestoreError: Error {
    case decodeFailed
    case getPlistFailed
    case insertFailed
    case joinDemoGroupFailed
}

enum ActivityType: Int {
    case addMember = 0
    case addExpense = 1
}

struct Collection {
    static let user = "user"
    static let group = "group"
    
    struct User {
        static let groups = "groups"
        static let activity = "activity"
    }
    
    struct Group {
        static let expense = "expense"
        static let member = "member"
    }
}

struct UserInfo: Codable {
    var id: String!
    let name: String
    let email: String
    let phone: String?
    let photoURL: String
    var groups: [GroupInfo]!
}

struct UploadUserInfo: Codable {
    let name: String
    let email: String
    let phone: String?
    let photoURL: String
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
    let photoURL: String
    var status: Int
    
    init(userInfo: UserInfo, status: Int) {
        self.id = userInfo.id
        self.name = userInfo.name
        self.email = userInfo.email
        self.photoURL = userInfo.photoURL
        self.status = status
    }
}

struct Expense: Codable {
    var id: String?
    let type: Int
    let desc: String
    let userID: String
    let amount: Double
    let payerInfo: AmountInfo
    let splitInfo: AmountInfo
    let position: GeoPoint
    let time: Timestamp
    
    init(type: Int, desc: String, userID: String, amount: Double,
         payerInfo: AmountInfo, splitInfo: AmountInfo, location: CLLocationCoordinate2D, time: Date) {
        
        self.userID = userID
        self.type = type
        self.amount = amount
        self.desc = desc
        self.payerInfo = payerInfo
        self.splitInfo = splitInfo
        self.position = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        self.time = Timestamp(date: time)
        
    }
}

struct Activity: Codable {
    var id: String!
    let type: Int
    let status: Int
    let targetMember: MemberInfo
    let pushUser: UserInfo
    let groupInfo: GroupInfo?
    let amount: Double?
    let time: Timestamp
    
    init(type: Int,
         targetMember: MemberInfo,
         pushUser: UserInfo,
         groupInfo: GroupInfo?,
         amount: Double?,
         time: Date,
         status: Int) {
        
        self.type = type
        self.targetMember = targetMember
        self.pushUser = pushUser
        self.groupInfo = groupInfo
        self.amount = amount
        self.time = Timestamp(date: time)
        self.status = status
    }
}

enum ActivityStatus: Int {
    case new = 0
    case readed = 1
    case used = 2
}

class FirestoreManager {
    
    static let shared = FirestoreManager()
    
    var firestore = Firestore.firestore()
    
    var currentGroupID: String? {
        return UserInfoManager.shaered.currentGroupInfo?.id
    }
    
    var currentUid: String? {
        return UserInfoManager.shaered.currentUserInfo?.id
    }
    
    var currentGroupRef: DocumentReference? {
        guard let groupID = currentGroupID else { return nil }
        return firestore.collection(Collection.group).document(groupID)
    }
    
    var currentUserRef: DocumentReference? {
        guard let uid = currentUid else { return nil }
        return firestore.collection(Collection.user).document(uid)
    }
    
    func insertNewUser(userInfo: UserInfo, completion: @escaping (Result<GroupInfo, Error>) -> Void) {
        
        guard let docData = try? FirestoreEncoder().encode(userInfo) else { return }

        firestore.collection(Collection.user).document(userInfo.id).setData(docData) { error in
            
            if error != nil {
                completion(Result.failure(FirestoreError.insertFailed))
                return
            }
                    
        }
        
        FirestoreManager.shared.joinDemoGroup(uid: userInfo.id, completion: { result in
            switch result {
            case .success(var demoGroup):
                
                UserInfoManager.shaered.setCurrentGroupInfo(demoGroup)
                demoGroup.status = MemberStatusType.joined.rawValue
                completion(Result.success(demoGroup))
                
            case .failure:
                completion(Result.failure(FirestoreError.joinDemoGroupFailed))
            }
        })
    }
    
    func getUserInfo(completion: @escaping (Result<UserInfo?, Error>) -> Void) {
                
        currentUserRef?.getDocument { (querySnapshot, error) in
            
            guard let document = querySnapshot, let data = document.data()
            else {
                completion(Result.success(nil))
                return
            }
            
            do {
                var userInfo = try FirestoreDecoder().decode(UserInfo.self, from: data)
                userInfo.id = document.documentID
                
                self.getUserGroups(completion: { userGroups in
                    userInfo.groups = userGroups
                    completion(Result.success(userInfo))
                })
            
            } catch {
                completion(Result.failure(error))
            }
            
        }
        
        completion(Result.success(nil))
    }
    
    func getUserGroups(completion: @escaping ([GroupInfo]) -> Void) {
        
        currentUserRef?.collection(Collection.User.groups).addSnapshotListener { (querySnapshot, error) in
            
            if let documents = querySnapshot?.documents {
                var userGroups = [GroupInfo]()
                for document in documents {
                    do {
                        var userGroup = try FirestoreDecoder().decode(GroupInfo.self, from: document.data())
                        userGroup.id = document.documentID
                        userGroups.append(userGroup)
                    } catch {
                        print(error)
                    }
                }
                
                completion(userGroups)
            }
            
        }
    }
    
    func getExpenses(completion: @escaping (Result<[Expense], Error>) -> Void) {
        
        currentGroupRef?.collection(Collection.Group.expense).order(by: "time", descending: true).addSnapshotListener { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else { return }
            
            var expenses = [Expense]()
            
            for document in documents {
                do {
                    var expense = try FirestoreDecoder().decode(Expense.self, from: document.data())
                    expense.id = document.documentID
                    expenses.append(expense)
                } catch {
                    print(error)
                }
            }
            
            completion(Result.success(expenses))
            
        }
    }
    
    func getMembers(completion: @escaping (Result<[MemberInfo], Error>) -> Void) {
        
        currentGroupRef?.collection(Collection.Group.member).addSnapshotListener { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else { return }
            
            var members = [MemberInfo]()
            
            for document in documents {
                do {
                    var member = try FirestoreDecoder().decode(MemberInfo.self, from: document.data())
                    member.id = document.documentID
                    members.append(member)
                } catch {
                    print(error)
                }
            }
            
            completion(Result.success(members))
            
        }
        
        completion(Result.success([MemberInfo]()))
    }
    
    func addExpense(expense: Expense,
                    completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let docData = try? FirestoreEncoder().encode(expense) else { return }
        
        currentGroupRef?.collection(Collection.Group.expense).addDocument(data: docData) { (error) in
            if let error = error {
                completion(Result.failure(error))
            } else {
                completion(Result.success("success"))
            }
            
        }
    }
    
    func searchUser(email: String?,
                    phone: String?,
                    completion: @escaping (Result<UserInfo?, Error>) -> Void) {
        
        if email != nil {
            
            firestore.collection(Collection.user).whereField("email", isEqualTo: email!).getDocuments { (querySnapshot, error) in

                if error != nil {
                    return
                }
                
                guard let documents = querySnapshot?.documents, let document = documents.first
                else {
                    completion(Result.success(nil))
                    return
                }

                do {
                    var userInfo = try FirebaseDecoder().decode(UserInfo.self, from: document.data())
                    userInfo.id = document.documentID
                    completion(Result.success(userInfo))
                } catch {
                    print(error)
                }

            }
            
        } else if phone != nil {
            
        }
        
    }
    
    func addGroup(groupInfo: GroupInfo, members: [MemberInfo], completion: @escaping (Result<String, Error>) -> Void) {
        
        var reference: DocumentReference?
        
        guard let docData = try? FirestoreEncoder().encode(groupInfo) else { return }
        
        reference = firestore.collection(Collection.group).addDocument(data: docData) { [weak self] error in
            if error != nil {
                print(error)
            }
            
            guard let groupID = reference?.documentID else { return }
            
            let group = GroupInfo(id: groupID, name: groupInfo.name, coverURL: groupInfo.coverURL, status: 3)
            
            for member in members {
                var newMember = member
                if newMember.status == MemberStatusType.willInvite.rawValue {
                    newMember.status = MemberStatusType.inviting.rawValue
                }
                
                self?.addMember(group: group, memberInfo: newMember, isBuilder: newMember.status == MemberStatusType.builder.rawValue)
            }
            
            self?.joinGroup(group: group, completion: { _ in
                completion(Result.success(groupID))
            })
            
        }
        
    }

    func addMember(group: GroupInfo? = UserInfoManager.shaered.currentGroupInfo, memberInfo: MemberInfo, isBuilder: Bool = false) {
        
        guard let group = group,
            let docData = try? FirestoreEncoder().encode(memberInfo),
            let currentUserInfo = UserInfoManager.shaered.currentUserInfo
        else { return }
        firestore.collection(Collection.group).document(group.id).collection(Collection.Group.member).document(memberInfo.id).setData(docData)
            
        if !isBuilder {
            addActivity(type: ActivityType.addMember.rawValue,
                        targetMember: memberInfo,
                        pushUser: currentUserInfo,
                        groupInfo: group,
                        amount: nil)
        }

    }
    
    func updateGroupMemberStatus(groupID: String? = FirestoreManager.shared.currentGroupID, memberInfo: MemberInfo, status: MemberStatusType, completion: @escaping (Result<Int, Error>) -> Void) {
        
        let data = ["status": status.rawValue]
        
        guard let groupID = groupID else { return }
        
        firestore.collection(Collection.group).document(groupID).collection(Collection.Group.member).document(memberInfo.id).updateData(data) { error in
            
            if error != nil {
                print("Error updating document: \(error!)")
            }
            
            print("Document successfully updated")
        }
        
//        if status != .inviting {
//            self.updateUserGroupStatus(uid: memberInfo.id, status: status, completion: { _ in
//
//                guard let currentUserInfo = UserInfoManager.shaered.currentUserInfo,
//                    let currentGroupInfo = UserInfoManager.shaered.currentGroupInfo
//                else { return }
                
//                self.addActivity(type: ActivityType.addMember.rawValue,
//                                 targetMember: memberInfo,
//                                 pushUser: currentUserInfo,
//                                 groupInfo: currentGroupInfo,
//                                 amount: nil)
//            })
//        }
        
    }
    
    func updateUserGroupStatus(uid: String, status: MemberStatusType, completion: @escaping (Result<Int, Error>) -> Void) {
        
        guard let groupID  = currentGroupID else { return }
        
        let data = ["status": status.rawValue]
        
        firestore.collection(Collection.user).document(uid).collection(Collection.User.groups).document(groupID).updateData(data)

    }
    
    func joinGroup(group: GroupInfo, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let docData = try? FirestoreEncoder().encode(group),
        let groupID = group.id else { return }
        
        currentUserRef?.collection(Collection.User.groups).document(groupID).setData(docData) { error in
            
            if error != nil {
                completion(Result.failure(FirestoreError.insertFailed))
                return
            }
        }
        
        completion(Result.success(groupID))
    }
    
    func joinDemoGroup(uid: String, completion: @escaping (Result<GroupInfo, Error>) -> Void) {
        guard let demoGroupID = Bundle.main.object(forInfoDictionaryKey: "DemoGroupID") as? String,
            let demoGroupCoverURL = Bundle.main.object(forInfoDictionaryKey: "DemoGroupCoverURL") as? String
        else {
            completion(Result.failure(FirestoreError.getPlistFailed))
            return
        }
        
        let demoGroup = GroupInfo(id: demoGroupID,
                                  name: "九州行(範例)",
                                  coverURL: demoGroupCoverURL,
                                  status: MemberStatusType.joined.rawValue)

        guard let docData = try? FirestoreEncoder().encode(demoGroup) else { return }
    
        firestore.collection(Collection.user).document(uid).collection(Collection.User.groups).document(demoGroupID).setData(docData) { error in
             
            if error != nil {
                completion(Result.failure(FirestoreError.insertFailed))
                return
            }

            completion(Result.success(demoGroup))
        }
    }
    
    func addActivity(type: Int, targetMember: MemberInfo, pushUser: UserInfo, groupInfo: GroupInfo?, amount: Double?) {
        
        let activity = Activity(type: type, targetMember: targetMember, pushUser: pushUser, groupInfo: groupInfo, amount: amount, time: Date(), status: 0)
        
        guard let docData = try? FirestoreEncoder().encode(activity) else { return }
        firestore.collection(Collection.user).document(targetMember.id).collection(Collection.User.activity).addDocument(data: docData)
        
    }
    
    func getActivity(uid: String, completion: @escaping (Result<[Activity], Error>) -> Void) {
        
        firestore.collection(Collection.user).document(uid).collection(Collection.User.activity).order(by: "time", descending: true).addSnapshotListener { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else { return }
            
            var activities = [Activity]()
            
            for document in documents {
                do {
                    var activity = try FirestoreDecoder().decode(Activity.self, from: document.data())
                    activity.id = document.documentID
                    activities.append(activity)
                } catch {
                    print(error)
                }
            }
            completion(Result.success(activities))
        }
        
    }
    
    func updateActivityStatus(uid: String, id: String, status: ActivityStatus) {
        let data = ["status": status.rawValue]
        firestore.collection(Collection.user).document(uid).collection(Collection.User.activity).document(id).updateData(data)
    }
    
}

extension Timestamp {
    func toFullFormat() -> String {
        let date = self.dateValue()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    func toSimpleFormat() -> String {
        let date = self.dateValue()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M月dd日"
        return formatter.string(from: date)
    }
    
}
