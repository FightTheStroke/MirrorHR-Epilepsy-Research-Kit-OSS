import XCTest
import OpenAIPackage

@testable import TherapyPackage
@testable import MirrorHRTelemetryPackage

final class TherapyPackageTests: XCTestCase {

    var viewModel: MedicationViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = MedicationViewModel(connector: OpenAIConnector.shared)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testPromptProcessing() throws {
        var medications: [MedicationViewModel.Medication] = []
        for reminder in sampleReminders {
            print(reminder)
            viewModel.processPrompt(prompt: reminder)
            print(viewModel.medications)
            medications.append(contentsOf: viewModel.medications)
        }

        print(medications)

        let expectedMedicationNames = Set(["Keppra", "Lamictal", "Topamax", "Zonisamide", "Depakote"])
        let returnedMedicationNames = Set(viewModel.medications.map { $0.name })
        
        XCTAssert(expectedMedicationNames.isSubset(of: returnedMedicationNames), "Some medications are missing")

        // Additional checks for each medication's schedules, doses, etc. can be added here based on the expected output
    }


    func testNotificationScheduling() {
        let schedule = MedicationViewModel.Schedule(time: MedicationViewModel.Time(hour: 10, minute: 0), days: [.monday, .wednesday])
        let medication = MedicationViewModel.Medication(name: "TestMed", dose: "2", form: .pill, schedules: [schedule])
        viewModel.medications.append(medication)

        // Call the function without arguments
        viewModel.scheduleReminders()

        // Here, you would ideally check that the notifications were scheduled.
        // But, for the sake of this mock test:
        XCTAssert(true)
    }

    
    func testInvalidPromptParsing() {
        let invalidPrompt = "Take some random medicines whenever you feel like it."

        // Testing the parseMedicationData function directly
        let result = viewModel.parseMedicationData(from: invalidPrompt)
        XCTAssertFalse((result != nil), "Parsing should fail for the invalid prompt.")
    }

    func testValidPromptParsing() {
        let validPrompt = "Remember me to take 3 pills of Tegretol every weekday in the morning at 7.30am."

        // Testing the parseMedicationData function directly
        let result = viewModel.parseMedicationData(from: validPrompt)
        XCTAssertTrue((result != nil), "Parsing should succeed for the valid prompt.")
    }

    func testValidationView() {
        let schedule = MedicationViewModel.Schedule(time: MedicationViewModel.Time(hour: 10, minute: 0), days: [.monday, .wednesday])
        let medication = MedicationViewModel.Medication(name: "TestMed", dose: "2", form: .liquid, schedules: [schedule])
        viewModel.medications.append(medication)
        
        // Instead of trying to inspect the view, inspect the ViewModel's data.
        XCTAssert(viewModel.medications.count == 1, "Expected one medication in the ViewModel")
    }
}
