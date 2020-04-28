//
//  Post+Mock.swift
//  How-To-3
//
//  Created by Karen Rodriguez on 4/28/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation

let validHowToJSON = """
[
  {
    "id": 3,
    "title":"Edgar's first how-to post",
    "post":"Instructions will go in here.",
    "created_at": "2020-04-28 00:58:30",
    "user_id": 1
  }
]
""".data(using: .utf8)

let invalidHowToJSON = """
[
  {
    "id": ,
    "title":"Edgar's first how-to post,
    "post":"Instructions will go in here.",
    "created_at": "2020-04-28 00:58:30",
    "user_id": 1
  }
]
""".data(using: .utf8)


