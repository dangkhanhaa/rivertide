/// Public surface of the tide alarms feature (CLAUDE.md 3.2).
library;

export 'application/alert_scheduler.dart' show rescheduleAlerts;
export 'presentation/alert_settings_sheet.dart' show AlertSettingsButton, showAlertSettings;
export 'presentation/alert_toggle.dart'
    show alertOnFor, alertsSupported, setAlertChoices, toggleAlert, watchAlertChoices;
