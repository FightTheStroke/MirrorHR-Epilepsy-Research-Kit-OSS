//import XCTest
//@testable import MirrorHRTelemetryPackage
//import Alamofire
//import RoberdanSecretsPackage
//
//final class MirrorHRTelemetryPackageTests: XCTestCase {
//    
//    func testGET() throws {
//        let expectation1 = self.expectation(description: "Hitting Telemetry in the cloud")
//        let expectation2 = self.expectation(description: "Hitting Telemetry in the cloud")
//
//        var cloudAPIResponse: CloudAPIGETResponse?
//        var wasSendSuccess: Bool = false
//        let cloudAPIManager = CloudAPIManager()
//        
//        // to secure there is at least one event sent before getting GET result
//        cloudAPIManager.sendMessageAsJson(.init(eventType: "TestGET", event: "test", value: "test")) {response in
//            switch response {
//            case .success:
//                wasSendSuccess = true
//            case .failure(let error):
//                print("error: \(error.localizedDescription)")
//            }
//            expectation1.fulfill()
//        }
//        
//        cloudAPIManager.get { result in
//            switch result {
//            case .success(let getResponse):
//                cloudAPIResponse = getResponse
//            case .failure:
//                break
//            }
//            expectation2.fulfill()
//        }
//       
//        wait(for: [expectation1], timeout: 30)
//        wait(for: [expectation2], timeout: 30)
//
//        XCTAssertEqual(wasSendSuccess, true)
//        XCTAssertNotEqual(cloudAPIResponse!.MessagesSent, 0)
//        XCTAssertNotEqual(cloudAPIResponse!.UpTime, "")
//    }
//    
//    func testPOSTJSON() throws {
//        let expectation = self.expectation(description: "Hitting Telemetry in the cloud")
//        var success: Bool = false
//        
//        let params: Parameters? = TelemetryMessage(eventType: "symptomsLogged", event: "sympt_seizure", value: "1").toDictionary()
//        let headers: HTTPHeaders = ["x-mr-uuid-auth": "hr-d13450bc-3abe-11ed-a261-0242ac120002" ]
//
//        AF.request(RoberdanSecretsPackage.hostJsonPost, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
//            .responseData { response in
//                guard let statusCode = response.response?.statusCode, statusCode == 201 else {
//                    return
//                }
//                print(statusCode)
//                if statusCode == 201 {
//                    success = true
//                }
//                expectation.fulfill()
//            }
//        wait(for: [expectation], timeout: 30)
//        XCTAssertEqual(success, true)
//    }
//        
//    func testCloudAPIManager() throws {
//        var resultCnt: Int = 0
//        let expectedResultCnt = 3
//        let cloudAPI = CloudAPIManager()
//        let expectation = self.expectation(description: "Hitting Telemetry in the cloud")
//        cloudAPI.sendMessageAsJson(.init(eventType: "Booting", event: "brandNewUser", value: "withWatch")) { _ in
//            resultCnt = 1
//            cloudAPI.sendMessageAsJson(.init(eventType: "Error", event: "error", value: CloudAPIManager.Errors.wrongMessageFormat.description)) { _ in
//                resultCnt = 2
//                cloudAPI.sendMessageAsJson(.init(eventType: "sympt_highBPM", event: "symptomsLogged", value: "1"), completion: { _ in
//                    resultCnt = 3
//                    expectation.fulfill()
//                })
//            }
//        }
//        wait(for: [expectation], timeout: 30)
//        XCTAssertEqual(resultCnt, expectedResultCnt)
//    }
//    
//    func testFullTelemetry() throws {
//        let telemetry = MirrorHRTelemetry.shared
//        let expectation = self.expectation(description: "Hitting Telemetry in the cloud")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            expectation.fulfill()
//        }
//        let done: Bool = true
////        telemetry.sendTelemetry(.symptomsLogged(symptom: "TestStymptom", value: "just a test"))
////        telemetry.sendTelemetry(.consensus(telemetry: Telemetries.dateOfBirth(birtDate: "").eventType, newValue: false))
////        telemetry.sendTelemetry(.booting(userType: .brandNewUser, value: "test booting"))
//        
//        // check logs on the cloudapi streams
//        wait(for: [expectation], timeout: 10)
//        XCTAssertEqual(done, true)
//    }
//    
//    func testCloudAPI() throws {
//        let expectation = self.expectation(description: "Hitting Telemetry in the cloud")
//        let cloudAPI = CloudAPIManager()
//        var cloudMainAPIResponse: CloudAPIResponse?
//        let telemetry = Telemetries.booting(userType: .returningUser, value: "Test Value")
//        let customType = telemetry.event
//        let value = telemetry.value
//        let telemetryMessage = TelemetryMessage(eventType: telemetry.eventType, event: customType, value: value)
//        cloudAPI.sendMessageAsJson(telemetryMessage) { result in
//            debugLog(String(describing: result))
//            switch result {
//            case .success(let cloudAPIResponse):
//                debugLog("Telemetry cloudAPiManager sendMessageAsJson with \(String(describing: cloudAPIResponse))")
//                cloudMainAPIResponse = cloudAPIResponse
//            case .failure(let error):
//                debugLog(error.localizedDescription, isImportant: true, module: "MirrorHRTelemetry - send - researchCloudAPI case - sendMessageAsJson")
//            }
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 10)
//        XCTAssertEqual(cloudMainAPIResponse?.result, MirrorHRTelemetryPackage.CloudAPIResponse.Results.success)
//    }
//    
//    func testBulkCloudAPIManager() throws {
//        var cloudApiResponseS: [CloudAPIResponse] = []
//        let cloudAPI = CloudAPIManager()
//        let expectation = self.expectation(description: "Hitting Telemetry in the cloud")
//
//        let expectedCnt = HandledSymptomsEvents.allPossibleSymptoms.count
//        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
//            expectation.fulfill()
//        }
//        
//        HandledSymptomsEvents.allPossibleSymptoms.forEach { sympt in
//            dispatchTelemetryEvent(event: .symptomsLogged(symptom: sympt.rawValue, localizedName: sympt.localizedString(), startDate: Date(), endDate: Date(), notes: "sample note"))
//            let telemetryMessage = TelemetryMessage(eventType: "sympt_seizure", event: sympt.rawValue, value: "test value")
//            cloudAPI.sendMessageAsJson(telemetryMessage) { response in
//                debugLog(String(describing: response))
//                switch response {
//                case .success(let cloudAPIResponse):
//                    debugLog(String(describing: cloudAPIResponse))
//                    if let cloudResp = cloudAPIResponse {
//                        cloudApiResponseS.append(cloudResp)
//                    }
//                case .failure(let error):
//                    debugLog(error.localizedDescription)
//                }
//            }
//        }
//       
//        // NON FUNZIA - LEGGERE I PRINT
//        wait(for: [expectation], timeout: 60)
//        debugLog("<------------Here are the cloud API Responses ---------------->")
//        debugLog(String(describing: cloudApiResponseS))
//        debugLog("<------------End of the cloud API Responses ---------------->")
//        XCTAssertEqual(cloudApiResponseS.count, expectedCnt)
//    }
//    
//    func testSendFile() throws {
//        let expectation = self.expectation(description: "Hitting Telemetry in the cloud")
//        let cloudAPI = CloudAPIManager()
//        var cloudAPIResponse: CloudAPIResponse?
//        cloudAPI.sendTestFile(fileModuleName: "first") { result in
//            switch result {
//            case .success:
//                cloudAPIResponse = CloudAPIResponse(result: .success, response: nil)
//            case .failure(let error):
//                print(error)
//            }
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 30)
//        XCTAssertEqual(cloudAPIResponse!.result, CloudAPIResponse.Results.success)
//    }
//    
//    enum HandledSymptomsEvents: String, CaseIterable, Codable, Comparable, Hashable {
//        static func < (lhs: HandledSymptomsEvents, rhs: HandledSymptomsEvents) -> Bool {
//            lhs.localizedString() < rhs.localizedString()
//        }
//        
//        case none = "sympt_emptySymptom"
//        case realTimeSession = "event_realTimeSession"
//        case seizure = "sympt_seizure"
//        case oldSeizure = "Seizure"
//        case highBPM = "sympt_highBPM"
//        case lowBPM = "sympt_lowBPM"
//        case constipation = "sympt_constipation"
//        case diarrhea = "sympt_diarrhea"
//        case hiccup = "sympt_hiccup"
//        case dizziness = "sympt_dizziness"
//        case fatigue = "sympt_fatigue"
//        case fever = "sympt_fever"
//        case headache = "sympt_headache"
//        case medicalExamination = "sympt_medicalExamination"
//        case hospitalization = "sympt_hospitalization"
//        case emergencyRoom = "sympt_emergencyRoom"
//        case coughing = "sympt_coughing"
//        case nausea = "sympt_nausea"
//        case shortnessOfBreath = "sympt_shortnessOfBreath"
//        case soreThroat = "sympt_soreThroat"
//        case vomiting = "sympt_vomiting"
//        case excitement = "sympt_excitement"
//        case moodChanges = "sympt_moodChanges"
//        case medicationChange = "sympt_medicationChange"
//        case sleepChanges = "sympt_sleepChanges"
//        case sleepDeprivation = "sympt_sleepDeprivation"
//        case appetiteChanges = "sympt_appetiteChanges"
//        case videoLog = "sympt_videoLog"
//        case videoSeizureLog = "sympt_videoSeizureLog"
//        case oldVideoSeizureLog = "Seizure Log"
//        case textLog = "sympt_textLog"
//        case stress = "sympt_stress"
//        case medicationTaken = "sympt_medicationTaken"
//        case medicationForgotten = "sympt_medicationForgotten"
//        case cold = "sympt_cold"
//        case other = "sympt_other"
//        case emergencyMedication = "sympt_emergencyMedication"
//        case filter = "sympt_FilterSupport"
//        case all = "allLogs"
//        case byDate = "filterByDate"
//        case therapy = "sympt_therapy"
//        case fall = "sympt_fall"
//        case headShot = "sympt_headShot"
//        case sport = "sympt_sport"
//        case vaccine = "sympt_vaccine"
//        case covidVaccine = "sympt_covidVaccine"
//        case covid = "sympt_covid"
//        case otherMedications = "sympt_other_medications"
//        case absence = "sympt_absence"
//        case dermatitis = "sympt_dermatitis"
//        case menses = "sympt_menses"
//        case toothache = "sympt_toothache"
//        
//        func localizedString() -> String {
//            NSLocalizedString(self.rawValue, comment: "")
//        }
//        
//        public var value: String {
//            return self.rawValue
//        }
//        
//        static var allPossibleSymptoms: [HandledSymptomsEvents] {
//            let reservedEvents: [HandledSymptomsEvents] = [.none, .videoLog, .videoSeizureLog, .textLog,
//                                                           .oldSeizure, .oldVideoSeizureLog, .filter,
//                                                           .byDate, .all, .realTimeSession]
//            
//            var returnArray: [HandledSymptomsEvents] = []
//            HandledSymptomsEvents.allCases
//                .filter { symptom -> Bool in
//                    !reservedEvents.contains(symptom)
//                }
//                .forEach { symptom in
//                    returnArray.append(symptom)
//                }
//            
//            return returnArray.sorted { lhs, rhs -> Bool in
//                if lhs.fastLaneInt == 1, rhs.fastLaneInt != 1 {
//                    return true
//                }
//                if lhs.fastLaneInt != 1, rhs.fastLaneInt == 1 {
//                    return false
//                }
//                return lhs.localizedString() < rhs.localizedString()
//            }
//        }
//        
//        static var allPossibleSymptomsLocalized: [String] {
//            allPossibleSymptoms.map { sympt in
//                sympt.localizedString()
//            }
//        }
//        
//        var fastLaneInt: Int {
//            switch self {
//            case .seizure, .medicationTaken, .medicationForgotten, .emergencyMedication: return 1
//            default: return 2
//            }
//        }
//    }
//}
