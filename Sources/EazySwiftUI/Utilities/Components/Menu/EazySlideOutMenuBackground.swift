import SwiftUI

struct EazySlideOutMenuBackground: View {
    let color: Color?

    var body: some View {
        if let color {
            color
        } else {
            Rectangle()
                .fill(.background)
        }
    }
}
