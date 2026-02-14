import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('en'),
    Locale('tr'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'INVENTRA'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

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

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Are you tired of\nthe mess?'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Stop asking \"Where did I put that?\".\nTake control of your physical storage.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Organize in Seconds'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Create spaces, scan QR codes, and\ncreate your digital inventory instantly.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Find It Instantly'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Search your physical world like a search\nengine. Never lose track of your inventory\nagain.'**
  String get onboardingDesc3;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @newToInventra.
  ///
  /// In en, this message translates to:
  /// **'New to Inventra? '**
  String get newToInventra;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @welcomeToInventra.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Inventra'**
  String get welcomeToInventra;

  /// No description provided for @manageInventoryProfessionally.
  ///
  /// In en, this message translates to:
  /// **'Manage your inventory professionally.'**
  String get manageInventoryProfessionally;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinInventra.
  ///
  /// In en, this message translates to:
  /// **'Join INVENTRA to manage your inventory\nseamlessly.'**
  String get joinInventra;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @enterEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a\npassword reset link.'**
  String get enterEmailForReset;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset Link Sent'**
  String get resetLinkSent;

  /// No description provided for @resetLinkSentMessage.
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to your email address.'**
  String get resetLinkSentMessage;

  /// No description provided for @failedToSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link'**
  String get failedToSendResetLink;

  /// No description provided for @backToLogIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Log In'**
  String get backToLogIn;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmNewPassword;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Your password must be at least 8 characters\nlong and include a combination of letters,\nnumbers, and symbols.'**
  String get passwordRequirements;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, Alex'**
  String get helloUser;

  /// No description provided for @mySpaces.
  ///
  /// In en, this message translates to:
  /// **'My Spaces'**
  String get mySpaces;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @sortNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get sortNameAZ;

  /// No description provided for @sortNameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get sortNameZA;

  /// No description provided for @sortItemCountLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Item Count (Low to High)'**
  String get sortItemCountLowHigh;

  /// No description provided for @sortItemCountHighLow.
  ///
  /// In en, this message translates to:
  /// **'Item Count (High to Low)'**
  String get sortItemCountHighLow;

  /// No description provided for @noSpacesYet.
  ///
  /// In en, this message translates to:
  /// **'No spaces yet'**
  String get noSpacesYet;

  /// No description provided for @createFirstSpace.
  ///
  /// In en, this message translates to:
  /// **'Create your first space to start organizing your items'**
  String get createFirstSpace;

  /// No description provided for @searchItemsSpaces.
  ///
  /// In en, this message translates to:
  /// **'Search items, spaces...'**
  String get searchItemsSpaces;

  /// No description provided for @allResults.
  ///
  /// In en, this message translates to:
  /// **'All Results'**
  String get allResults;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @spaces.
  ///
  /// In en, this message translates to:
  /// **'Spaces'**
  String get spaces;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @searchForItemsOrSpaces.
  ///
  /// In en, this message translates to:
  /// **'Search for items or spaces'**
  String get searchForItemsOrSpaces;

  /// No description provided for @spacesLabel.
  ///
  /// In en, this message translates to:
  /// **'SPACES'**
  String get spacesLabel;

  /// No description provided for @itemsLabel.
  ///
  /// In en, this message translates to:
  /// **'ITEMS'**
  String get itemsLabel;

  /// No description provided for @addNewStorage.
  ///
  /// In en, this message translates to:
  /// **'Add New Storage'**
  String get addNewStorage;

  /// No description provided for @createStorage.
  ///
  /// In en, this message translates to:
  /// **'Create Storage'**
  String get createStorage;

  /// No description provided for @storageName.
  ///
  /// In en, this message translates to:
  /// **'Storage Name'**
  String get storageName;

  /// No description provided for @storageLocation.
  ///
  /// In en, this message translates to:
  /// **'Where is it located?'**
  String get storageLocation;

  /// No description provided for @enterStorageName.
  ///
  /// In en, this message translates to:
  /// **'Enter storage name'**
  String get enterStorageName;

  /// No description provided for @pleaseEnterStorageName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a storage name'**
  String get pleaseEnterStorageName;

  /// No description provided for @storageType.
  ///
  /// In en, this message translates to:
  /// **'STORAGE TYPE'**
  String get storageType;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get details;

  /// No description provided for @qrIdAutoGenerated.
  ///
  /// In en, this message translates to:
  /// **'QR ID: INV-2024 (Auto-generated)'**
  String get qrIdAutoGenerated;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get newItem;

  /// No description provided for @saveItem.
  ///
  /// In en, this message translates to:
  /// **'Save Item'**
  String get saveItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'ITEM NAME'**
  String get itemName;

  /// No description provided for @enterItemName.
  ///
  /// In en, this message translates to:
  /// **'Enter item name'**
  String get enterItemName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @addTags.
  ///
  /// In en, this message translates to:
  /// **'Add Tags'**
  String get addTags;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add Notes'**
  String get addNotes;

  /// No description provided for @addingTo.
  ///
  /// In en, this message translates to:
  /// **'ADDING TO'**
  String get addingTo;

  /// No description provided for @pleaseEnterItemName.
  ///
  /// In en, this message translates to:
  /// **'Please enter an item name'**
  String get pleaseEnterItemName;

  /// No description provided for @selectTags.
  ///
  /// In en, this message translates to:
  /// **'Select Tags'**
  String get selectTags;

  /// No description provided for @enterNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter notes...'**
  String get enterNotes;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'AREA'**
  String get area;

  /// No description provided for @exactLocation.
  ///
  /// In en, this message translates to:
  /// **'EXACT LOCATION'**
  String get exactLocation;

  /// No description provided for @defaultLocation.
  ///
  /// In en, this message translates to:
  /// **'Bottom shelf, left side compartment.'**
  String get defaultLocation;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @moveItem.
  ///
  /// In en, this message translates to:
  /// **'Move Item'**
  String get moveItem;

  /// No description provided for @selectStorageToMove.
  ///
  /// In en, this message translates to:
  /// **'Select a storage to move this item to:'**
  String get selectStorageToMove;

  /// No description provided for @itemMovedTo.
  ///
  /// In en, this message translates to:
  /// **'Item moved to {spaceName}'**
  String itemMovedTo(String spaceName);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @aboutThemes.
  ///
  /// In en, this message translates to:
  /// **'About Themes'**
  String get aboutThemes;

  /// No description provided for @themesDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a theme that suits your environment. Dark mode is perfect for low-light storage areas, while Light mode offers maximum clarity.'**
  String get themesDescription;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @changesSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get changesSavedSuccessfully;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.'**
  String get deleteAccountConfirmation;

  /// No description provided for @accountDeletionRequested.
  ///
  /// In en, this message translates to:
  /// **'Account deletion requested'**
  String get accountDeletionRequested;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutInventra.
  ///
  /// In en, this message translates to:
  /// **'About Inventra'**
  String get aboutInventra;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 3.0.1'**
  String get version;

  /// No description provided for @inventraVersion.
  ///
  /// In en, this message translates to:
  /// **'INVENTRA v3.0.1'**
  String get inventraVersion;

  /// No description provided for @yourPersonalInventoryManager.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Inventory Manager'**
  String get yourPersonalInventoryManager;

  /// No description provided for @inventraDescription.
  ///
  /// In en, this message translates to:
  /// **'INVENTRA helps you organize and track your belongings across all storage spaces. Never lose track of where you put things again!'**
  String get inventraDescription;

  /// No description provided for @qrCodeScanning.
  ///
  /// In en, this message translates to:
  /// **'QR Code Scanning'**
  String get qrCodeScanning;

  /// No description provided for @qrCodeScanningDesc.
  ///
  /// In en, this message translates to:
  /// **'Quickly access storage spaces with QR codes'**
  String get qrCodeScanningDesc;

  /// No description provided for @smartSearch.
  ///
  /// In en, this message translates to:
  /// **'Smart Search'**
  String get smartSearch;

  /// No description provided for @smartSearchDesc.
  ///
  /// In en, this message translates to:
  /// **'Find items instantly across all your spaces'**
  String get smartSearchDesc;

  /// No description provided for @darkModeFeature.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeFeature;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Perfect for low-light storage areas'**
  String get darkModeDesc;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024 INVENTRA. All rights reserved.'**
  String get copyright;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for organized people'**
  String get madeWithLove;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @faqCreateStorage.
  ///
  /// In en, this message translates to:
  /// **'How do I create a new storage space?'**
  String get faqCreateStorage;

  /// No description provided for @faqCreateStorageAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"Add New Space\" card on the home screen or use the + button to create a new storage space.'**
  String get faqCreateStorageAnswer;

  /// No description provided for @faqScanQR.
  ///
  /// In en, this message translates to:
  /// **'How do I scan a QR code?'**
  String get faqScanQR;

  /// No description provided for @faqScanQRAnswer.
  ///
  /// In en, this message translates to:
  /// **'Navigate to the Scanner tab at the bottom of the screen, then point your camera at the QR code.'**
  String get faqScanQRAnswer;

  /// No description provided for @faqMoveItems.
  ///
  /// In en, this message translates to:
  /// **'Can I move items between spaces?'**
  String get faqMoveItems;

  /// No description provided for @faqMoveItemsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes! Open the item details and tap \"Move\" to relocate it to a different storage space.'**
  String get faqMoveItemsAnswer;

  /// No description provided for @faqPrintQR.
  ///
  /// In en, this message translates to:
  /// **'How do I print QR codes?'**
  String get faqPrintQR;

  /// No description provided for @faqPrintQRAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open a storage space, tap the printer icon next to the QR code to print or save the label.'**
  String get faqPrintQRAnswer;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'support@inventra.app'**
  String get supportEmail;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @liveChatAvailability.
  ///
  /// In en, this message translates to:
  /// **'Available 9 AM - 6 PM'**
  String get liveChatAvailability;

  /// No description provided for @documentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get documentation;

  /// No description provided for @browseGuides.
  ///
  /// In en, this message translates to:
  /// **'Browse our guides'**
  String get browseGuides;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @alignQRCode.
  ///
  /// In en, this message translates to:
  /// **'Align QR code within frame'**
  String get alignQRCode;

  /// No description provided for @enterCodeManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Code Manually'**
  String get enterCodeManually;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get enterCode;

  /// No description provided for @codeExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. INV-2024-001'**
  String get codeExample;

  /// No description provided for @searchingFor.
  ///
  /// In en, this message translates to:
  /// **'Searching for: {code}'**
  String searchingFor(String code);

  /// No description provided for @manageSpaces.
  ///
  /// In en, this message translates to:
  /// **'Manage Spaces'**
  String get manageSpaces;

  /// No description provided for @noSpacesToManage.
  ///
  /// In en, this message translates to:
  /// **'No spaces to manage'**
  String get noSpacesToManage;

  /// No description provided for @deleteSpaceQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Space?'**
  String get deleteSpaceQuestion;

  /// No description provided for @deleteSpaceConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{spaceName}\"? All items inside will also be deleted.'**
  String deleteSpaceConfirmation(String spaceName);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(int count);

  /// No description provided for @boxId.
  ///
  /// In en, this message translates to:
  /// **'BOX ID'**
  String get boxId;

  /// No description provided for @itemSingular.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemSingular;

  /// No description provided for @itemPlural.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemPlural;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYet;

  /// No description provided for @addFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add your first item to this space'**
  String get addFirstItem;

  /// No description provided for @editNameLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit Name & Location'**
  String get editNameLocation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @loggedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccessfully;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationItemAdded.
  ///
  /// In en, this message translates to:
  /// **'Item Added'**
  String get notificationItemAdded;

  /// No description provided for @notificationItemAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'{itemName} added to \'{spaceName}\''**
  String notificationItemAddedMessage(String itemName, String spaceName);

  /// No description provided for @notificationSpaceCreated.
  ///
  /// In en, this message translates to:
  /// **'New Space Created'**
  String get notificationSpaceCreated;

  /// No description provided for @notificationSpaceCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'You successfully created \'{spaceName}\''**
  String notificationSpaceCreatedMessage(String spaceName);

  /// No description provided for @notificationWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to INVENTRA'**
  String get notificationWelcome;

  /// No description provided for @notificationWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Start by scanning your first item'**
  String get notificationWelcomeMessage;

  /// No description provided for @notificationSystemUpdate.
  ///
  /// In en, this message translates to:
  /// **'System Update'**
  String get notificationSystemUpdate;

  /// No description provided for @notificationSystemUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'INVENTRA v2.1 is now live'**
  String get notificationSystemUpdateMessage;

  /// No description provided for @timeAgo2m.
  ///
  /// In en, this message translates to:
  /// **'2m ago'**
  String get timeAgo2m;

  /// No description provided for @timeAgo1h.
  ///
  /// In en, this message translates to:
  /// **'1h ago'**
  String get timeAgo1h;

  /// No description provided for @timeAgo1d.
  ///
  /// In en, this message translates to:
  /// **'1d ago'**
  String get timeAgo1d;

  /// No description provided for @timeAgo2d.
  ///
  /// In en, this message translates to:
  /// **'2d ago'**
  String get timeAgo2d;

  /// No description provided for @ago.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get ago;

  /// No description provided for @newSpace.
  ///
  /// In en, this message translates to:
  /// **'Add New Space'**
  String get newSpace;

  /// No description provided for @addNewItem.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItem;

  /// No description provided for @manageBox.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Box'**
  String get manageBox;

  /// No description provided for @manageDrawer.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Drawer'**
  String get manageDrawer;

  /// No description provided for @manageShelf.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Shelf'**
  String get manageShelf;

  /// No description provided for @manageCabinet.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Cabinet'**
  String get manageCabinet;

  /// No description provided for @deleteBox.
  ///
  /// In en, this message translates to:
  /// **'Delete Box'**
  String get deleteBox;

  /// No description provided for @deleteDrawer.
  ///
  /// In en, this message translates to:
  /// **'Delete Drawer'**
  String get deleteDrawer;

  /// No description provided for @deleteShelf.
  ///
  /// In en, this message translates to:
  /// **'Delete Shelf'**
  String get deleteShelf;

  /// No description provided for @deleteCabinet.
  ///
  /// In en, this message translates to:
  /// **'Delete Cabinet'**
  String get deleteCabinet;

  /// No description provided for @editBox.
  ///
  /// In en, this message translates to:
  /// **'Edit Box'**
  String get editBox;

  /// No description provided for @editDrawer.
  ///
  /// In en, this message translates to:
  /// **'Edit Drawer'**
  String get editDrawer;

  /// No description provided for @editShelf.
  ///
  /// In en, this message translates to:
  /// **'Edit Shelf'**
  String get editShelf;

  /// No description provided for @editCabinet.
  ///
  /// In en, this message translates to:
  /// **'Edit Cabinet'**
  String get editCabinet;

  /// No description provided for @box.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get box;

  /// No description provided for @drawer.
  ///
  /// In en, this message translates to:
  /// **'Drawer'**
  String get drawer;

  /// No description provided for @shelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get shelf;

  /// No description provided for @cabinet.
  ///
  /// In en, this message translates to:
  /// **'Cabinet'**
  String get cabinet;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @deleteItemQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Item?'**
  String get deleteItemQuestion;

  /// No description provided for @deleteItemConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{itemName}\"? This action cannot be undone.'**
  String deleteItemConfirmation(String itemName);

  /// No description provided for @qrCodeSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'QR code saved to gallery'**
  String get qrCodeSavedToGallery;

  /// No description provided for @failedToSaveQRCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to save QR code'**
  String get failedToSaveQRCode;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please allow access in settings.'**
  String get permissionDenied;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @photoPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'INVENTRA needs permission to save QR codes to your photo library. Please enable access in Settings.'**
  String get photoPermissionMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'INVENTRA needs camera access to scan QR codes. Please grant permission to use this feature.'**
  String get cameraPermissionMessage;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
