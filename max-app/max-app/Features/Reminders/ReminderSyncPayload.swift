//
//  ReminderSyncPayload.swift
//  max-app
//

import Foundation

/// The complete set of currently incomplete reminders sent in one sync.
nonisolated struct ReminderSyncPayload: Encodable, Equatable {
    var reminders: [ReminderPayload]
}

nonisolated struct ReminderPayload: Encodable, Equatable {
    /// EventKit's local identifier is required to apply edits to this reminder later.
    var reminderIdentifier: String
    var title: String
    var notes: String?
    var list: ReminderListPayload
    var dueDate: String?
    var url: String?
    var location: String?
    var recurrenceRules: [ReminderRecurrenceRulePayload]
}

nonisolated struct ReminderListPayload: Encodable, Equatable {
    /// EventKit's local identifier is required when creating or moving a reminder.
    var identifier: String
    var title: String
}

nonisolated struct ReminderRecurrenceRulePayload: Encodable, Equatable {
    var frequency: String
    var interval: Int
    var daysOfTheWeek: [ReminderRecurrenceDayPayload]
    var daysOfTheMonth: [Int]
    var monthsOfTheYear: [Int]
    var weeksOfTheYear: [Int]
    var daysOfTheYear: [Int]
    var setPositions: [Int]
    var endDate: String?
    var occurrenceCount: Int?
}

nonisolated struct ReminderRecurrenceDayPayload: Encodable, Equatable {
    /// Calendar weekday numbering: Sunday is 1 and Saturday is 7.
    var weekday: Int
    /// Zero means no ordinal; for example, 2 means the second occurrence.
    var weekNumber: Int
}
