import SwiftUI

struct Create: View {
    @State private var name = ""
    var add: (String) -> Void
    
    var body: some View {
        VStack {
            Text("Create.title")
                .font(.caption)
            
            TextField("Create.new", text: $name)
            
            Button(action: {
                self.add(self.name)
            }) {
                Text("Create.add")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
            }
            .background(Color("halo"))
            .cornerRadius(4, antialiased: true)
        }
    }
}
