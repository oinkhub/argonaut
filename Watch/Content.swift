import SwiftUI

struct Content: View {
    @ObservedObject var places: Places
    @State private var creating = false
    var add: (String) -> Void
    var delete: (IndexSet) -> Void

    var body: some View {
        List {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .padding(.leading, 5)
                    .foregroundColor(Color("halo"))
                
                Text(.init("Main.add"))
                    .padding(.leading, 2)
            }
            .onTapGesture {
                self.creating.toggle()
            }
            
            Section(header: Text(.init("Main.header"))) {
                ForEach(places.session?.items ?? [], id: \.self) { item in
                    NavigationLink(destination: Navigate(places: self.places, item: item)) {
                        Text(item.name)
                    }
                }.onDelete(perform: delete)
            }
        }
        .sheet(isPresented: $creating) {
            Create {
                self.add($0)
                self.creating.toggle()
            }
        }
        .alert(isPresented: $places.error) {
            Alert(title: Text("Main.alert"), message: Text(self.places.message), dismissButton:
                .default(Text("Main.continue")) {
                    self.places.error = false
                }
            )
        }
        .navigationBarTitle("Main.title")
    }
}
