import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OTurn'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'OTurn - Fair task distribution for teams. Roll fairly who\'s next!'**
  String get appDescription;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About OTurn'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'OTurn helps with fair distribution of tasks in teams.'**
  String get aboutDescription;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by Waldemar Stockmann'**
  String get developedBy;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @potatoModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Potato for President! 🥔'**
  String get potatoModeEnabled;

  /// No description provided for @potatoModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Potato mode disabled'**
  String get potatoModeDisabled;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @noTasksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tasks available'**
  String get noTasksAvailable;

  /// No description provided for @noTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first task for a team\nand let the fair rolling begin!'**
  String get noTasksSubtitle;

  /// No description provided for @createFirstTask.
  ///
  /// In en, this message translates to:
  /// **'Create first task'**
  String get createFirstTask;

  /// No description provided for @noGroupsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No groups available'**
  String get noGroupsAvailable;

  /// No description provided for @noGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first group with team members\nto distribute tasks fairly'**
  String get noGroupsSubtitle;

  /// No description provided for @createFirstGroup.
  ///
  /// In en, this message translates to:
  /// **'Create first group'**
  String get createFirstGroup;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task \"{taskName}\"?'**
  String deleteTaskTitle(Object taskName);

  /// No description provided for @deleteTaskContent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteTaskContent;

  /// No description provided for @deleteGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete group \"{groupName}\"?'**
  String deleteGroupTitle(Object groupName);

  /// No description provided for @deleteGroupContent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteGroupContent;

  /// No description provided for @unknownGroup.
  ///
  /// In en, this message translates to:
  /// **'Unknown group'**
  String get unknownGroup;

  /// No description provided for @fairMode.
  ///
  /// In en, this message translates to:
  /// **'Fair mode'**
  String get fairMode;

  /// No description provided for @randomMode.
  ///
  /// In en, this message translates to:
  /// **'Random mode'**
  String get randomMode;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Marketing Team'**
  String get groupNameHint;

  /// No description provided for @groupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name'**
  String get groupNameRequired;

  /// No description provided for @groupImage.
  ///
  /// In en, this message translates to:
  /// **'Group image'**
  String get groupImage;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// No description provided for @memberNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get memberNameHint;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'Members ({count})'**
  String membersCount(Object count);

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No members added yet'**
  String get noMembersYet;

  /// No description provided for @memberAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'{name} is already in the group'**
  String memberAlreadyExists(Object name);

  /// No description provided for @addAtLeastOneMember.
  ///
  /// In en, this message translates to:
  /// **'Add at least one member'**
  String get addAtLeastOneMember;

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @taskName.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get taskName;

  /// No description provided for @taskNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Write email to management'**
  String get taskNameHint;

  /// No description provided for @taskNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a task name'**
  String get taskNameRequired;

  /// No description provided for @taskImage.
  ///
  /// In en, this message translates to:
  /// **'Task image'**
  String get taskImage;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get selectGroup;

  /// No description provided for @selectGroupRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a group'**
  String get selectGroupRequired;

  /// No description provided for @fairModeToggle.
  ///
  /// In en, this message translates to:
  /// **'Fair mode'**
  String get fairModeToggle;

  /// No description provided for @fairModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Fair rotation - everyone gets a turn once'**
  String get fairModeDescription;

  /// No description provided for @additionalMembers.
  ///
  /// In en, this message translates to:
  /// **'Additional members'**
  String get additionalMembers;

  /// No description provided for @additionalMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Add people not in the group'**
  String get additionalMembersHint;

  /// No description provided for @excludedMembers.
  ///
  /// In en, this message translates to:
  /// **'Excluded members'**
  String get excludedMembers;

  /// No description provided for @excludedMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Exclude people from this task'**
  String get excludedMembersHint;

  /// No description provided for @taskOptions.
  ///
  /// In en, this message translates to:
  /// **'Task options'**
  String get taskOptions;

  /// No description provided for @switchToRandomMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to random mode'**
  String get switchToRandomMode;

  /// No description provided for @switchToFairMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to fair mode'**
  String get switchToFairMode;

  /// No description provided for @randomModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Completely random selection on each roll'**
  String get randomModeDescription;

  /// No description provided for @showHistory.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get showHistory;

  /// No description provided for @deleteHistory.
  ///
  /// In en, this message translates to:
  /// **'Delete history'**
  String get deleteHistory;

  /// No description provided for @deleteHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all previous executions'**
  String get deleteHistorySubtitle;

  /// No description provided for @resetFairQueue.
  ///
  /// In en, this message translates to:
  /// **'Reset fair queue'**
  String get resetFairQueue;

  /// No description provided for @resetFairQueueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reshuffle queue'**
  String get resetFairQueueSubtitle;

  /// No description provided for @fairModeActivated.
  ///
  /// In en, this message translates to:
  /// **'Fair mode activated'**
  String get fairModeActivated;

  /// No description provided for @randomModeActivated.
  ///
  /// In en, this message translates to:
  /// **'Random mode activated'**
  String get randomModeActivated;

  /// No description provided for @historyDeleted.
  ///
  /// In en, this message translates to:
  /// **'History deleted'**
  String get historyDeleted;

  /// No description provided for @fairQueueReset.
  ///
  /// In en, this message translates to:
  /// **'Fair queue reset'**
  String get fairQueueReset;

  /// No description provided for @rollDice.
  ///
  /// In en, this message translates to:
  /// **'🎲 Roll'**
  String get rollDice;

  /// No description provided for @rolling.
  ///
  /// In en, this message translates to:
  /// **'Rolling...'**
  String get rolling;

  /// No description provided for @tapToRoll.
  ///
  /// In en, this message translates to:
  /// **'Tap to roll'**
  String get tapToRoll;

  /// No description provided for @noParticipantsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No participants available'**
  String get noParticipantsAvailable;

  /// No description provided for @isNext.
  ///
  /// In en, this message translates to:
  /// **'is next!'**
  String get isNext;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @queueTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue ({count})'**
  String queueTitle(Object count);

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueEmpty;

  /// No description provided for @queueEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everyone has had a turn - next roll starts new round'**
  String get queueEmptySubtitle;

  /// No description provided for @notYetSelected.
  ///
  /// In en, this message translates to:
  /// **'Not yet selected:'**
  String get notYetSelected;

  /// No description provided for @executionDetails.
  ///
  /// In en, this message translates to:
  /// **'Execution details ({count})'**
  String executionDetails(Object count);

  /// No description provided for @noExecutionsYet.
  ///
  /// In en, this message translates to:
  /// **'No executions yet'**
  String get noExecutionsYet;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'participants'**
  String get participants;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'{taskName} - History'**
  String historyTitle(Object taskName);

  /// No description provided for @addHistoryManually.
  ///
  /// In en, this message translates to:
  /// **'Add history manually'**
  String get addHistoryManually;

  /// No description provided for @noExecutions.
  ///
  /// In en, this message translates to:
  /// **'No executions yet'**
  String get noExecutions;

  /// No description provided for @historyWillBeShown.
  ///
  /// In en, this message translates to:
  /// **'History will be shown here'**
  String get historyWillBeShown;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @totalExecutions.
  ///
  /// In en, this message translates to:
  /// **'Total executions:'**
  String get totalExecutions;

  /// No description provided for @firstExecution.
  ///
  /// In en, this message translates to:
  /// **'First execution:'**
  String get firstExecution;

  /// No description provided for @lastExecution.
  ///
  /// In en, this message translates to:
  /// **'Last execution:'**
  String get lastExecution;

  /// No description provided for @participantFrequency.
  ///
  /// In en, this message translates to:
  /// **'Participant frequency:'**
  String get participantFrequency;

  /// No description provided for @fromParticipants.
  ///
  /// In en, this message translates to:
  /// **'From {count} participants'**
  String fromParticipants(Object count);

  /// No description provided for @executionsCount.
  ///
  /// In en, this message translates to:
  /// **'Executions: {count}'**
  String executionsCount(Object count);

  /// No description provided for @lastSelectedPerson.
  ///
  /// In en, this message translates to:
  /// **'Last: {person}'**
  String lastSelectedPerson(Object person);

  /// No description provided for @queueCount.
  ///
  /// In en, this message translates to:
  /// **'Queue: {count}'**
  String queueCount(Object count);

  /// No description provided for @editHistory.
  ///
  /// In en, this message translates to:
  /// **'Edit history'**
  String get editHistory;

  /// No description provided for @manualHistoryEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual history entry'**
  String get manualHistoryEntry;

  /// No description provided for @selectedPerson.
  ///
  /// In en, this message translates to:
  /// **'Selected person:'**
  String get selectedPerson;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date and time:'**
  String get dateAndTime;

  /// No description provided for @deleteHistoryEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete history'**
  String get deleteHistoryEntry;

  /// No description provided for @deleteHistoryEntryContent.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this history entry?'**
  String get deleteHistoryEntryContent;

  /// No description provided for @historyUpdated.
  ///
  /// In en, this message translates to:
  /// **'History updated'**
  String get historyUpdated;

  /// No description provided for @historyAdded.
  ///
  /// In en, this message translates to:
  /// **'History added'**
  String get historyAdded;

  /// No description provided for @historyEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'History deleted'**
  String get historyEntryDeleted;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get selectImage;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @imageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Image not\nfound'**
  String get imageNotFound;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImage;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInfo;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English language'**
  String get englishLanguage;

  /// No description provided for @germanLanguage.
  ///
  /// In en, this message translates to:
  /// **'German language'**
  String get germanLanguage;

  /// No description provided for @useSystemLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use system language'**
  String get useSystemLanguage;

  /// No description provided for @darkModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark mode is enabled'**
  String get darkModeEnabled;

  /// No description provided for @lightModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Light mode is enabled'**
  String get lightModeEnabled;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearAllData;

  /// No description provided for @clearAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all groups, tasks, and settings'**
  String get clearAllDataSubtitle;

  /// No description provided for @clearAllDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your groups, tasks, history, and app settings. This action cannot be undone. Are you sure?'**
  String get clearAllDataConfirmation;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear data'**
  String get clearData;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data has been cleared'**
  String get allDataCleared;

  /// No description provided for @errorClearingData.
  ///
  /// In en, this message translates to:
  /// **'Error clearing data'**
  String get errorClearingData;

  /// No description provided for @clearImages.
  ///
  /// In en, this message translates to:
  /// **'Clear images'**
  String get clearImages;

  /// No description provided for @clearImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all uploaded images'**
  String get clearImagesSubtitle;

  /// No description provided for @clearImagesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all uploaded images. Groups and tasks will remain but lose their images. This action cannot be undone.'**
  String get clearImagesConfirmation;

  /// No description provided for @imagesCleared.
  ///
  /// In en, this message translates to:
  /// **'All images have been cleared'**
  String get imagesCleared;

  /// No description provided for @errorClearingImages.
  ///
  /// In en, this message translates to:
  /// **'Error clearing images'**
  String get errorClearingImages;

  /// No description provided for @aboutTasks.
  ///
  /// In en, this message translates to:
  /// **'Create persistent tasks with specific groups and track execution history.'**
  String get aboutTasks;

  /// No description provided for @aboutGroups.
  ///
  /// In en, this message translates to:
  /// **'Organize team members into reusable groups for different projects.'**
  String get aboutGroups;

  /// No description provided for @aboutFairMode.
  ///
  /// In en, this message translates to:
  /// **'Ensure everyone gets selected equally through intelligent rotation.'**
  String get aboutFairMode;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved'**
  String get allRightsReserved;

  /// No description provided for @helpContent.
  ///
  /// In en, this message translates to:
  /// **'OTurn helps distribute tasks fairly among team members.\n\n• Create groups with team members\n• Create tasks and assign them to groups\n• Use fair mode for equal distribution or random mode for chance-based selection\n• Track history to see who was selected when\n• Add or exclude members for specific tasks\n\nFor support, please contact the developer.'**
  String get helpContent;

  /// No description provided for @createTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTaskTitle;

  /// No description provided for @editTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTaskTitle;

  /// No description provided for @taskNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get taskNameLabel;

  /// No description provided for @taskImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Task image'**
  String get taskImageLabel;

  /// No description provided for @selectGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get selectGroupLabel;

  /// No description provided for @fairModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fair mode'**
  String get fairModeLabel;

  /// No description provided for @fairModeHelp.
  ///
  /// In en, this message translates to:
  /// **'Everyone gets selected once before anyone gets selected twice'**
  String get fairModeHelp;

  /// No description provided for @additionalMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional members'**
  String get additionalMembersLabel;

  /// No description provided for @excludedMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'Excluded members'**
  String get excludedMembersLabel;

  /// No description provided for @taskSaved.
  ///
  /// In en, this message translates to:
  /// **'Task saved'**
  String get taskSaved;

  /// No description provided for @addAtLeastOneMemberError.
  ///
  /// In en, this message translates to:
  /// **'Add at least one member'**
  String get addAtLeastOneMemberError;

  /// No description provided for @memberAlreadyInGroup.
  ///
  /// In en, this message translates to:
  /// **'{name} is already in the group'**
  String memberAlreadyInGroup(Object name);

  /// No description provided for @noMembersAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No members added yet'**
  String get noMembersAddedYet;

  /// No description provided for @allEveryoneHadTurn.
  ///
  /// In en, this message translates to:
  /// **'Everyone has had a turn - next roll starts new round'**
  String get allEveryoneHadTurn;

  /// No description provided for @executionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Execution details ({count})'**
  String executionDetailsTitle(Object count);

  /// No description provided for @queueIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueIsEmpty;

  /// No description provided for @stillToCome.
  ///
  /// In en, this message translates to:
  /// **'Still to come:'**
  String get stillToCome;

  /// No description provided for @rollPotatoDice.
  ///
  /// In en, this message translates to:
  /// **'🥔 Roll'**
  String get rollPotatoDice;

  /// No description provided for @rollDiceAction.
  ///
  /// In en, this message translates to:
  /// **'🎲 Roll'**
  String get rollDiceAction;

  /// No description provided for @switchToRandomModeAction.
  ///
  /// In en, this message translates to:
  /// **'Switch to random mode'**
  String get switchToRandomModeAction;

  /// No description provided for @switchToFairModeAction.
  ///
  /// In en, this message translates to:
  /// **'Switch to fair mode'**
  String get switchToFairModeAction;

  /// No description provided for @showHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get showHistoryAction;

  /// No description provided for @deleteHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Delete history'**
  String get deleteHistoryAction;

  /// No description provided for @deleteHistoryActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all previous executions'**
  String get deleteHistoryActionSubtitle;

  /// No description provided for @resetFairQueueAction.
  ///
  /// In en, this message translates to:
  /// **'Reset fair queue'**
  String get resetFairQueueAction;

  /// No description provided for @resetFairQueueActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reshuffle queue'**
  String get resetFairQueueActionSubtitle;

  /// No description provided for @pleaseSelectGroup.
  ///
  /// In en, this message translates to:
  /// **'Please select a group'**
  String get pleaseSelectGroup;

  /// No description provided for @selectGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get selectGroupAction;

  /// No description provided for @chooseGroup.
  ///
  /// In en, this message translates to:
  /// **'Choose group'**
  String get chooseGroup;

  /// No description provided for @randomSelectionEachRoll.
  ///
  /// In en, this message translates to:
  /// **'Random selection on each roll'**
  String get randomSelectionEachRoll;

  /// No description provided for @excludeMembers.
  ///
  /// In en, this message translates to:
  /// **'Exclude members'**
  String get excludeMembers;

  /// No description provided for @excludeMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Exclude members'**
  String get excludeMembersTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
