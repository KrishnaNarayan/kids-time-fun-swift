/*
 *  KidsTimeFunAppConstants.h
 *  KidsTimeFun
 *
 //  Created by Jagmeet Chawla on 4/12/09.
 //  Revised by Krishna Narayan on 9/17/09
 //		 - Updated graphics
 //		 - Added tell a friend
 //		 - Changed app name to Kids Learn To Tell Time
 //	 Revised by Krishna Narayan on 10/14/09
 //	     - Added conditional compilation for multiple languages - Spanish, French, Filipino, Portuguese, Turkish, Korean
 //  Modified by SVV Satyanarayana, under contract to NSC Partners LLC on 28/04/10.
 //  Revised by Krishna Narayan on 8/20/10
 //		 - Update graphics for back to school
 //		 - Changed name to Kids Time Fun
 //		 - Revised icons for Kids Fraction Fun to Kids Math Fun~5th Grade and Learn to Tell Time to Kids Time Fun
 //		 - Next version will include additional languages...will need to change the buttons, graphics are hard coded :(
 //	 Revised by Krishna Narayan on 10/29/10 - Revised graphics and UI.  Fixed timers, fixed try again, changed fonts, and added new backgrounds.
 //  Revised by Krishna Narayan on 1/22/11 - Revised graphics, fixed SET TIME smoother movement of hands, detects touches closer to the hand now.
 //  Revised by Krishna Narayan on 3/9/12 - Added sound files and kids voice files
 //  Revised by Krishna Narayan on 12/14/12 - Tested new sound files, revised text, copyright, released as universal version. Satyam debugged memory leaks
 //  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.
 */


//CONDITIONAL COMPILATION FLAGS
//Set languages options
#define CC_ENGLISH 1
#define CC_SPANISH 2
#define CC_FRENCH 3
#define CC_FILIPINO 4
#define CC_PORTUGUESE 5
#define CC_TURKISH 6
#define CC_HAWAIIAN 7
#define CC_KOREAN 8

//SET LANGUAGE HERE

#define CC_LANGUAGE CC_ENGLISH

//Screens
#define kScrNone 0
#define kScrMenu 1
#define kScrTellTime 2
#define kScrSetTime 3
#define kScrTimeBefore 4
#define kScrTimeAfter 5
#define kScrElapsedTime 6
#define kScrRecordScore 7
#define kScrTopScores 8
#define kScrSettings 9
#define kTellAFriend 10
#define kScrHelp 11
#define kScrAbout 12
#define kScrTutorial 13
#define kScrSupport 14
#define kScrMoreApplications 15
//Activities
#define kActNone -1
#define kNumberOfActivities 6
#define kActTellTime 0
#define kActTimeBefore 1
#define kActTimeAfter 2
#define kActElapsedTime 3
#define kActSetTime 4
#define kActMixed 5
//Activity Type
#define kActTypeNone -1
#define kNumberOfActivityTypes 2
#define kActTypeNumbered 0
#define kActTypeTimed 1
//Activity Level
#define kActLevelNone -1
#define kNumberOfActivityLevels 4
#define kActLevelYellowBelt 0
#define kActLevelGreenBelt 1
#define kActLevelRedBelt 2
#define kActLevelBlackBelt 3
//Grade Level (the new single difficulty knob; drives clock-time increments)
#define kGradeNone -1
#define kNumberOfGrades 3
#define kGradeFirst 0
#define kGradeSecond 1
#define kGradeThird 2
//Activity Individual Question Progress
#define kActQuestionNotDisplayed 0
#define kActQuestionAsked 1
#define kActQuestionAnswered 2
#define kActQuestionSkipped 3
//Activity Result
#define kActResultRight 0
#define kActResultWrong 1
#define kActResultUnanswered 2
//Application Defaults
#define kDefaultActivityType kActTypeNumbered
#define kDefaultActivityLevel kActLevelYellowBelt
#define kDefaultGradeLevel kGradeFirst
#define kDefaultMaxNumberOfQuestions 10
#define kDefaultMaxTimeInSeconds 60
#define kDefaultSizeOfTopScoreList 100
#define kDefaultAppSoundState YES
//Application Strings

#if CC_LANGUAGE == CC_ENGLISH

#define kDefaultPlayerName @"Player 1"
#define kStrAppTitle @"Kids Time Fun"
#define kStrTellTime @"Tell Time"
#define kStrSetTime @"Set Time"
#define kStrTimeBefore @"Time Before"
#define kStrTimeAfter @"Time After"
#define kStrElapsedTime @"Elapsed Time"
#define kStrHelp @"More Fun Apps"
#define kStrAbout @"About"
#define kStrSettings @"Settings"
#define kStrTutorial @"Tutorial"
#define kStrResult @"Your Score"
#define kStrTopScores @"Top Scores"
#define kStrMixed @"Mixed"
#define kStrTellAFriend @"Tell a Friend"
#define kStrTopScoreMessage @"Congratulations! You have a new top score."
#define kStrNoTopScoreMessage @"Try again to get a top score."
#define kStrYourNameHereMessage @"Your name"
#define kStrSave @"Save"
#define kStrDone @"Go"
#define kStrVarListScore @"Top %i Scores"
#define kStrVarMaxQuestions @"%i Questions"
#define kStrOneMinute @"1 Minute"
#define kStrVarMaxMinutes @"%i Minutes"
#define kStrBlank @""
#define kStrRankBelts @"My Belts"
#define kStrGradeLevel @"Grade Level"
#define kStrFirstGrade @"First Grade"
#define kStrSecondGrade @"Second Grade"
#define kStrThirdGrade @"Third Grade"
#define kStrFirstGradeInfo @"Start here! Practice o'clock and half past with simple, friendly clocks."
#define kStrSecondGradeInfo @"Ready for more — practice quarter past, half past, and quarter to."
#define kStrThirdGradeInfo @"The full challenge — read the clock to every five minutes."
#define kStrNoBeltYet @"No belt yet"

#elif CC_LANGUAGE == CC_SPANISH


# define kDefaultPlayerName @ "Jugador 1" 
# define kStrAppTitle @ "Diversión KidsTime" 
# define kStrTellTime @ "Dígale a Time" 
# define kStrSetTime @ "Set Time" 
# define kStrTimeBefore @ "Antes de Tiempo" 
# define kStrTimeAfter @ "Time After" 
# define kStrElapsedTime @ "Tiempo Transcurrido" 
# define kStrHelp @ "More Fun Apps" 
# define kStrAbout @ "Acerca de" 
# define kStrSettings @ "Configuración" 
# define kStrTutorial @ "Tutorial" 
# define kStrResult @ "Su puntuación" 
# define kStrTopScores @ "las calificaciones más altas" 
# define kStrMixed @ "mixta" 
# define kStrTellAFriend @ "Recomendar a un amigo" 
# define kStrTopScoreMessage @ "¡Felicitaciones! Usted tiene una puntuación máxima nuevo". 
# define kStrNoTopScoreMessage @ "Trate de nuevo para obtener una puntuación alta." 
# define kStrYourNameHereMessage @ "Tu nombre" 
# define kStrSave @ "Guardar" 
# define kStrDone @ "Go" 
# define kStrVarListScore @ "Top %i Partituras" 
# define kStrVarMaxQuestions @ "Cuestiones %i" 
# define kStrOneMinute @ "1 minuto" 
# define kStrVarMaxMinutes @ "%i Minutos" 
# define kStrBlank @ ""

#elif CC_LANGUAGE == CC_FRENCH 

# define kDefaultPlayerName @ "Joueur 1" 
# define kStrAppTitle @ "Apprendre à lire l'heure" 
# define kStrTellTime @ "Dites-Time" 
# define kStrSetTime @ "Time Set" 
# define kStrTimeBefore @ "Time Before" 
# define kStrTimeAfter @ "Time After" 
# define kStrElapsedTime @ "Temps écoulé" 
# define kStrHelp @ "More Fun Apps" 
# define kStrAbout @ "A propos" 
# define kStrSettings @ "Paramètres" 
# define kStrTutorial @ "Tutorial" 
# define kStrResult @ "Your Score" 
# define kStrTopScores @ "Les meilleurs selon nous" 
# define kStrMixed @ "mixte" 
# define kStrTellAFriend @ "Envoyer à un ami" 
# define kStrTopScoreMessage @ "Félicitations, vous avez une note supérieure requis." 
# define kStrNoTopScoreMessage @ "Essayez à nouveau d'obtenir un meilleur score." 
# define kStrYourNameHereMessage @ "Votre nom" 
# define kStrSave @ "Enregistrer" 
# define kStrDone @ "Go" 
# define kStrVarListScore @ "Top scores %i" 
# define kStrVarMaxQuestions @ "Questions %i" 
# define kStrOneMinute @ "1 minute" 
# define kStrVarMaxMinutes @ "%i minutes" 
# define kStrBlank @ ""


#endif

//Application Nib files
//#define kNibMenu @"MenuView"
//#define kNibActivity @"ActivityView"
#define kNibTellTime @"TellTimeView"
#define kNibSetTime @"SetTimeView"
#define kNibTimeBefore @"TellTimeView"
#define kNibTimeAfter @"TellTimeView"
#define kNibElapsedTime @"ElapsedTimeView"
//#define kNibHelp @"HelpView"
//#define kNibAbout @"HelpView"
//#define kNibSettings @"SettingsView"
//#define kNibTutorial @"HelpView"
#define kNibTopScores @"TopScoresDetailView"
#define kNibResult @"ResultView"
#define kNibTellAFriend @"TellAFriendView"

//Application iPad Nib files
//#define kiPadNibMenu @"MenuView"
//#define kiPadNibActivity @"ActivityView"
#define kiPadNibTellTime @"TellTimeView-iPad"
#define kiPadNibSetTime @"SetTimeView-iPad"
#define kiPadNibTimeBefore @"TellTimeView-iPad"
#define kiPadNibTimeAfter @"TellTimeView-iPad"
#define kiPadNibElapsedTime @"ElapsedTimeView-iPad"
//#define kiPadNibHelp @"HelpView"
//#define kiPadNibAbout @"HelpView"
//#define kiPadNibSettings @"SettingsView"
//#define kiPadNibTutorial @"HelpView"
#define kiPadNibTopScores @"TopScoresDetailView-iPad"
#define kiPadNibResult @"ResultView-iPad"
#define kiPadNibTellAFriend @"TellAFriendView-iPad"


//Application Images
#define kBGApp @"BGWhite.png"
#define kBGTellTime @"tell_time.png"
#define kBGSetTime @"set_time.png"
#define kBGTimeAfter @"time_after.png"
#define kBGTimeBefore @"time_before.png"
#define kBGElapsedTime @"elapsed_time.png"
#define kBGMixed @"mixed.png"
#define kImgRight @"Right.png"
#define kImgWrong @"Wrong.png"
#define kImgSettings @"Settings.png"
#define kImgHome @"Home.png"
//Application Files
//ClipArt Files
#define kClipArtFileRangeLow 1
#define kClipArtFileRangeHigh 100
#define kClipArtFileMask @"%iKCF72A.%@"
#define kClipArtFileType @"png"
//State
#define kFileAppState @"KTFState.plist"
#define kFileAppSettings @"KTFSettings.plist"
#define kFileBeltProgress @"KTFBeltProgress.plist"
#define kFileAdaptive @"KTFAdaptive.plist"
//Settings
//Var File Names for Scores - pass activity, type and level as variables
#define kFileVarScores @"KTFScoreForAct%iTyp%iLvl%i.plist"
//Settings Dictionary Keys
#define kSettingsKeyNumberOfQuestions @"NumberOfQuestions"
#define kSettingsKeyNumberOfMinutes @"NumberOfMinutes"
#define kSettingsKeyActivityLevel @"ActivityLevel"
#define kSettingsKeyGradeLevel @"GradeLevel"
#define kSettingsKeyPlaySound @"PlaySound"
//State Dictionary Keys

//Score Dictionary Keys
#define kPlayerName @"PlayerName"
#define kActivity @"Activity"
#define kActivityType @"ActivityType"
#define kActivityLevel @"ActivityLevel"
#define kQuestionsAsked @"QuestionsAsked"
#define kQuestionsAttempted @"QuestionsAttempted"
#define kRightAnswers @"RightAnswers"
#define kWrongAnswers @"WrongAnswers"
#define kPercentScore @"PercentScore"
#define kSecondsTaken @"SecondsTaken"
#define kScoreRank @"ScoreRank"
#define kScoreDateTime @"ScoreDateTime"
//For State use NSUserDefaults
//For Settings use settings bundle and NSUserDefaults

