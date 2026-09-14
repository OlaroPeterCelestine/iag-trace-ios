import XCTest
@testable import TraceCore

final class RbacTests: XCTestCase {
    private func store() -> TraceStore {
        let s = TraceStore(persistence: MemoryKeyValueStore())
        s.load()
        return s
    }

    func testAgentLoginAndLotLookup() {
        let s = store()
        XCTAssertNil(s.login("agent", demoPassword))
        XCTAssertTrue(s.isSignedIn)
        XCTAssertTrue(s.isAgent)
        XCTAssertEqual(s.lookup("IAG-LOT-00421")?.farmer, "Nakato Grace")
    }

    func testFarmerLoginScopesToNakato() {
        let s = store()
        XCTAssertNil(s.login("farmer", demoPassword))
        XCTAssertFalse(s.isAgent)
        XCTAssertEqual(s.myFarmer?["name"], "Nakato Grace")
        XCTAssertTrue(s.scoped("farms").allSatisfy { $0["farmer"] == "Nakato Grace" })
        XCTAssertFalse(s.visibleRoutes().contains { $0.id == "register" })
        XCTAssertFalse(s.visibleRoutes().contains { $0.id == "agents" })
        XCTAssertTrue(s.visibleRoutes().contains { $0.id == "portal" })
        XCTAssertTrue(s.visibleRoutes().contains { $0.id == "lookup" })
    }

    func testSupplierPortalSeesNamuliRecords() {
        let s = store()
        XCTAssertNil(s.login("supplier", demoPassword))
        XCTAssertTrue(s.isPortal)
        XCTAssertEqual(s.myFarmer?["name"], "Namuli Sarah")
        XCTAssertTrue(s.scoped("batches").contains { $0["code"] == "BATCH-0001" })
    }

    func testWebFeatureCatalogIsOnThePhone() {
        let ids = Set(traceRoutes.map(\.id))
        for id in ["farmers", "intake", "batches", "chain", "qr", "lab", "compliance", "reports", "payments", "map", "hub", "portal", "admin"] {
            XCTAssertTrue(ids.contains(id), id)
        }
        for key in ["farmers", "batches", "qr-stories", "lab-results", "shipments", "harvest-lots", "field-inspections"] {
            XCTAssertNotNil(entities[key], key)
        }
    }

    func testIntakeHarvestRequestAndBatchAdvance() {
        let s = store()
        s.login("admin", demoPassword)
        let farmer = s.intakeFarmer(
            kind: "Farm", name: "Test Grower", phone: "0700000000", village: "Kyanamukaka",
            district: "Masaka", variety: "SL14", acres: "1", gps: "-0.34, 31.73", bio: "Demo bio",
            gross: "100", tare: "5", moisture: "12"
        )
        XCTAssertTrue(farmer?["code"].hasPrefix("FRM-") == true)
        XCTAssertTrue(s.farms.contains { $0["farmer"] == "Test Grower" })
        XCTAssertTrue(s.batches.contains { $0["farmer"] == "Test Grower" && $0["stage"] == "Intake" })

        let batch = s.batches.first { $0["code"] == "BATCH-0002" }!
        XCTAssertEqual(normalizeStage(batch["stage"]), "Intake")
        s.advanceBatch(batch.id)
        XCTAssertEqual(s.byId("batches", batch.id)?["stage"], "Wet mill")

        s.logout()
        s.login("farmer", demoPassword)
        s.requestHarvest(volumeKg: 50, notes: "Ready tomorrow")
        XCTAssertTrue(s.scoped("harvest-requests").contains { $0["farmer"] == "Nakato Grace" && $0["volumeKg"] == "50" })
    }

    func testQrPublishIsGatedLikeTheWebDesk() {
        let s = store()
        s.login("admin", demoPassword)
        XCTAssertNotNil(s.publishQr("qr-1"))
    }

    func testPortalCannotIntakeAndStaffCannotRequestHarvest() {
        let s = store()
        s.login("farmer", demoPassword)
        XCTAssertNil(s.intakeFarmer(
            kind: "Farm", name: "Blocked", phone: "0700", village: "X", district: "Masaka",
            variety: "SL14", acres: "1", gps: "", bio: "", gross: "10", tare: "0", moisture: "12"
        ))
        XCTAssertFalse(s.farmers.contains { $0["name"] == "Blocked" })

        s.logout()
        s.login("agent", demoPassword)
        s.requestHarvest(volumeKg: 10, notes: "no")
        XCTAssertFalse(s.of("harvest-requests").contains { $0["notes"] == "no" })
    }

    func testUnknownUserAndWrongPassword() {
        let s = store()
        XCTAssertEqual(s.login("nobody", demoPassword), "Unknown user. Try farmer, supplier, agent, or admin.")
        XCTAssertEqual(s.login("admin", "nope"), "Wrong password.")
        XCTAssertFalse(s.isSignedIn)
    }
}
