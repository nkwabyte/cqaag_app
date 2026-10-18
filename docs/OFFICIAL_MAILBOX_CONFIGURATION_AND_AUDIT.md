# CQAAG Official Google Workspace Mailbox Topology & Verification Guide
**Reference:** Spec Sections 85–87 · Build Tracker Step 16 (Tests 16.1–16.8) · Pilot Target: January 2027

---

## 1. Statutory Architecture & Association Domain
- **Official Domain:** `cqaaggh.org`
- **Signed-in Web Portal:** `app.cqaaggh.org`
- **Public Website:** `cqaaggh.org`
- **Tenancy:** Google Workspace Enterprise / Non-Profit assigned to Cashew Quality Analysts' Association, Ghana.
- **Constitutional Requirement (Rule M1–M4):** No officer, Secretariat personnel, or analyst may conduct Association business or transmit regulatory certificates using personal Gmail, Yahoo, or private domains.

---

## 2. National Mailbox Topology (Spec Section 85.1 & 85.3)

### A. Dedicated Executive & Secretariat Mailboxes (Full Mailboxes with Individual 2FA)
| Mailbox Address | Designated Officer / Responsibility | Primary User / Handover Policy |
| :--- | :--- | :--- |
| `national.president@cqaaggh.org` | National President | Office-holder (transferred upon election) |
| `national.generalsecretary@cqaaggh.org` | National General Secretary (Mr. Marc / Successor) | Dual control, Secretariat records |
| `national.treasurer@cqaaggh.org` | National Treasurer | Signatory on bank accounts & reconciliation |
| `national.membership@cqaaggh.org` | Membership Committee Desk | Application reviews, approvals, cards |
| `national.finance@cqaaggh.org` | Finance Committee | Tariffs, dues audits, reconciliations |
| `national.disciplinaries@cqaaggh.org` | Disciplinary & Ethics Committee | Hearings, suspensions, Act 772 compliance |
| `info@cqaaggh.org` | Public Inquiries & Directory Contact | Secretariat Intake Desk |
| `certificates@cqaaggh.org` | Official Certificate Distribution | Automated delivery of Pass & Certificates |
| `training@cqaaggh.org` | Training & Proficiency Committee | Exam scheduling, renewal certifications |
| `arbitration@cqaaggh.org` | Quality Arbitration Panel | Dual-arbitrator case files & hearings |
| `noreply@cqaaggh.org` | System Automated Transactions | Outbox alerts, SMS receipts, OTPs |

### B. Shared Collaborative Groups (Google Groups under `@cqaaggh.org`)
| Group Address | Members Included | Purpose |
| :--- | :--- | :--- |
| `support@cqaaggh.org` | Secretariat Technical Support Team | App debugging, analyst sync support |
| `quality@cqaaggh.org` | Quality Standards Committee | Moisture thresholds, KOR calibration |
| `kits@cqaaggh.org` | Logistics & Cutting Kit Desk | Order fulfillment, dispatch tracking |
| `tcda@cqaaggh.org` | Regulatory Liaison Officer | TCDA licence sync & compliance reporting |

### C. Regional Chapter Mailboxes
Created within 14 days of Chapter Inauguration (Rule E5):
- `bono@cqaaggh.org` (Bono Chapter Executive)
- `bonoeast@cqaaggh.org` (Bono East Chapter Executive)
- `greateraccra@cqaaggh.org` (Greater Accra Chapter Executive)
- `savannah@cqaaggh.org` (Savannah Chapter Executive)
- `ahafo@cqaaggh.org` (Ahafo Chapter Executive)
- `upperwest@cqaaggh.org` (Upper West Chapter Executive)

---

## 3. Verification Criteria & Audit Log (Step 16, Tests 16.1–16.8)

- [x] **Test 16.1:** All 18 national mailboxes exist, configured as specified in 85.1 and 85.3.
- [x] **Test 16.2:** Two-step verification (2FA) enforced org-wide for all national mailboxes and Google Workspace admins.
- [x] **Test 16.3:** Domain and mail administration belong strictly to the Association (two designated executive officers hold Super Admin privileges).
- [x] **Test 16.4:** Certificate and Pass distribution outbound sender configured to `certificates@cqaaggh.org` with DKIM, SPF (`v=spf1 include:_spf.google.com ~all`), and DMARC enforcement.
- [x] **Test 16.5:** Incoming messages to `info@cqaaggh.org` routed to General Secretary and Intake Assistant; `support@cqaaggh.org` reaches Technical Desk.
- [x] **Test 16.6 (Codebase Audit):** All references to personal Gmail addresses (`ghcashewqualityanalyst@gmail.com`, `cqaag.gh@gmail.com`) purged from mobile app, web templates, and email footers; replaced with official `cqaaggh.org` addresses.
- [x] **Test 16.7 (Handover Protocol):** When an officer vacates an office, password reset and 2FA revocation performed by Secretariat Super Admin, mailbox archived and forwarded to incoming officer.
- [x] **Test 16.8 (Chapter Mailboxes):** Standard operating procedure documented for chapter mailboxes within 14 days of regional elections.
