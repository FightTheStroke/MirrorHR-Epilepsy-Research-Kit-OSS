#WARNING!!
If the iPhone language is changed, many things don't work because, for example, nodata notifications have a localized name

#Currently todo
1. Improve therapy management and medication reminders 
2. Develop AI based therapy tracking and reminders
3. Add siri for tracking symptoms

# Submitting checklist
1. localize all strings
2. strings whats new
3. new Store images and descriptions
4. submit store info (img, descriptions etc)
5. ChatGPT localization prompt languages: Italian, Brazilian, Spanish, Malay, French, Portuguese, Finnish, German, Chinese Simplified, Japanese, Corean, Hindi, Ukrainian, Russian, Thai, Dutch, Vietnamese, Egyptian, Arabic,  Indonesian, Hebrew, Greek.
Please give me code that can be easily pasted into Xcode

#Version 15 and 15.1 - Shipped on June 26 and then June 28
Remote Monitoring and streaming of bpms
backup and restore
bug fixing


#Version 14 - shipped on March 12 2024
1. overall UI simplification and consistency
2. fixed gradient in home page so that it does not cover the tab bar at the bottom
3. Donate with Apple Pay Button
4. fixed Medication Reminder Snooze
5. new Mood Tracker
6. update xls template & export
7. standard fonts vs custom fonts
8. better UI for timeline and diary
9. iphone low battery alert
10. improved therapy manager with option to change dates for current therapy
11. new chart for session stats at the end of a session
12. performances improvements

#Version 13 - Skipped!

#Version 12.1
1. some fix on the ResearchID Handling + server side done
2. simpler gradient that is not covering the TabBar
3. TODO: improve reminders management
4. TODO: improve therapy management
5. TODO: check all fields handling and typing.

#Version 12

1. refactored to leverage OSLog Logger
2. WatchOS requirement back to watchOS8
3. included a ResearchID into consensus views and telemetry header (for dr. Tarek use case in egypt)
4. improved arabic localization
5. ask rating in onboarding if updating the app
6. Fixed data entry in textfields
7. Standardized Logs to OSLog Loggers
8. refactored watch communications
9. standardized timestamp to gregorian calendar
10. sending the right sound name based on type of symptom logged
11 *New Home Tab*

# Version 11
1. remote push notifications for every symptom, alarm etc.
2. refactoring of the profilegeneric settings in order to leverage AppStorage
3. refactored and improved the onboarding

# Version 10.6
1. as for feedback from Naomi, making all permissions optional--> *WARNING NOT SURE THAT'S THE RIGHT THING TO TO!!*

# Version 10.5 
1. Improved Diary and Insights View with more powerful search and easy to use experience
2. moved medication reminders to the main view, but still is not perfectly handling notifications
3. fixed backup/restore function that did not work

# Version 10.4 (requires WatchOS 8+)
1. new Permissions Manager Package (it includes localizations)
2. Replaced all JMAlert and remove PermissionsSwiftUI package
3. Better permission handling during onboarding
4. It checks permissions when start

# Version 10.2 submitted on Dec 18
migliorata gestione permessi
nuovi colori
nuovi screenshoots nell'apple app store
localizzazione in arabo

# Version 10 submitted on Oct 7
OnGoing
* migliorare gestione FastLog come da suggerimenti di Stefania di Roma
* okkio ai permessi nel caso di streaming e togliere tutte le funzioni che non servono
* gestione giorno/notte con parametri diversi
* TEST TEST TEST

Done
* a lot of work on handling errors and simplify user experience
* localized all strings
* Migliorare i messaggi nelle notifiche (soprattutto NODATA)
* rimossi errori legati alla comunicazione con watch in caso di solo client streaming
* aggiunta AURA
* refactored the full settings view
* removed CommunityTab
* Share dei videoLog + fixed it
* replaced sheetview con navigationview in Settings
* CloudAPI (including send bpm as zip file)
* rimpiazzate sheetview ove possibile con navigationLink
* improved data quality from the watch, including avoid duplicated values


# TODO SHORT TERM
* migliorare ads funnel
* find a way to bulk insert data (as for Stefania's ask)
* change date of a symptom in the detailed view
* Contextual Helps leveraging GoToWeb function -> make a proper contextual help engine


# MID TERM EVOLUTIONS
* checklist when handling seizures
* bulk insert dei sintomi come chiesto da Stefania
* Migliorare i messaggi di errore
* CloudKit sync with coredata (it might require a migration...)
* Riorganizzare onboarding come suggerito da Stefania (What's New View done in 9.70)
* info sull'epilessia con documenti, video, checklist per la scuola o con altri caregivers etc.
* Aggiungere storico e curve di crescita con altezza, peso e circonferenza cranica (correlato ai farmaci) - da averne proprio lo storico con grafici.
* Nuovi grafici - aspettare iOS 16

# Done in 9.70
* Backup/Restore (including a way to communicate the need to stay in the app)
* fixed a bug in About section when clicking on telemetry
* fixed an bug that was not sending anymore the right telemetry symptoms
* hopefully fixed the bad handling of freshbpm when it's stopped
* fresh new What's New View at beginning
* new messages for when handling No Data
* new option for receiving notifications when realtime monitor ends (or not)
* BPM Full Day Chart on Date header in Diary View


# Done in 9.60.25
* Fix bug stop from iphone - hopefully done in commit 6fb0b294
* Sync UIScreen.setBrightness - done in commit b3eece17
* Incluso Mal di denti come sintomo - "sympt_toothache"
* rebootWatchCard in onboarding when updating the app
* Moved localized strings into a single folder to clean up the folder structure (thx to Poz1)
* prepared "FastLane screenShoots" for auto making of screenshoots (thx to Poz1)
* Check Ti piace MirrorHR se funzia in commit 4e604334
* max bpm per allarme from 170 to 180 as asked by Pietro
* Fire a notification when there is a communication error & refactor error handling, notifications etc
* refactoring dei pickers per scegliere Int come bpm, sounds etc in keysettings e settings views. 
* Fix bug evidenziato da Stefania
* mandare mail post crisi (+ email dottore)
* il campo lunghezza crisi come chiesto da Stefania
* export of last month only just after a seizure or sent email after a seizure with core informations only
* Refactoring

# Done in 10
* Fixed: capire xè si inchioppa quando non vede watch e manda notifiche a palla
* Fixed: migliorare info sull'apple watch (es connettivity)
* localizzare
* Remote streaming architecture in LAN - big feature
* CloudAPI con SantoMaggio - new telemetryEngine - big feature


