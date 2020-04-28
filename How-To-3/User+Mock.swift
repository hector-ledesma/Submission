//
//  User+Mock.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/28/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation

let validUserJSON = """
{
  "id": 5,
  "username": "tim_the_enchanter",
  "password": "$2a$12$K4DW2jDwOORS5AN/qGYA..I.b1RZUBzqlIwpg2BJIIIBYASABTTAu",
  "email": "enchanter_tim@gmail.com"
}
""".data(using: .utf8)

let invalidUserJSON = """
{
  "id": ,
  "username": "tim_the_enchanter,
  "password": "$2a$12$K4DW2jDwOORS5AN/qGYA..I.b1RZUBzqlIwpg2BJIIIBYASABTTAu",
  "email": "enchanter_tim@gmail.com"
}
""".data(using: .utf8)

let validLoginJSON = """
{
    "username":"tim_the_enchanter",
    "password":"123abc"
}
""".data(using: .utf8)
