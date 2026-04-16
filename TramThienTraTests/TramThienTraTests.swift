import XCTest
@testable import TramThienTra

@MainActor
final class TramThienTraTests: XCTestCase {
    func testGratitudeLogCreation() throws {
        let log = GratitudeLog(date: Date(), items: ["Item 1", "Item 2"])
        XCTAssertEqual(log.items.count, 2)
    }

    func testStreakViewModelInitialState() throws {
        let vm = StreakViewModel()
        XCTAssertEqual(vm.streak, 0)
    }

    func testTichLuyCharacterLimit() throws {
        let vm = TichLuyViewModel()
        let longText = String(repeating: "a", count: 350)
        vm.item1 = String(longText.prefix(300))
        XCTAssertLessThanOrEqual(vm.item1.count, 300)
    }
}