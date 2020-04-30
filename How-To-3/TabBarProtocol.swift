//
//  TabBarProtocol.swift
//  How-To-3
//
//  Created by Bhawnish Kumar on 4/29/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation


protocol PostPresenter: class {
    var backendController: BackendController? { get set }
}
