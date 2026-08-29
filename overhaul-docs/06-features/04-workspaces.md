# Feature Specification: Workspaces & Kanban Sections

> **Forensic Rebuild Specification**  
> Complete specification for AURA's contextual workspace hierarchy, section grouping, archiving system, and AI workspace router.

---

## 1. Workspace Domain & Architecture

Workspaces are AURA's primary organizational contexts (e.g. *"Work"*, *"Personal"*, *"IIT Prep"*). Every task, reminder, alarm, event, and note can be assigned to a workspace.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ WORKSPACE: "IIT Prep"  [Color: #22D3EE] [Icon: code]                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ ├── Section 1: "Algorithms & DS"                                            │
│ │   ├── Task: Implement Red-Black Tree in C++                               │
│ │   └── Note: LeetCode Graph traversal templates                            │
│ ├── Section 2: "System Design"                                              │
│ │   └── Task: Read Designing Data-Intensive Applications Ch. 5              │
│ └── Section 3: "Mock Interviews"                                            │
│     └── Event: Mock with Senior SWE (Sunday 4 PM)                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Data Model & Database Schema

### 2.1 Table: `workspaces`
- `id` (Text PRIMARY KEY): UUID v4.
- `name` (Text NOT NULL): Max 50 characters.
- `color_hex` (Text DEFAULT `'#C8FF00'`): Hex accent color string.
- `icon_key` (Text DEFAULT `'custom'`): Lucide icon identifier (`folder`, `book`, `code`, `briefcase`, `custom`).
- `sort_order` (Integer DEFAULT 0): Custom drag-and-drop sort order.
- `created_by` (Text DEFAULT `'user'`): `'user'` or `'system'`.
- `is_archived` (Boolean DEFAULT false): 0 = Active, 1 = Archived.
- `created_at` / `updated_at` (Integer): Epoch milliseconds.
- `deleted_at` (Integer nullable): Epoch milliseconds when soft-deleted.

### 2.2 Table: `workspace_sections`
- `id` (Text PRIMARY KEY): UUID v4.
- `workspace_id` (Text REFERENCES `workspaces(id)`): Parent workspace.
- `name` (Text NOT NULL): Section header name.
- `sort_order` (Integer DEFAULT 0): Display position.
- `is_archived` (Boolean DEFAULT false): Section archive state.
- `created_at` / `updated_at` / `deleted_at` (Integer): Timestamps.

---

## 3. Workspace Screens Specification

### 3.1 Workspace List Screen (`WorkspaceListScreen`)

- **Reactive Streams**:
  - `workspaceDao.watchAll()`: Streams all active, non-archived workspaces.
  - `workspaceItemCountProvider(wsId)`: Streams live pending task count for each workspace card.
- **Card UI**:
  - Vertical accent color bar on left edge.
  - Icon container with matching background tint.
  - Workspace title and task count badge (e.g. `5 tasks`).
  - Trailing menu icon for quick Edit, Archive, or Delete.
- **Top Actions**:
  - Search bar filtering workspaces by name.
  - `[+ NEW WORKSPACE]` button opening creation dialog.
  - View Archived Workspaces toggle.

### 3.2 Workspace Detail Screen (`WorkspaceDetailScreen`)

- **Hero Header**: Displays workspace title, colored icon badge, total tasks count, and edit cog.
- **Section Management**:
  - Section headers with collapsible item lists.
  - Add Section button (`[+ ADD SECTION]`).
- **Quick Task Capture**:
  - Persistent bottom input bar pre-assigned to the active workspace and selected section.
- **Item Cards**:
  - Checkbox to toggle completion.
  - Tap navigates to `TaskDetailScreen`.
  - Swipe-left to delete (cancels OS notifications).
  - Swipe-right to snooze.

---

## 4. Archiving & Cascading Soft-Delete

### 4.1 Archiving Workflow
- Archiving a workspace (`workspaceDao.archive(id)`) sets `is_archived = true`.
- Archived workspaces are hidden from the main list, date navigator, and voice routing suggestions.
- All items inside remain preserved.
- Restoring (`workspaceDao.unarchive(id)`) in Settings -> Workspaces & Archive brings the workspace and all items back to active status.

### 4.2 Cascading Soft-Delete
- Soft-deleting a workspace (`workspaceDao.softDelete(id)`) sets `deleted_at = nowMs` on:
  1. The workspace row.
  2. All child `workspace_sections`.
  3. All child `items`.
- Invokes `ReminderSchedulingService.cancelForItem(itemId)` for all soft-deleted items to ensure no zombie alarms fire.

---

## 5. AI Workspace Routing & Taxonomy Matching

When the user speaks a command containing a workspace hint (e.g. *"add task to Placement Prep"*):

1. **Exact Match (Confidence 1.0)**: Matches if `workspace.name.toLowerCase() == hint.toLowerCase()`.
2. **Fuzzy Containment (Confidence 0.8–0.9)**: Matches if workspace name contains hint, hint contains name, or significant tokens overlap.
3. **Taxonomy Keyword Fallback (Confidence 0.7)**: Maps hint against generic keyword index:
   - `work` -> `['work', 'office', 'standup', 'sprint', 'deploy', 'client', 'meeting', 'project', 'deadline', 'report']`
   - `personal` -> `['personal', 'home', 'family', 'hobby', 'errand', 'shopping']`
   - `health` -> `['gym', 'exercise', 'medicine', 'doctor', 'workout', 'fitness', 'run']`
   - `finance` -> `['finance', 'budget', 'bank', 'tax', 'invoice', 'payment', 'rent']`
   - `learning` -> `['study', 'learn', 'course', 'exam', 'assignment', 'class', 'school', 'college', 'university', 'reading']`
4. **New Workspace Suggestion**: If no match, proposes creating a new workspace named after the hint. Creation executes inside `CreateTaskUseCase` database transaction with `#C8FF00` default accent.
