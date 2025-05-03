//// The Swift Programming Language
//// https://docs.swift.org/swift-book
//
//import SwiftUI
//import SwiftData
//import UserNotifications
//
//@available(iOS 17, *)
//// Define your models
//@Model final class TherapyList: Identifiable {
//    @Attribute(.unique) var id: UUID = UUID()
//    var therapies: [Therapy] = []
//    
//    public init() { }
//}
//
//@available(iOS 17, *)
//@Model final class Therapy: Identifiable {
//    @Attribute(.unique) var id: UUID = UUID()
//    var name: String = ""
//    var startDate: Date = Date()
//    var endDate: Date = Date()
//    var routines: [Routine] = []
//    
//    public init(name: String, startDate: Date, endDate: Date, routines: [Routine]) {
//        self.id = UUID()
//        self.name = name
//        self.startDate = startDate
//        self.endDate = endDate
//        self.routines = routines
//    }
//    
//    static var preview: Therapy {
//        Therapy(name: "preview", startDate: Date(), endDate: Date(), routines: [])
//    }
//    
//}
//@available(iOS 17, *)
//@Model final class Routine: Identifiable {
//    @Attribute(.unique) var id: UUID = UUID()
//    var name: String = ""
//    var reminder: Date = Date()
//    var comment: String = ""
//    var medications: [Medication] = []
//    public init() { }
//}
//@available(iOS 17, *)
//@Model class Medication: Identifiable {
//    @Attribute(.unique) var id: UUID = UUID()
//    var name: String = ""
//    var unit: String = ""
//    var shape: String = ""
//    var quantity: Int = 0
//    public init() { }
//}
//
//// Create ViewModel for managing TherapyList
//@available(iOS 17, *)
//class TherapyListViewModel: ObservableObject {
//    @Published var therapyList: TherapyList
//    
//    init(therapyList: TherapyList) {
//        self.therapyList = therapyList
//    }
//    
//    func addTherapy(_ therapy: Therapy) {
//        therapyList.therapies.append(therapy)
//    }
//    
//    func deleteTherapy(at indexSet: IndexSet) {
//        therapyList.therapies.remove(atOffsets: indexSet)
//    }
//    
//    func updateTherapy(at index: Int, with therapy: Therapy) {
//        therapyList.therapies[index] = therapy
//    }
//}
//
//// Main View
//@available(iOS 17, *)
//struct SmartTherapyHomeView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query(sort: \Therapy.startDate, order: .forward)
//    var therapies: [Therapy]
//    
//    @State private var showAddTherapy = false
//    @State private var selection: Therapy?
//    @State private var path: [Therapy] = []
//    
//    var body: some View {
//        NavigationSplitView {
//            List(selection: $selection) {
//                ForEach(therapies) { therapy in
//                    Text(therapy.name)
//                        .swipeActions(edge: .trailing) {
//                            Button(role: .destructive) {
//                                deleteTherapy(therapy)
//                            } label: {
//                                Label("Delete", systemImage: "trash")
//                            }
//                        }
//                }
//                .onDelete(perform: deleteTrips(at:))
//            }
//            .overlay {
//                if therapies.isEmpty {
//                    ContentUnavailableView {
//                         Label("No therapy", systemImage: "car.circle")
//                    } description: {
//                         Text("New therapies you create will appear here.")
//                    }
//                }
//            }
//            .navigationTitle("Upcoming therapies")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    EditButton()
//                        .disabled(therapies.isEmpty)
//                }
//                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                    Spacer()
//                    Button {
//                        showAddTherapy = true
//                    } label: {
//                        Label("Add trip", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            if let selection = selection {
//                NavigationStack {
//                    Text(selection.name)
//                }
//            }
//        }
//        .sheet(isPresented: $showAddTherapy) {
//            NavigationStack {
//                Form {
//                    
//                }
//            }
//            .presentationDetents([.medium, .large])
//        }
//    }
//    
//    private func deleteTrips(at offsets: IndexSet) {
//        withAnimation {
//            offsets.map { therapies[$0] }.forEach(deleteTherapy)
//        }
//    }
//    
//    private func deleteTherapy(_ therapy: Therapy) {
//        /**
//         Unselect the item before deleting it.
//         */
//        if therapy.persistentModelID == selection?.persistentModelID {
//            selection = nil
//        }
//        modelContext.delete(therapy)
//    }
//}
//
///**
// Preview sample data.
// */
//@available(iOS 17, *)
//actor PreviewSampleData {
//
//    @MainActor
//    static var container: ModelContainer = {
//        return try! inMemoryContainer()
//    }()
//
//    static var inMemoryContainer: () throws -> ModelContainer = {
//        let schema = Schema([Therapy.self])
//        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try! ModelContainer(for: schema, configurations: [configuration])
//        let sampleData: [any PersistentModel] = [
//            Therapy.preview
//        ]
//        Task { @MainActor in
//            sampleData.forEach {
//                container.mainContext.insert($0)
//            }
//        }
//        return container
//    }
//}
//
//
//@available(iOS 17, *)// Reminder scheduling function
//func scheduleReminder(for time: Date) {
//    let content = UNMutableNotificationContent()
//    content.title = "Medication Reminder"
//    // ... other notification setup
//
//    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,], from: time)
//    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//
//    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//}
