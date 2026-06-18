// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'OTurn';

  @override
  String get appDescription =>
      'OTurn - Faire Aufgabenverteilung für Teams. Würfele fair wer als nächstes dran ist!';

  @override
  String get about => 'Über OTurn';

  @override
  String get aboutDescription =>
      'OTurn hilft bei der fairen Verteilung von Aufgaben in Teams.';

  @override
  String get developedBy => 'Entwickelt von Waldemar Stockmann';

  @override
  String get understood => 'Verstanden';

  @override
  String get help => 'Hilfe';

  @override
  String get close => 'Schließen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get potatoModeEnabled => 'Kartoffel for President! 🥔';

  @override
  String get potatoModeDisabled => 'Kartoffel Modus deaktiviert';

  @override
  String get tasks => 'Aufgaben';

  @override
  String get groups => 'Gruppen';

  @override
  String get noTasksAvailable => 'Keine Aufgaben vorhanden';

  @override
  String get noTasksSubtitle =>
      'Erstelle deine erste Aufgabe für ein Team\nund lass das faire Würfeln beginnen!';

  @override
  String get createFirstTask => 'Erste Aufgabe erstellen';

  @override
  String get noGroupsAvailable => 'Keine Gruppen vorhanden';

  @override
  String get noGroupsSubtitle =>
      'Erstelle deine erste Gruppe mit Teammitgliedern\num Aufgaben fair zu verteilen';

  @override
  String get createFirstGroup => 'Erste Gruppe erstellen';

  @override
  String deleteTaskTitle(Object taskName) {
    return 'Aufgabe \"$taskName\" löschen?';
  }

  @override
  String get deleteTaskContent =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String deleteGroupTitle(Object groupName) {
    return 'Gruppe \"$groupName\" löschen?';
  }

  @override
  String get deleteGroupContent =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get unknownGroup => 'Unbekannte Gruppe';

  @override
  String get fairMode => 'Fair-Modus';

  @override
  String get randomMode => 'Zufalls-Modus';

  @override
  String get createGroup => 'Gruppe erstellen';

  @override
  String get editGroup => 'Gruppe bearbeiten';

  @override
  String get groupName => 'Gruppenname';

  @override
  String get groupNameHint => 'z.B. Marketing Team';

  @override
  String get groupNameRequired => 'Bitte gib einen Gruppennamen ein';

  @override
  String get groupImage => 'Gruppenbild';

  @override
  String get addMember => 'Mitglied hinzufügen';

  @override
  String get memberNameHint => 'Name eingeben';

  @override
  String membersCount(Object count) {
    return 'Mitglieder ($count)';
  }

  @override
  String get noMembersYet => 'Noch keine Mitglieder hinzugefügt';

  @override
  String memberAlreadyExists(Object name) {
    return '$name ist bereits in der Gruppe';
  }

  @override
  String get addAtLeastOneMember => 'Füge mindestens ein Mitglied hinzu';

  @override
  String get createTask => 'Aufgabe erstellen';

  @override
  String get editTask => 'Aufgabe bearbeiten';

  @override
  String get taskName => 'Aufgabenname';

  @override
  String get taskNameHint => 'z.B. E-Mail an Management schreiben';

  @override
  String get taskNameRequired => 'Bitte gib einen Aufgabennamen ein';

  @override
  String get taskImage => 'Aufgabenbild';

  @override
  String get selectGroup => 'Gruppe auswählen';

  @override
  String get selectGroupRequired => 'Bitte wähle eine Gruppe aus';

  @override
  String get fairModeToggle => 'Fair-Modus';

  @override
  String get fairModeDescription => 'Faire Rotation - jeder kommt einmal dran';

  @override
  String get additionalMembers => 'Zusätzliche Mitglieder';

  @override
  String get additionalMembersHint =>
      'Personen hinzufügen, die nicht in der Gruppe sind';

  @override
  String get excludedMembers => 'Ausgeschlossene Mitglieder';

  @override
  String get excludedMembersHint => 'Personen von dieser Aufgabe ausschließen';

  @override
  String get taskOptions => 'Aufgaben-Optionen';

  @override
  String get switchToRandomMode => 'Zu Zufalls-Modus wechseln';

  @override
  String get switchToFairMode => 'Zu Fair-Modus wechseln';

  @override
  String get randomModeDescription =>
      'Komplett zufällige Auswahl bei jedem Würfeln';

  @override
  String get showHistory => 'History anzeigen';

  @override
  String get deleteHistory => 'History löschen';

  @override
  String get deleteHistorySubtitle => 'Alle bisherigen Ausführungen löschen';

  @override
  String get resetFairQueue => 'Fair-Queue zurücksetzen';

  @override
  String get resetFairQueueSubtitle => 'Warteschlange neu mischen';

  @override
  String get fairModeActivated => 'Fair-Modus aktiviert';

  @override
  String get randomModeActivated => 'Zufalls-Modus aktiviert';

  @override
  String get historyDeleted => 'History gelöscht';

  @override
  String get fairQueueReset => 'Fair-Queue zurückgesetzt';

  @override
  String get rollDice => '🎲 Würfeln';

  @override
  String get rolling => 'Würfeln...';

  @override
  String get tapToRoll => 'Tippe zum Würfeln';

  @override
  String get noParticipantsAvailable => 'Keine Teilnehmer verfügbar';

  @override
  String get isNext => 'ist dran!';

  @override
  String get tryAgain => 'Nochmal';

  @override
  String get done => 'Fertig';

  @override
  String queueTitle(Object count) {
    return 'Warteschlange ($count)';
  }

  @override
  String get queueEmpty => 'Warteschlange ist leer';

  @override
  String get queueEmptySubtitle =>
      'Alle waren schon dran - nächstes Würfeln startet neue Runde';

  @override
  String get notYetSelected => 'Noch nicht dran:';

  @override
  String executionDetails(Object count) {
    return 'Ausführungs-Details ($count)';
  }

  @override
  String get noExecutionsYet => 'Noch keine Ausführungen';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get participants => 'Teilnehmer';

  @override
  String get history => 'History';

  @override
  String historyTitle(Object taskName) {
    return '$taskName - History';
  }

  @override
  String get addHistoryManually => 'History manuell hinzufügen';

  @override
  String get noExecutions => 'Noch keine Ausführungen';

  @override
  String get historyWillBeShown => 'Die History wird hier angezeigt';

  @override
  String get summary => 'Zusammenfassung';

  @override
  String get totalExecutions => 'Gesamte Ausführungen:';

  @override
  String get firstExecution => 'Erste Ausführung:';

  @override
  String get lastExecution => 'Letzte Ausführung:';

  @override
  String get participantFrequency => 'Häufigkeit der Teilnehmer:';

  @override
  String fromParticipants(Object count) {
    return 'Aus $count Teilnehmern';
  }

  @override
  String executionsCount(Object count) {
    return 'Ausführungen: $count';
  }

  @override
  String lastSelectedPerson(Object person) {
    return 'Zuletzt: $person';
  }

  @override
  String queueCount(Object count) {
    return 'Warteschlange: $count';
  }

  @override
  String get editHistory => 'History bearbeiten';

  @override
  String get manualHistoryEntry => 'Manueller History-Eintrag';

  @override
  String get selectedPerson => 'Ausgewählte Person:';

  @override
  String get dateAndTime => 'Datum und Zeit:';

  @override
  String get deleteHistoryEntry => 'History löschen';

  @override
  String get deleteHistoryEntryContent =>
      'Möchten Sie diesen History-Eintrag wirklich löschen?';

  @override
  String get historyUpdated => 'History aktualisiert';

  @override
  String get historyAdded => 'History hinzugefügt';

  @override
  String get historyEntryDeleted => 'History gelöscht';

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get chooseFile => 'Datei wählen';

  @override
  String get gallery => 'Galerie';

  @override
  String get remove => 'Entfernen';

  @override
  String get imageNotFound => 'Bild nicht\ngefunden';

  @override
  String get addImage => 'Bild hinzufügen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get dataManagement => 'Datenverwaltung';

  @override
  String get appInfo => 'App-Informationen';

  @override
  String get englishLanguage => 'Englische Sprache';

  @override
  String get germanLanguage => 'Deutsche Sprache';

  @override
  String get useSystemLanguage => 'Systemsprache verwenden';

  @override
  String get darkModeEnabled => 'Dunkler Modus ist aktiviert';

  @override
  String get lightModeEnabled => 'Heller Modus ist aktiviert';

  @override
  String get clearAllData => 'Alle Daten löschen';

  @override
  String get clearAllDataSubtitle =>
      'Alle Gruppen, Aufgaben und Einstellungen löschen';

  @override
  String get clearAllDataConfirmation =>
      'Dies wird dauerhaft alle Ihre Gruppen, Aufgaben, Historie und App-Einstellungen löschen. Diese Aktion kann nicht rückgängig gemacht werden. Sind Sie sicher?';

  @override
  String get clearData => 'Daten löschen';

  @override
  String get allDataCleared => 'Alle Daten wurden gelöscht';

  @override
  String get errorClearingData => 'Fehler beim Löschen der Daten';

  @override
  String get clearImages => 'Bilder löschen';

  @override
  String get clearImagesSubtitle => 'Alle hochgeladenen Bilder löschen';

  @override
  String get clearImagesConfirmation =>
      'Dies wird dauerhaft alle hochgeladenen Bilder löschen. Gruppen und Aufgaben bleiben erhalten, verlieren aber ihre Bilder. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get imagesCleared => 'Alle Bilder wurden gelöscht';

  @override
  String get errorClearingImages => 'Fehler beim Löschen der Bilder';

  @override
  String get aboutTasks =>
      'Erstelle persistente Aufgaben mit spezifischen Gruppen und verfolge die Ausführungshistorie.';

  @override
  String get aboutGroups =>
      'Organisiere Teammitglieder in wiederverwendbare Gruppen für verschiedene Projekte.';

  @override
  String get aboutFairMode =>
      'Stelle sicher, dass jeder gleichmäßig ausgewählt wird durch intelligente Rotation.';

  @override
  String get allRightsReserved => 'Alle Rechte vorbehalten';

  @override
  String get helpContent =>
      'OTurn hilft dabei, Aufgaben fair unter Teammitgliedern zu verteilen.\n\n• Erstelle Gruppen mit Teammitgliedern\n• Erstelle Aufgaben und weise sie Gruppen zu\n• Verwende den Fair-Modus für gleichmäßige Verteilung oder den Zufalls-Modus für zufallsbasierte Auswahl\n• Verfolge die Historie um zu sehen, wer wann ausgewählt wurde\n• Füge Mitglieder hinzu oder schließe sie für bestimmte Aufgaben aus\n\nFür Support kontaktiere bitte den Entwickler.';

  @override
  String get createTaskTitle => 'Aufgabe erstellen';

  @override
  String get editTaskTitle => 'Aufgabe bearbeiten';

  @override
  String get taskNameLabel => 'Aufgabenname';

  @override
  String get taskImageLabel => 'Aufgabenbild';

  @override
  String get selectGroupLabel => 'Gruppe auswählen';

  @override
  String get fairModeLabel => 'Fair-Modus';

  @override
  String get fairModeHelp =>
      'Jeder wird einmal ausgewählt, bevor jemand zweimal dran kommt';

  @override
  String get additionalMembersLabel => 'Zusätzliche Mitglieder';

  @override
  String get excludedMembersLabel => 'Ausgeschlossene Mitglieder';

  @override
  String get taskSaved => 'Aufgabe gespeichert';

  @override
  String get addAtLeastOneMemberError => 'Füge mindestens ein Mitglied hinzu';

  @override
  String memberAlreadyInGroup(Object name) {
    return '$name ist bereits in der Gruppe';
  }

  @override
  String get noMembersAddedYet => 'Noch keine Mitglieder hinzugefügt';

  @override
  String get allEveryoneHadTurn =>
      'Alle waren schon dran - nächstes Würfeln startet neue Runde';

  @override
  String executionDetailsTitle(Object count) {
    return 'Ausführungs-Details ($count)';
  }

  @override
  String get queueIsEmpty => 'Warteschlange ist leer';

  @override
  String get stillToCome => 'Noch nicht dran:';

  @override
  String get rollPotatoDice => '🥔 Würfeln';

  @override
  String get rollDiceAction => '🎲 Würfeln';

  @override
  String get switchToRandomModeAction => 'Zu Zufalls-Modus wechseln';

  @override
  String get switchToFairModeAction => 'Zu Fair-Modus wechseln';

  @override
  String get showHistoryAction => 'History anzeigen';

  @override
  String get deleteHistoryAction => 'History löschen';

  @override
  String get deleteHistoryActionSubtitle =>
      'Alle bisherigen Ausführungen löschen';

  @override
  String get resetFairQueueAction => 'Fair-Queue zurücksetzen';

  @override
  String get resetFairQueueActionSubtitle => 'Warteschlange neu mischen';

  @override
  String get pleaseSelectGroup => 'Bitte wähle eine Gruppe aus';

  @override
  String get selectGroupAction => 'Gruppe auswählen';

  @override
  String get chooseGroup => 'Gruppe wählen';

  @override
  String get randomSelectionEachRoll => 'Zufällige Auswahl bei jedem Würfeln';

  @override
  String get excludeMembers => 'Mitglieder ausschließen';

  @override
  String get excludeMembersTitle => 'Mitglieder ausschließen';

  @override
  String get aboutTasksTitle => '🎯 Aufgaben';

  @override
  String get aboutTasksDescription =>
      '• Erstelle wiederkehrende Aufgaben für deine Gruppen\n• Wähle zwischen Zufalls- und Fair-Modus\n• Verfolge die Historie aller Ausführungen';

  @override
  String get aboutGroupsTitle => '👥 Gruppen';

  @override
  String get aboutGroupsDescription =>
      '• Organisiere Teammitglieder in wiederverwendbare Gruppen\n• Perfekt für verschiedene Projekte und Teams';

  @override
  String get aboutFairModeTitle => '⚖️ Fair-Modus';

  @override
  String get aboutFairModeDescription =>
      '• Jeder kommt einmal dran, bevor die nächste Runde startet\n• Perfekt für regelmäßige Aufgaben wie Müll rausbringen';

  @override
  String get aboutRandomModeTitle => '🎲 Zufalls-Modus';

  @override
  String get aboutRandomModeDescription =>
      '• Komplett zufällige Auswahl bei jedem Würfeln\n• Ideal für spontane Entscheidungen';

  @override
  String get aboutGroupsManagementDescription =>
      '• Verwalte Teams und deren Mitglieder\n• Autocomplete basierend auf bestehenden Namen\n• Einfache Bearbeitung und Verwaltung';

  @override
  String get aboutDataStorageTitle => '💾 Datenspeicherung';

  @override
  String get aboutDataStorageDescriptionWeb =>
      '• Alle Daten werden lokal im Browser gespeichert\n• Keine externen Server oder Cloud-Dienste';

  @override
  String get aboutDataStorageDescriptionMobile =>
      '• Alle Daten werden nur auf diesem Gerät gespeichert\n• Keine Server, keine Internetverbindung nötig';

  @override
  String get aboutThisAppTitle => '📱 Über diese App';

  @override
  String get allRightsReservedShort => '© 2025 Alle Rechte vorbehalten';

  @override
  String get extractFromPhoto => 'Aus Foto extrahieren';

  @override
  String get extractNamesFromPhoto => 'Namen aus Foto extrahieren';

  @override
  String get selectPhotoForExtraction =>
      'Foto auswählen um Namen zu extrahieren';

  @override
  String get processingImage => 'Bild wird verarbeitet...';

  @override
  String get extractedNames => 'Extrahierte Namen';

  @override
  String get noNamesFound => 'Keine Namen im Bild gefunden';

  @override
  String get addExtractedNames => 'Extrahierte Namen hinzufügen';

  @override
  String get extractionError =>
      'Fehler beim Extrahieren der Namen aus dem Bild';

  @override
  String extractionSuccess(Object count) {
    return '$count Namen erfolgreich extrahiert';
  }

  @override
  String get photoExtraction => 'Foto-Extraktion';

  @override
  String get camera => 'Kamera';

  @override
  String get selectTextRegion => 'Textbereich auswählen';

  @override
  String get cropInstruction =>
      'Ziehen Sie um den Bereich mit Namen auszuwählen';

  @override
  String get cameraNotSupportedWeb =>
      'Kamera wird im Webbrowser nicht unterstützt - bitte Galerie verwenden';
}
