//
//  SonusLiveActivity.swift
//  Sonus
//
//  Created by NH Duc on 23/2/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SonusAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SonusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SonusAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SonusAttributes {
    fileprivate static var preview: SonusAttributes {
        SonusAttributes(name: "World")
    }
}

extension SonusAttributes.ContentState {
    fileprivate static var smiley: SonusAttributes.ContentState {
        SonusAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SonusAttributes.ContentState {
         SonusAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SonusAttributes.preview) {
   SonusLiveActivity()
} contentStates: {
    SonusAttributes.ContentState.smiley
    SonusAttributes.ContentState.starEyes
}
