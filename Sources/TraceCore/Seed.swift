import Foundation

private func rec(_ fields: [String: String]) -> TraceRecord {
    var data = fields
    if data["createdAt"] == nil { data["createdAt"] = "2026-08-25T08:00:00.000Z" }
    if data["updatedAt"] == nil { data["updatedAt"] = "2026-08-25T08:00:00.000Z" }
    return TraceRecord(data)
}

public func seedTraceRecords() -> [String: [TraceRecord]] {
    [
        "farmers": [
            rec(["id": "frm-1", "name": "Namuli Sarah", "code": "FRM-0001", "phone": "0772123456", "village": "Kyanamukaka", "district": "Masaka", "variety": "SL14 Arabica", "acres": "1.8", "gps": "-0.3412, 31.7361", "bio": "Third-generation coffee farmer at Africa Coffee Park catchment.", "certs": "Organic, Fairtrade", "dueDiligence": "DDR-ACP-0041", "satellite": "pass", "primaryAgent": "Okello James", "status": "Active"]),
            rec(["id": "frm-2", "name": "Ssekandi Peter", "code": "FRM-0002", "phone": "0754988122", "village": "Bukakata", "district": "Masaka", "variety": "KP423", "acres": "0.9", "gps": "", "bio": "", "certs": "", "status": "Active"]),
            rec(["id": "frm-nakato", "name": "Nakato Grace", "code": "F-0142", "phone": "+256 772 441 200", "village": "Kyanamukaka", "district": "Masaka", "variety": "Arabica AA", "acres": "2.4", "gps": "-0.341, 31.736", "bio": "Shaded arabica gardens near Masaka buying centre.", "certs": "Organic", "dueDiligence": "DDR-ACP-0142", "satellite": "pass", "primaryAgent": "Auma Inspector", "status": "Active"]),
            rec(["id": "frm-okello", "name": "Okello Peter", "code": "F-0088", "phone": "+256 701 220 019", "village": "Bungokho", "district": "Mbale", "variety": "Arabica AA", "acres": "1.8", "gps": "1.078, 34.175", "status": "Active"]),
            rec(["id": "frm-auma", "name": "Auma Rose", "code": "F-0210", "phone": "+256 782 110 441", "village": "Kyamuhunga", "district": "Bushenyi", "variety": "Robusta", "acres": "3.1", "status": "Active"]),
        ],
        "farms": [
            rec(["id": "farm-1", "name": "Namuli plot A", "code": "FARM-0001", "farmer": "Namuli Sarah", "farmerId": "frm-1", "district": "Masaka", "village": "Kyanamukaka", "variety": "SL14 Arabica", "acres": "1.8", "hectares": "0.73", "gps": "-0.3412, 31.7361", "bio": "Shaded arabica on a 1 ha EUDR square.", "satellite": "pass", "dueDiligence": "DDR-ACP-0041", "status": "Active"]),
            rec(["id": "farm-2", "name": "Ssekandi homestead", "code": "FARM-0002", "farmer": "Ssekandi Peter", "farmerId": "frm-2", "district": "Masaka", "village": "Bukakata", "variety": "KP423", "acres": "0.9", "gps": "", "status": "Active"]),
            rec(["id": "farm-nakato", "name": "Nakato Garden", "code": "FM-0142-A", "farmer": "Nakato Grace", "farmerId": "frm-nakato", "district": "Masaka", "hectares": "2.4", "gps": "-0.341, 31.736", "satellite": "pass", "dueDiligence": "DDR-ACP-0142", "bio": "Upper slope and valley plots.", "status": "Active"]),
            rec(["id": "farm-okello", "name": "Hillside Arabica", "code": "FM-0088-A", "farmer": "Okello Peter", "farmerId": "frm-okello", "district": "Mbale", "hectares": "1.8", "gps": "1.078, 34.175", "status": "Active"]),
            rec(["id": "farm-auma", "name": "Kyamuhunga Plot", "code": "FM-0210-A", "farmer": "Auma Rose", "farmerId": "frm-auma", "district": "Bushenyi", "hectares": "3.1", "status": "Active"]),
        ],
        "plots": [
            rec(["id": "plt-1", "name": "Upper slope", "code": "P-1", "farm": "Nakato Garden", "crop": "Arabica AA", "hectares": "1.1", "status": "Active"]),
            rec(["id": "plt-2", "name": "Valley", "code": "P-2", "farm": "Nakato Garden", "crop": "Robusta", "hectares": "1.3", "status": "Active"]),
            rec(["id": "plt-3", "name": "Main block", "code": "P-1", "farm": "Hillside Arabica", "crop": "Arabica AA", "hectares": "1.8", "status": "Active"]),
        ],
        "crops": [
            rec(["id": "crop-1", "name": "Arabica", "code": "SL14", "season": "2026 A", "status": "Active"]),
            rec(["id": "crop-2", "name": "Robusta", "code": "KP423", "season": "2026 A", "status": "Active"]),
        ],
        "cooperatives": [
            rec(["id": "coop-1", "name": "Masaka Coffee Growers", "code": "COOP-0001", "district": "Masaka", "members": "42", "status": "Active"]),
        ],
        "cooperative-members": [
            rec(["id": "cm-1", "name": "Namuli Sarah", "cooperative": "Masaka Coffee Growers", "farmer": "FRM-0001", "phone": "0772123456", "status": "Active"]),
            rec(["id": "cm-2", "name": "Nakato Grace", "cooperative": "Masaka Coffee Growers", "farmer": "F-0142", "phone": "+256 772 441 200", "status": "Active"]),
        ],
        "harvest-requests": [
            rec(["id": "hr-1", "reference": "HR-0008", "date": "2026-08-24", "farmer": "Namuli Sarah", "village": "Kyanamukaka", "volumeKg": "200", "status": "Pending"]),
        ],
        "suppliers": [
            rec(["id": "sup-1", "name": "Namuli Sarah", "code": "SUP-FRM-0001", "kind": "Farm", "district": "Masaka", "status": "Active"]),
            rec(["id": "sup-2", "name": "Masaka Coffee Growers", "code": "SUP-COOP-0001", "kind": "Cooperative", "district": "Masaka", "status": "Active"]),
        ],
        "batches": [
            rec(["id": "batch-1", "name": "Namuli cherry lot", "code": "BATCH-0001", "farmer": "Namuli Sarah", "farm": "Namuli plot A", "beanType": "Arabica", "variety": "SL14 Arabica", "stage": "Dry mill", "grossKg": "420", "tare": "8", "netKg": "412.0", "moisture": "12.4", "cup": "84.2", "grade": "AA", "status": "Active"]),
            rec(["id": "batch-2", "name": "Ssekandi intake", "code": "BATCH-0002", "farmer": "Ssekandi Peter", "farm": "Ssekandi homestead", "beanType": "Arabica", "stage": "Intake", "grossKg": "180", "tare": "3", "netKg": "177.0", "moisture": "18.1", "status": "Pending"]),
            rec(["id": "batch-3", "name": "Nakato harvest", "code": "BATCH-0003", "farmer": "Nakato Grace", "farm": "Nakato Garden", "beanType": "Arabica", "variety": "Arabica AA", "stage": "Approved", "grossKg": "848", "tare": "8", "netKg": "840.0", "moisture": "11.8", "cup": "85.0", "grade": "AA", "status": "Active"]),
        ],
        "custody-events": [
            rec(["id": "evt-1", "reference": "EVT-0001", "date": "2026-08-12", "lot": "BATCH-0001", "from": "Namuli plot A", "to": "ACP wet mill", "quantity": "412", "status": "Recorded"]),
            rec(["id": "evt-2", "reference": "EVT-0002", "date": "2026-08-18", "lot": "BATCH-0001", "from": "ACP wet mill", "to": "ACP dry mill", "quantity": "390", "status": "Recorded"]),
        ],
        "chain-of-custody": [
            rec(["id": "mov-1", "reference": "MOV-0001", "date": "2026-08-12", "lot": "BATCH-0001", "from": "Namuli plot A", "to": "ACP wet mill", "quantity": "412", "status": "Received"]),
            rec(["id": "mov-2", "reference": "MOV-0002", "date": "2026-08-18", "lot": "BATCH-0001", "from": "ACP wet mill", "to": "ACP dry mill", "quantity": "390", "status": "Received"]),
            rec(["id": "cus-1", "reference": "COC-0088", "date": "2026-08-12", "lot": "IAG-LOT-00421", "from": "Nakato Garden", "to": "Masaka buying centre", "quantity": "840", "status": "Received"]),
            rec(["id": "cus-2", "reference": "COC-0089", "date": "2026-08-14", "lot": "IAG-LOT-00421", "from": "Masaka buying centre", "to": "Namanve warehouse", "quantity": "840", "status": "In transit"]),
        ],
        "export-lots": [
            rec(["id": "elot-1", "name": "ACP Masaka AA", "code": "LOT-00421", "batches": "BATCH-0001,BATCH-0003", "grade": "AA", "weightKg": "390", "status": "Ready"]),
        ],
        "qr-stories": [
            rec(["id": "qr-1", "name": "ACP Masaka AA story", "code": "LOT-00421", "lot": "LOT-00421", "farmer": "Namuli Sarah", "status": "Live", "notes": "Shaded SL14 from Kyanamukaka. Cup 84.2. Organic + Fairtrade."]),
            rec(["id": "qr-2", "name": "Nakato Garden AA", "code": "IAG-LOT-00421", "lot": "LOT-00421", "farmer": "Nakato Grace", "status": "Live", "notes": "Shade trees in place. No prohibited spray observed."]),
        ],
        "lab-results": [
            rec(["id": "lab-1", "reference": "LAB-0091", "date": "2026-08-20", "batch": "BATCH-0001", "moisture": "12.4", "cup": "84.2", "grade": "AA", "status": "Complete"]),
            rec(["id": "lab-2", "reference": "LAB-0092", "date": "2026-08-25", "batch": "BATCH-0002", "moisture": "18.1", "status": "Pending"]),
        ],
        "certifications": [
            rec(["id": "cert-1", "name": "Organic EU", "code": "ORG-1182", "farmer": "Namuli Sarah", "scheme": "Organic", "issued": "2025-03-01", "expires": "2027-03-01", "status": "Valid"]),
            rec(["id": "cert-2", "name": "Fairtrade", "code": "FT-441", "farmer": "Namuli Sarah", "scheme": "Fairtrade", "issued": "2025-06-01", "expires": "2026-12-01", "status": "Valid"]),
            rec(["id": "cert-3", "name": "Organic internal ICS", "code": "ORG-0142", "farmer": "Nakato Grace", "scheme": "Organic", "issued": "2025-04-01", "expires": "2027-03-31", "status": "Valid"]),
            rec(["id": "cert-4", "name": "Fairtrade", "code": "FT-0088", "farmer": "Okello Peter", "scheme": "Fairtrade", "issued": "2025-01-15", "expires": "2026-12-15", "status": "Valid"]),
        ],
        "field-agents": [
            rec(["id": "agt-1", "name": "Okello James", "code": "AGT-0004", "phone": "0703112233", "district": "Masaka", "farmers": "18", "status": "Approved"]),
            rec(["id": "agt-2", "name": "Auma Inspector", "code": "AGT-0005", "phone": "0782001100", "district": "Masaka", "farmers": "12", "status": "Approved"]),
        ],
        "farmer-payments": [
            rec(["id": "pay-1", "reference": "PAY-331", "date": "2026-08-13", "farmer": "Namuli Sarah", "amount": "2472000", "status": "Paid"]),
            rec(["id": "pay-2", "reference": "PAY-332", "date": "2026-08-13", "farmer": "Nakato Grace", "amount": "11760000", "status": "Paid"]),
        ],
        "farmgate-prices": [
            rec(["id": "price-1", "name": "Arabica cherry", "district": "Masaka", "date": "2026-08-25", "priceKg": "14000", "status": "Published"]),
            rec(["id": "price-2", "name": "Robusta cherry", "district": "Bushenyi", "date": "2026-08-25", "priceKg": "4200", "status": "Published"]),
        ],
        "purchase-orders": [
            rec(["id": "po-1", "reference": "PO-0188", "date": "2026-08-10", "supplier": "Masaka Coffee Growers", "amount": "12000000", "status": "Open"]),
            rec(["id": "po-2", "reference": "PO-0189", "date": "2026-08-11", "supplier": "Namuli Sarah", "amount": "2472000", "status": "Received"]),
        ],
        "sales-orders": [
            rec(["id": "so-1", "reference": "SO-0044", "date": "2026-08-22", "buyer": "Nordic Roasters", "lot": "LOT-00421", "amount": "48000000", "status": "Confirmed"]),
        ],
        "buyers": [
            rec(["id": "buy-1", "name": "Nordic Roasters", "code": "BUY-0012", "country": "Sweden", "status": "Active"]),
        ],
        "inventory-skus": [
            rec(["id": "sku-1", "name": "Arabica AA green", "code": "SKU-AA", "grade": "AA", "stockKg": "390", "status": "Active"]),
        ],
        "shipments": [
            rec(["id": "shp-1", "reference": "SHP-0071", "date": "2026-08-26", "customer": "Nordic Roasters", "fromLocation": "Namanve warehouse", "toLocation": "Mombasa CFS", "vehicle": "UAX 441T", "weightKg": "390", "status": "Scheduled"]),
        ],
        "stock-sessions": [
            rec(["id": "ss-1", "reference": "STK-0012", "date": "2026-08-18", "vehicle": "UAX 441T", "agent": "Okello James", "sacks": "12", "status": "Sealed"]),
        ],
        "harvest-lots": [
            rec(["id": "lot-421", "name": "Nakato AA", "code": "LOT-00421", "date": "2026-08-12", "farmer": "Nakato Grace", "farmerId": "frm-nakato", "farm": "Nakato Garden", "farmId": "farm-nakato", "crop": "Arabica AA", "quantity": "840", "grade": "AA", "traceCode": "IAG-LOT-00421", "status": "In store"]),
            rec(["id": "lot-418", "name": "Okello AB", "code": "LOT-00418", "date": "2026-08-08", "farmer": "Okello Peter", "farmerId": "frm-okello", "farm": "Hillside Arabica", "farmId": "farm-okello", "crop": "Arabica AA", "quantity": "510", "grade": "AB", "traceCode": "IAG-LOT-00418", "status": "Shipped"]),
        ],
        "collections": [
            rec(["id": "col-1", "reference": "COL-0019", "date": "2026-08-12", "farmer": "Nakato Grace", "farmerId": "frm-nakato", "lot": "IAG-LOT-00421", "lotId": "lot-421", "buyingCentre": "Masaka buying centre", "quantity": "840", "amount": "11760000", "status": "Paid"]),
        ],
        "trace-codes": [
            rec(["id": "tc-1", "code": "IAG-LOT-00421", "name": "Nakato AA public code", "lot": "LOT-00421", "farmer": "Nakato Grace", "date": "2026-08-12", "status": "Active"]),
        ],
        "field-inspections": [
            rec(["id": "insp-1", "reference": "INSP-0004", "date": "2026-08-20", "farm": "Nakato Garden", "farmId": "farm-nakato", "inspector": "Auma Inspector", "result": "Pass", "findings": "Shade trees in place.", "status": "Complete"]),
            rec(["id": "insp-2", "reference": "INSP-0005", "date": "2026-08-22", "farm": "Hillside Arabica", "farmId": "farm-okello", "inspector": "Auma Inspector", "result": "Follow-up", "findings": "Buffer zone incomplete on eastern edge.", "status": "Draft"]),
        ],
    ]
}

public func seedAudit() -> [AuditEntry] {
    [
        AuditEntry(id: "audit-seed", at: "2026-08-25T08:00:00.000Z", action: "seed", entity: "farmers", label: "Demo TraceIAG records", actor: "system"),
    ]
}
