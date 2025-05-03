//
//  MyFileClass.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 09/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SharedPkg

class MyFile: Codable {
    var userID: String = NILSTRING
    var filename: String = NILSTRING
    var localFileName: String = NILSTRING
    var localFileNameWithDate: String = NILSTRING
    var localFullPathWithDate: URL = getDocumentsDirectory()
    var ext: String = NILSTRING
    var savedLocally: Bool = false
    var content: String = NILSTRING
    var fileType: MirrorHRFileTypes = .unclassified
    var dateFile = Date()

    // it always add the date to the filename
    init(content: String?, userID: String, filename: String, ext: String, fileType: MirrorHRFileTypes) {
        self.userID = userID
        dateFile = Date()
        self.ext = ext
        self.fileType = fileType
        self.filename = filename
        localFileName = "\(filename).\(ext)"
        localFileNameWithDate = "\(filename)-\(dateFile.returnFileName()).\(ext)"
        localFullPathWithDate = getDocumentsDirectory().appendingPathComponent(localFileNameWithDate)
        self.content = content ?? NILSTRING
        savedLocally = false
    }

    init(filename: String, userID: String, ext: String, fileType: MirrorHRFileTypes) {
        self.userID = userID
        self.ext = ext
        dateFile = Date()
        self.fileType = .unclassified
        self.filename = filename
        localFileName = "\(filename).\(ext)"
        localFileNameWithDate = "\(filename)-\(dateFile.returnFileName()).\(ext)"
        localFullPathWithDate = getDocumentsDirectory().appendingPathComponent(localFileNameWithDate)
        content = NILSTRING
        savedLocally = false
    }

    func save() -> Bool {
        do {
            try content.write(to: localFullPathWithDate, atomically: true, encoding: String.Encoding.utf8)
            mainDebugger.append("File saved on  \(localFullPathWithDate)", .justALog)
            savedLocally = true
        } catch {
            mainDebugger.append("I'm sorry I was not able to save the File :( - Error: \(error)", .error, sourceModule: "MyFile save")
            savedLocally = false
        }
        return (savedLocally)
    }
}
