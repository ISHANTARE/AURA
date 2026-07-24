import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/widgets.dart';

/// AURA Icon System — Lucide Icons ONLY (ADR-012)
///
/// Rules:
///   1. No emojis. Ever.
///   2. No Material Icons. No Heroicons. No mixing.
///   3. Always stroke variant — never filled unless explicitly noted.
///   4. Reference this class everywhere instead of LucideIcons directly
///      so icon mapping stays centralized and auditable.
///
/// Source: 03_UX/design_system.md — Icon System section
abstract final class AuraIcons {
  // ── Navigation ─────────────────────────────────────────────────────────
  static const IconData home        = LucideIcons.home;
  static const IconData calendar    = LucideIcons.calendarDays;
  static const IconData workspaces  = LucideIcons.layoutDashboard;
  static const IconData settings    = LucideIcons.settings;

  // ── Core actions ───────────────────────────────────────────────────────
  static const IconData add         = LucideIcons.plus;
  static const IconData edit        = LucideIcons.pencil;
  static const IconData delete      = LucideIcons.trash2;
  static const IconData archive     = LucideIcons.archive;
  static const IconData close       = LucideIcons.x;
  static const IconData back        = LucideIcons.chevronLeft;
  static const IconData forward     = LucideIcons.chevronRight;
  static const IconData more        = LucideIcons.moreVertical;
  static const IconData search      = LucideIcons.search;
  static const IconData share       = LucideIcons.share2;
  static const IconData move        = LucideIcons.arrowRightLeft;
  static const IconData export_icon = LucideIcons.download;
  static const IconData filter      = LucideIcons.listFilter;
  static const IconData sort        = LucideIcons.arrowUpDown;
  static const IconData dragHandle  = LucideIcons.gripVertical;

  // ── Task / content types ───────────────────────────────────────────────
  static const IconData task        = LucideIcons.checkSquare;
  static const IconData event       = LucideIcons.calendarDays;
  static const IconData note        = LucideIcons.stickyNote;
  static const IconData document    = LucideIcons.fileText;
  static const IconData image       = LucideIcons.image;
  static const IconData link        = LucideIcons.link;
  static const IconData subtask     = LucideIcons.cornerDownRight;

  // ── Status / state ─────────────────────────────────────────────────────
  static const IconData done        = LucideIcons.checkCircle;
  static const IconData overdue     = LucideIcons.alertTriangle;
  static const IconData recurring   = LucideIcons.refreshCw;

  // ── Priority ───────────────────────────────────────────────────────────
  static const IconData priorityHigh   = LucideIcons.chevronsUp;
  static const IconData priorityMedium = LucideIcons.minus;
  static const IconData priorityLow    = LucideIcons.chevronDown;

  // ── Reminders / notifications ──────────────────────────────────────────
  static const IconData reminder    = LucideIcons.bell;
  static const IconData reminderOff = LucideIcons.bellOff;
  static const IconData snooze      = LucideIcons.alarmClock;

  // ── Voice / capture ────────────────────────────────────────────────────
  static const IconData mic         = LucideIcons.mic;
  static const IconData keyboard    = LucideIcons.keyboard;

  // ── AI ─────────────────────────────────────────────────────────────────
  static const IconData ai          = LucideIcons.sparkles;

  // ── Network / connectivity ─────────────────────────────────────────────
  static const IconData offline     = LucideIcons.wifiOff;

  // ── User / profile ─────────────────────────────────────────────────────
  static const IconData profile     = LucideIcons.user;
  static const IconData lock        = LucideIcons.lock;

  // ── Morning briefing ───────────────────────────────────────────────────
  static const IconData briefing    = LucideIcons.sunrise;

  // ── Workspace section ──────────────────────────────────────────────────
  static const IconData section     = LucideIcons.folderOpen;

  // ── Workspace type icons (workspace creation / display) ────────────────
  static const IconData wsCollege    = LucideIcons.graduationCap;
  static const IconData wsGate       = LucideIcons.target;
  static const IconData wsWork       = LucideIcons.briefcase;
  static const IconData wsPersonal   = LucideIcons.user;
  static const IconData wsHealth     = LucideIcons.heart;
  static const IconData wsFinance    = LucideIcons.creditCard;
  static const IconData wsProjects   = LucideIcons.layoutGrid;
  static const IconData wsPlacement  = LucideIcons.award;
  static const IconData wsResearch   = LucideIcons.flaskConical;
  static const IconData wsCustom     = LucideIcons.folder;

  /// Returns the workspace icon for a given workspace name (case-insensitive).
  /// Falls back to [wsCustom] if no match found.
  static IconData forWorkspace(String name) {
    final n = name.toLowerCase();
    if (n.contains('vit') || n.contains('college') || n.contains('university')) return wsCollege;
    if (n.contains('gate') || n.contains('iit') || n.contains('prep')) return wsGate;
    if (n.contains('intern') || n.contains('work') || n.contains('job')) return wsWork;
    if (n.contains('personal') || n.contains('self')) return wsPersonal;
    if (n.contains('health') || n.contains('gym') || n.contains('fitness')) return wsHealth;
    if (n.contains('finance') || n.contains('money') || n.contains('budget')) return wsFinance;
    if (n.contains('project') || n.contains('build') || n.contains('dev')) return wsProjects;
    if (n.contains('place') || n.contains('recruit') || n.contains('career')) return wsPlacement;
    if (n.contains('research') || n.contains('paper') || n.contains('patent')) return wsResearch;
    return wsCustom;
  }

  // ── Icon sizes ──────────────────────────────────────────────────────────
  /// Inline with body text
  static const double sizeInline = 16.0;
  /// Standard list item / UI icon
  static const double sizeStandard = 20.0;
  /// App bar / nav bar
  static const double sizeNavBar = 24.0;
  /// Empty state illustrations
  static const double sizeEmptyState = 36.0;
  /// Large feature icons
  static const double sizeLarge = 48.0;
}
