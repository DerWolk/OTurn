// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OTurn';

  @override
  String get appDescription =>
      'OTurn - Fair task distribution for teams. Roll fairly who\'s next!';

  @override
  String get about => 'About OTurn';

  @override
  String get aboutDescription =>
      'OTurn helps with fair distribution of tasks in teams.';

  @override
  String get developedBy => 'Developed by Waldemar Stockmann';

  @override
  String get understood => 'Understood';

  @override
  String get help => 'Help';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get potatoModeEnabled => 'Potato for President! 🥔';

  @override
  String get potatoModeDisabled => 'Potato mode disabled';

  @override
  String get tasks => 'Tasks';

  @override
  String get groups => 'Groups';

  @override
  String get noTasksAvailable => 'No tasks available';

  @override
  String get noTasksSubtitle =>
      'Create your first task for a team\nand let the fair rolling begin!';

  @override
  String get createFirstTask => 'Create first task';

  @override
  String get noGroupsAvailable => 'No groups available';

  @override
  String get noGroupsSubtitle =>
      'Create your first group with team members\nto distribute tasks fairly';

  @override
  String get createFirstGroup => 'Create first group';

  @override
  String deleteTaskTitle(Object taskName) {
    return 'Delete task \"$taskName\"?';
  }

  @override
  String get deleteTaskContent => 'This action cannot be undone.';

  @override
  String deleteGroupTitle(Object groupName) {
    return 'Delete group \"$groupName\"?';
  }

  @override
  String get deleteGroupContent => 'This action cannot be undone.';

  @override
  String get unknownGroup => 'Unknown group';

  @override
  String get fairMode => 'Fair mode';

  @override
  String get randomMode => 'Random mode';

  @override
  String get createGroup => 'Create group';

  @override
  String get editGroup => 'Edit group';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNameHint => 'e.g. Marketing Team';

  @override
  String get groupNameRequired => 'Please enter a group name';

  @override
  String get groupImage => 'Group image';

  @override
  String get addMember => 'Add member';

  @override
  String get memberNameHint => 'Enter name';

  @override
  String membersCount(Object count) {
    return 'Members ($count)';
  }

  @override
  String get noMembersYet => 'No members added yet';

  @override
  String memberAlreadyExists(Object name) {
    return '$name is already in the group';
  }

  @override
  String get addAtLeastOneMember => 'Add at least one member';

  @override
  String get createTask => 'Create task';

  @override
  String get editTask => 'Edit task';

  @override
  String get taskName => 'Task name';

  @override
  String get taskNameHint => 'e.g. Write email to management';

  @override
  String get taskNameRequired => 'Please enter a task name';

  @override
  String get taskImage => 'Task image';

  @override
  String get selectGroup => 'Select group';

  @override
  String get selectGroupRequired => 'Please select a group';

  @override
  String get fairModeToggle => 'Fair mode';

  @override
  String get fairModeDescription => 'Fair rotation - everyone gets a turn once';

  @override
  String get additionalMembers => 'Additional members';

  @override
  String get additionalMembersHint => 'Add people not in the group';

  @override
  String get excludedMembers => 'Excluded members';

  @override
  String get excludedMembersHint => 'Exclude people from this task';

  @override
  String get taskOptions => 'Task options';

  @override
  String get switchToRandomMode => 'Switch to random mode';

  @override
  String get switchToFairMode => 'Switch to fair mode';

  @override
  String get randomModeDescription =>
      'Completely random selection on each roll';

  @override
  String get showHistory => 'Show history';

  @override
  String get deleteHistory => 'Delete history';

  @override
  String get deleteHistorySubtitle => 'Delete all previous executions';

  @override
  String get resetFairQueue => 'Reset fair queue';

  @override
  String get resetFairQueueSubtitle => 'Reshuffle queue';

  @override
  String get fairModeActivated => 'Fair mode activated';

  @override
  String get randomModeActivated => 'Random mode activated';

  @override
  String get historyDeleted => 'History deleted';

  @override
  String get fairQueueReset => 'Fair queue reset';

  @override
  String get rollDice => '🎲 Roll';

  @override
  String get rolling => 'Rolling...';

  @override
  String get tapToRoll => 'Tap to roll';

  @override
  String get noParticipantsAvailable => 'No participants available';

  @override
  String get isNext => 'is next!';

  @override
  String get tryAgain => 'Try again';

  @override
  String get done => 'Done';

  @override
  String queueTitle(Object count) {
    return 'Queue ($count)';
  }

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String get queueEmptySubtitle =>
      'Everyone has had a turn - next roll starts new round';

  @override
  String get notYetSelected => 'Not yet selected:';

  @override
  String executionDetails(Object count) {
    return 'Execution details ($count)';
  }

  @override
  String get noExecutionsYet => 'No executions yet';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get participants => 'participants';

  @override
  String get history => 'History';

  @override
  String historyTitle(Object taskName) {
    return '$taskName - History';
  }

  @override
  String get addHistoryManually => 'Add history manually';

  @override
  String get noExecutions => 'No executions yet';

  @override
  String get historyWillBeShown => 'History will be shown here';

  @override
  String get summary => 'Summary';

  @override
  String get totalExecutions => 'Total executions:';

  @override
  String get firstExecution => 'First execution:';

  @override
  String get lastExecution => 'Last execution:';

  @override
  String get participantFrequency => 'Participant frequency:';

  @override
  String fromParticipants(Object count) {
    return 'From $count participants';
  }

  @override
  String executionsCount(Object count) {
    return 'Executions: $count';
  }

  @override
  String lastSelectedPerson(Object person) {
    return 'Last: $person';
  }

  @override
  String queueCount(Object count) {
    return 'Queue: $count';
  }

  @override
  String get editHistory => 'Edit history';

  @override
  String get manualHistoryEntry => 'Manual history entry';

  @override
  String get selectedPerson => 'Selected person:';

  @override
  String get dateAndTime => 'Date and time:';

  @override
  String get deleteHistoryEntry => 'Delete history';

  @override
  String get deleteHistoryEntryContent =>
      'Do you really want to delete this history entry?';

  @override
  String get historyUpdated => 'History updated';

  @override
  String get historyAdded => 'History added';

  @override
  String get historyEntryDeleted => 'History deleted';

  @override
  String get selectImage => 'Select image';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get gallery => 'Gallery';

  @override
  String get remove => 'Remove';

  @override
  String get imageNotFound => 'Image not\nfound';

  @override
  String get addImage => 'Add image';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get appInfo => 'App Information';

  @override
  String get englishLanguage => 'English language';

  @override
  String get germanLanguage => 'German language';

  @override
  String get useSystemLanguage => 'Use system language';

  @override
  String get darkModeEnabled => 'Dark mode is enabled';

  @override
  String get lightModeEnabled => 'Light mode is enabled';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get clearAllDataSubtitle => 'Delete all groups, tasks, and settings';

  @override
  String get clearAllDataConfirmation =>
      'This will permanently delete all your groups, tasks, history, and app settings. This action cannot be undone. Are you sure?';

  @override
  String get clearData => 'Clear data';

  @override
  String get allDataCleared => 'All data has been cleared';

  @override
  String get errorClearingData => 'Error clearing data';

  @override
  String get clearImages => 'Clear images';

  @override
  String get clearImagesSubtitle => 'Delete all uploaded images';

  @override
  String get clearImagesConfirmation =>
      'This will permanently delete all uploaded images. Groups and tasks will remain but lose their images. This action cannot be undone.';

  @override
  String get imagesCleared => 'All images have been cleared';

  @override
  String get errorClearingImages => 'Error clearing images';

  @override
  String get aboutTasks =>
      'Create persistent tasks with specific groups and track execution history.';

  @override
  String get aboutGroups =>
      'Organize team members into reusable groups for different projects.';

  @override
  String get aboutFairMode =>
      'Ensure everyone gets selected equally through intelligent rotation.';

  @override
  String get allRightsReserved => 'All rights reserved';

  @override
  String get helpContent =>
      'OTurn helps distribute tasks fairly among team members.\n\n• Create groups with team members\n• Create tasks and assign them to groups\n• Use fair mode for equal distribution or random mode for chance-based selection\n• Track history to see who was selected when\n• Add or exclude members for specific tasks\n\nFor support, please contact the developer.';

  @override
  String get createTaskTitle => 'Create task';

  @override
  String get editTaskTitle => 'Edit task';

  @override
  String get taskNameLabel => 'Task name';

  @override
  String get taskImageLabel => 'Task image';

  @override
  String get selectGroupLabel => 'Select group';

  @override
  String get fairModeLabel => 'Fair mode';

  @override
  String get fairModeHelp =>
      'Everyone gets selected once before anyone gets selected twice';

  @override
  String get additionalMembersLabel => 'Additional members';

  @override
  String get excludedMembersLabel => 'Excluded members';

  @override
  String get taskSaved => 'Task saved';

  @override
  String get addAtLeastOneMemberError => 'Add at least one member';

  @override
  String memberAlreadyInGroup(Object name) {
    return '$name is already in the group';
  }

  @override
  String get noMembersAddedYet => 'No members added yet';

  @override
  String get allEveryoneHadTurn =>
      'Everyone has had a turn - next roll starts new round';

  @override
  String executionDetailsTitle(Object count) {
    return 'Execution details ($count)';
  }

  @override
  String get queueIsEmpty => 'Queue is empty';

  @override
  String get stillToCome => 'Still to come:';

  @override
  String get rollPotatoDice => '🥔 Roll';

  @override
  String get rollDiceAction => '🎲 Roll';

  @override
  String get switchToRandomModeAction => 'Switch to random mode';

  @override
  String get switchToFairModeAction => 'Switch to fair mode';

  @override
  String get showHistoryAction => 'Show history';

  @override
  String get deleteHistoryAction => 'Delete history';

  @override
  String get deleteHistoryActionSubtitle => 'Delete all previous executions';

  @override
  String get resetFairQueueAction => 'Reset fair queue';

  @override
  String get resetFairQueueActionSubtitle => 'Reshuffle queue';

  @override
  String get pleaseSelectGroup => 'Please select a group';

  @override
  String get selectGroupAction => 'Select group';

  @override
  String get chooseGroup => 'Choose group';

  @override
  String get randomSelectionEachRoll => 'Random selection on each roll';

  @override
  String get excludeMembers => 'Exclude members';

  @override
  String get excludeMembersTitle => 'Exclude members';

  @override
  String get aboutTasksTitle => '🎯 Tasks';

  @override
  String get aboutTasksDescription =>
      '• Create recurring tasks for your groups\n• Choose between random and fair mode\n• Track the history of all executions';

  @override
  String get aboutGroupsTitle => '👥 Groups';

  @override
  String get aboutGroupsDescription =>
      '• Organize team members into reusable groups\n• Perfect for different projects and teams';

  @override
  String get aboutFairModeTitle => '⚖️ Fair Mode';

  @override
  String get aboutFairModeDescription =>
      '• Everyone gets a turn once before the next round starts\n• Perfect for recurring tasks like taking out trash';

  @override
  String get aboutRandomModeTitle => '🎲 Random Mode';

  @override
  String get aboutRandomModeDescription =>
      '• Completely random selection on each roll\n• Ideal for spontaneous decisions';

  @override
  String get aboutGroupsManagementDescription =>
      '• Manage teams and their members\n• Autocomplete based on existing names\n• Easy editing and management';

  @override
  String get aboutDataStorageTitle => '💾 Data Storage';

  @override
  String get aboutDataStorageDescriptionWeb =>
      '• All data is stored locally in the browser\n• No external servers or cloud services';

  @override
  String get aboutDataStorageDescriptionMobile =>
      '• All data is stored only on this device\n• No servers, no internet connection required';

  @override
  String get aboutThisAppTitle => '📱 About this App';

  @override
  String get allRightsReservedShort => '© 2025 All rights reserved';

  @override
  String get extractFromPhoto => 'Extract from photo';

  @override
  String get extractNamesFromPhoto => 'Extract names from photo';

  @override
  String get selectPhotoForExtraction => 'Select photo to extract names';

  @override
  String get processingImage => 'Processing image...';

  @override
  String get extractedNames => 'Extracted names';

  @override
  String get noNamesFound => 'No names found in image';

  @override
  String get addExtractedNames => 'Add extracted names';

  @override
  String get extractionError => 'Error extracting names from image';

  @override
  String extractionSuccess(Object count) {
    return 'Successfully extracted $count names';
  }

  @override
  String get photoExtraction => 'Photo extraction';

  @override
  String get camera => 'Camera';

  @override
  String get selectTextRegion => 'Select text region';

  @override
  String get cropInstruction => 'Drag to select the area with names';
}
