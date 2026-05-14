//
//  SonusBundle.swift
//  Sonus
//
//  Created by NH Duc on 23/2/26.
//

import WidgetKit
import SwiftUI

@main
struct SonusBundle: WidgetBundle {
    var body: some Widget {
        Sonus()
        SonusControl()
        SonusLiveActivity()
    }
}
