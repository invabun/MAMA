---
name: operate-mama
description: Operate the Malaysia Additive Manufacturing Association membership site for application intake, member profile access, application decisions and invoice-file handoff. Use to verify the data effect of each step.
---

# Operate MAMA membership

MAMA manages association membership. Operate with the relevant applicant, member or authorized admin through the static pages. Enter sensitive identity documents and account credentials in the approved UI. Keep them out of chat transcripts, code, test fixtures and issue evidence.

## Identify the environment

The pages use Supabase JS with a browser URL and public client key embedded in the page code. The [schema snapshot](../../supabase_setup.sql) labels the project AIShort / B3D. MAMA's logical data consists of its membership tables, user sessions and document buckets. The current source does not demonstrate a dedicated physical database. Serving these HTML files locally still points at the configured backend. Confirm every affected page's target before a test write or authentication email. Use mock calls or a dedicated test project and test mailbox. No MAMA-owned MCP service or tool registry is defined here. A generic database connection grants no business role.

## Operate by role

| Task | Inputs and application interface | Success evidence |
| --- | --- | --- |
| Apply | Open [register.html](../../register.html), choose membership type and fill name, email, phone, state and the fields shown for that type. Individual applicants provide identification; corporate applicants provide organization details; students provide institution, course, matric ID, student ID file and lecturer contact. The form requires consent. [submitForm](../../mama.js) generates an application UUID, uploads supplied student files to `student-docs` and inserts `mama_members` with `application_status=new`. | Registration success acknowledges the insert. In a test environment, locate the same application via the authorized admin view and verify its type and expected file references. The code can insert a row after an unavailable attachment upload. Check before resubmitting; another submission generates a fresh UUID. |
| Read or change own profile | Open [member.html](../../member.html) with the applicant's registered email and complete the email link privately. The page selects one `mama_members` row by the authenticated email. Save Profile updates phone, state, industry and intro by the loaded member ID. | Refresh and confirm exactly the requested fields on the same member. If no unique match loads, reconcile through an authorized admin. |
| Decide an application | The authorized administrator opens [admin.html](../../admin.html) and signs in with the admin account. Select the exact application ID and approved decision. Approve writes `application_status` and a generated `membership_number`; reject changes the application status. | Reopen the same member and confirm stored status and, on approval, its number. Number allocation uses an approved-member count. After a collision or uncertain response, read back before retrying. Approval does not establish payment receipt. |
| Attach an invoice | In the admin detail for the intended member ID, choose the approved file. The page uploads to `mama_files` and inserts a `mama_member_files` row with member ID, file name, URL and invoice type. | Check both the uploaded file and the linked invoice on the correct test member dashboard. A metadata failure after an upload can leave an unlinked object. Reconcile before uploading again and keep document URLs private. |

## Known limits to acceptance

The current student form emits `member_type=student` and `payment_status=foc`. The checked-in schema constraints omit both values. A working live student flow therefore depends on the actual schema. If the approved test schema rejects the values, report the mismatch without changing real data or rerunning the setup SQL. The public contact form in [index.html](../../index.html) calls `submitContact`, which only changes the displayed message. Its thank-you screen offers no evidence of delivery.

## Validate and hand off

Check `node --check mama.js` after script changes. Render the changed static page and verify its CSS, JavaScript, conditional member fields and error display. For a write-flow change, use a fixture against the isolated target and confirm the role-specific readback above. If an isolated backend is unavailable, report rendering or mock results and the pending integration case separately.

Keep member rows, document uploads, backups and any NAS storage outside the application release. The existing `records/` tree contains tracked documents; preserve its contents and avoid using it for new member uploads. Changing hosting does not move external data. Production database, bucket, membership policy, fee or deployment changes need the owner's decision and an identified rollback target. In the task issue or PR record the revision, target, role, test case, observed result and any remaining discrepancy without personal data. Update the skill with changes to forms, policies, storage, MCP tools or acceptance evidence.
