//
//  LocalStorage.swift
//  Raja
//
//  Created by HTS-MAC on 14/06/22.
//

import UIKit
import SQLite3
import FMDB
import SwiftyJSON

var db: OpaquePointer?

let dbPath: String = "raja.sqlite"

let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    .appendingPathComponent(dbPath)

var database = FMDatabase(url:fileURL)

class LocalStorage {
    
    static let sharedInstance = LocalStorage()
    let viewModel = recentViewModel()
    
    // create db
    func createDB()  {
        //opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
            print("!error opening database")
        }
    }
    
    //create all tables
    func createTable()  {
        //creating table for RECENT_POST
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS RECENT_POST (postId VARCHAR(40) PRIMARY KEY,posterUserName TEXT,posterName TEXT,posterImage TEXT, postTime TEXT,suggestedType TEXT,suggestedBy TEXT,likeCount TEXT DEFAULT '0',resharedCount TEXT DEFAULT '0',liked TEXT,reshared TEXT,postType TEXT,composedDetail TEXT,composedImage_url TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        //creating table for OWN_POST
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS OWN_POST (postId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,posterUserName TEXT,posterName TEXT,posterImage TEXT, postTime TEXT,suggestedType TEXT,suggestedBy TEXT,likeCount TEXT DEFAULT '0',resharedCount TEXT DEFAULT '0',liked TEXT,reshared TEXT,postType TEXT,composedDetail TEXT,composedImage_url TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        //creating table for USERS
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS USERS (userName VARCHAR(40) PRIMARY KEY,name TEXT,userImageUrl TEXT,bio TEXT, link TEXT,joinDate TEXT,followingCount TEXT,followersCount TEXT,following TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK){
            
        }
    }
    
    func savePost(recent: PostsModel){
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            let queryString = "INSERT OR REPLACE INTO RECENT_POST (postId, posterUserName,posterName,posterImage,postTime,suggestedType,suggestedBy,likeCount,resharedCount,liked,reshared,postType,composedDetail,composedImage_url) VALUES ('\(recent.postID)',\"\(recent.postedBy.userName)\",\"\(recent.postedBy.name)\",'\(recent.postedBy.userImageURL)','\(recent.postType)','\(recent.suggestedType)','\(recent.suggestedBy)','\(recent.likeCount)','\(recent.resharedCount)','\(recent.liked)','\(recent.reshared)','\(recent.postType)',\"\(recent.composedDetail)\",'\(recent.composedImageURL)');"
            print("myyy SQL QUERY : \(queryString)")
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg =  String(cString: sqlite3_errmsg(db)!)
            print("error closing database \(errmsg)")
        }
        //        db = nil
    }
    
    
    // GET OVER ALL RECENT POSTS FORM THE LOCAL STORAGE
    func getAllPosters() -> JSON {
        let resultArray = NSMutableArray()
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM RECENT_POST"
            print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let result = NSMutableDictionary()
                    result.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "post_id")
                    let userDict = NSMutableDictionary()
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "user_name")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "name")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "user_image_url")
                    
                    result.setValue(userDict, forKey: "posted_by")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "posted_time")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "suggested_type")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "suggested_by")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "like_count")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "reshared_count")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "liked")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "reshared")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "post_type")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "composed_detail")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "composed_image_url")
                    resultArray.add(result)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        let  jsonDict = NSMutableDictionary()
        if resultArray.count != 0{
            jsonDict.setValue(200, forKey: "status_code")
            jsonDict.setValue(resultArray, forKey: "result")
        } else{
            jsonDict.setValue(500, forKey: "status_code")
            jsonDict.setValue(NSMutableArray(), forKey: "result")
        }
        print("!QWER\(JSON(jsonDict))")
        return JSON(jsonDict)
    }
    
    // GET SPECIFIC POST USING user name
    func getSpeficPost(username: String) -> JSON {
        let resultArray = NSMutableArray()
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM RECENT_POST WHERE posterUserName = '\(username)'"
            print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let result = NSMutableDictionary()
                    result.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "post_id")
                    let userDict = NSMutableDictionary()
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "user_name")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "name")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "user_image_url")
                    
                    result.setValue(userDict, forKey: "posted_by")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "posted_time")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "suggested_type")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "suggested_by")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "like_count")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "reshared_count")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "liked")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "reshared")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "post_type")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "composed_detail")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "composed_image_url")
                    resultArray.add(result)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        let  jsonDict = NSMutableDictionary()
        if resultArray.count != 0{
            jsonDict.setValue(200, forKey: "status_code")
            jsonDict.setValue(resultArray, forKey: "result")
        } else{
            jsonDict.setValue(500, forKey: "status_code")
            jsonDict.setValue(NSMutableArray(), forKey: "result")
        }
        print("!QWER\(JSON(jsonDict))")
        return JSON(jsonDict)
    }
    
    
    //MARK: -UPDATE LIKE
    func updateLike(post_id:String,liked:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            let queryString = "UPDATE RECENT_POST SET liked = '\(liked)' WHERE postId = '\(post_id)';"
            
            print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg =  String(cString: sqlite3_errmsg(db)!)
            print("error closing database \(errmsg)")
        }
        //        db = nil
    }
    
    //MARK: -UPDATE SHARE
    func updateShare(post_id:String,shared:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            let queryString = "UPDATE RECENT_POST SET reshared = '\(shared)' WHERE postId = '\(post_id)';"
            
            print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg =  String(cString: sqlite3_errmsg(db)!)
            print("error closing database \(errmsg)")
        }
        //        db = nil
    }
    
}

//MARK: FOR USER ACCOUNT MAITANCE
extension LocalStorage{
    
    // GET OVER ALL USERS FORM THE LOCAL STORAGE
    func getAllUsers() -> JSON {
        let resultArray = NSMutableArray()
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM USERS"
            print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let result = NSMutableDictionary()
                    
                    result.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "user_name")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "name")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "user_image_url")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "bio")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "link")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "join_date")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "following_count")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "followers_count")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "following")
                    resultArray.add(result)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        let  jsonDict = NSMutableDictionary()
        if resultArray.count != 0{
            jsonDict.setValue(200, forKey: "status_code")
            jsonDict.setValue(resultArray, forKey: "users_detail")
        } else{
            jsonDict.setValue(500, forKey: "status_code")
            jsonDict.setValue(NSMutableArray(), forKey: "users_detail")
        }
        print("!USERS_FROM_LOCAL\(JSON(jsonDict))")
        return JSON(jsonDict)
    }
    
    func getUser(userName: String) -> JSON {
        let resultArray = NSMutableArray()
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT * FROM USERS WHERE userName = '\(userName)'"
            print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let result = NSMutableDictionary()
                    
                    result.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "user_name")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "name")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "user_image_url")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "bio")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "link")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "join_date")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "following_count")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "followers_count")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "following")
                    resultArray.add(result)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        let  jsonDict = NSMutableDictionary()
        if resultArray.count != 0{
            jsonDict.setValue(200, forKey: "status_code")
            jsonDict.setValue(resultArray, forKey: "users_detail")
        } else{
            jsonDict.setValue(500, forKey: "status_code")
            jsonDict.setValue(NSMutableArray(), forKey: "users_detail")
        }
        print("!USERS_FROM_LOCAL\(JSON(jsonDict))")
        return JSON(jsonDict)
    }
    
    func storeUserDetatils(userDetail: UsersDetailModel){
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            
            let queryString = "INSERT OR REPLACE INTO USERS (userName, name,userImageUrl,bio,link,joinDate,followingCount,followersCount,following) VALUES ('\(userDetail.userName)',\"\(userDetail.name)\",\"\(userDetail.userImageURL)\",\"\(userDetail.bio)\",'\(userDetail.link)','\(userDetail.joinDate)','\(userDetail.followingCount)','\(userDetail.followersCount)','\(userDetail.following)');"
            print("myyy SQL QUERY : \(queryString)")
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg =  String(cString: sqlite3_errmsg(db)!)
            print("error closing database \(errmsg)")
        }
        //        db = nil
    }
    
    //MARK: -UPDATE LIKE
    func updateFollwing(userName:String,following:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            //                        let queryString = "DELETE FROM USERS"
            let queryString = "UPDATE USERS SET following = '\(following)' WHERE userName = '\(userName)';"
            
            print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg =  String(cString: sqlite3_errmsg(db)!)
            print("error closing database \(errmsg)")
        }
        //        db = nil
    }
}
extension LocalStorage{
    // GET OVER ALL RECENT POSTS FORM THE LOCAL STORAGE
    func getAllOwnPost() -> JSON {
        let resultArray = NSMutableArray()
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT * FROM OWN_POST ORDER BY postId Desc"
            
            print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let result = NSMutableDictionary()
                    
                    result.setValue(String(sqlite3_column_int64(stmt, 0)), forKey: "post_id")
                    let userDict = NSMutableDictionary()
                    
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "user_name")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "name")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "user_image_url")
                    
                    result.setValue(userDict, forKey: "posted_by")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "posted_time")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "suggested_type")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "suggested_by")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "like_count")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "reshared_count")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "liked")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "reshared")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "post_type")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "composed_detail")
                    result.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "composed_image_url")
                    resultArray.add(result)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        let  jsonDict = NSMutableDictionary()
        if resultArray.count != 0{
            jsonDict.setValue(200, forKey: "status_code")
            jsonDict.setValue(resultArray, forKey: "result")
        } else{
            jsonDict.setValue(500, forKey: "status_code")
            jsonDict.setValue(NSMutableArray(), forKey: "result")
        }
        print("!QWER\(JSON(jsonDict))")
        return JSON(jsonDict)
    }
    
    func saveOwnPost(recent: PostsModel){
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            let queryString = "INSERT OR REPLACE INTO OWN_POST (posterUserName,posterName,posterImage,postTime,suggestedType,suggestedBy,likeCount,resharedCount,liked,reshared,postType,composedDetail,composedImage_url) VALUES (\"\(recent.postedBy.userName)\",\"\(recent.postedBy.name)\",'\(recent.postedBy.userImageURL)','\(recent.postType)','\(recent.suggestedType)','\(recent.suggestedBy)','\(recent.likeCount)','\(recent.resharedCount)','\(recent.liked)','\(recent.reshared)','\(recent.postType)',\"\(recent.composedDetail)\",'\(recent.composedImageURL)');"
            print("myyy SQL QUERY : \(queryString)")
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg =  String(cString: sqlite3_errmsg(db)!)
            print("error closing database \(errmsg)")
        }
        //        db = nil
    }
    
    //MARK: -UPDATE LIKE
    func updateOwnPostLike(post_id:String,liked:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            let queryString = "UPDATE OWN_POST SET liked = '\(liked)' WHERE postId = \(post_id);"
            
            print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg =  String(cString: sqlite3_errmsg(db)!)
            print("error closing database \(errmsg)")
        }
        //        db = nil
    }
    
    //MARK: -UPDATE SHARE
    func updateOwnPostShare(post_id:String,shared:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(fileURL.path, &db)==SQLITE_OK)
        {
            let queryString = "UPDATE OWN_POST SET reshared = '\(shared)' WHERE postId = \(post_id);"
            
            print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg =  String(cString: sqlite3_errmsg(db)!)
            print("error closing database \(errmsg)")
        }
        //        db = nil
    }
}

