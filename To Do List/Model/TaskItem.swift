//
//  TaskItem.swift
//  To Do List
//
//  Created by Petar Iliev on 26.6.22.
//

import Foundation

struct TaskItem: Encodable {
    var text: String = ""
    var checked: Bool = false
}
