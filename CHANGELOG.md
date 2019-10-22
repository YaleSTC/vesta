# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
### Added
* Add SID to users ([#669](https://gitlab.com/yale-sdmp/vesta/issues/669)).
* Add new scope associations to room so that only non-archived data can be retrieved ([#960](https://gitlab.com/yale-sdmp/vesta/issues/960)).
* Add foreign key contraints to schema and dependency handling for all associations ([#406](https://gitlab.com/yale-sdmp/vesta/issues/406)).
* Add blank template suite import file ([#706](https://gitlab.com/yale-sdmp/vesta/issues/706)).
* Add 'About Us' page ([#591](https://gitlab.com/yale-sdmp/vesta/issues/591)).
* Update feature specs to use navigation ([#399] (https://gitlab.com/yale-sdmp/vesta/issues/399)).

### Changed
* Sort groups in results and suite selection tables by lottery number ([#968](https://gitlab.com/yale-sdmp/vesta/issues/968)).
* Create method for lock_and_email ([#945](https://gitlab.com/yale-sdmp/vesta/issues/945)).
* Hide the login link in the nav when a user is not in a specific college ([#909](https://gitlab.com/yale-sdmp/vesta/issues/909)).
* Hide the draws dropdown if there are no draws ([#884](https://gitlab.com/yale-sdmp/vesta/issues/884)).
* Change login and logout to log in and log out when they are used as verbs ([#955](https://gitlab.com/yale-sdmp/vesta/issues/955)).
* Add timeoutable to users and expiration date to cookies ([#963](https://gitlab.com/yale-sdmp/vesta/issues/963)).
* Make oversubscription handling notify unlucky groups ([#964](https://gitlab.com/yale-sdmp/vesta/issues/964)).
* Create query object for users by intent and add a model method to Draw ([#870](https://gitlab.com/yale-sdmp/vesta/issues/870)).
* Create GroupWithoutSuites query object for GroupsReport ([627](https://gitlab.com/yale-sdmp/vesta/issues/627)).
* Remove User non-essential display methods ([#852](https://gitlab.com/yale-sdmp/vesta/issues/852)).
* Change DrawPolicy#group_actions to remove policy check against draft stage of the draw ([#722](https://gitlab.com/yale-sdmp/vesta/issues/722)).
* Hide the Terms of Service link when user is not logged in ([#978](https://gitlab.com/yale-sdmp/vesta/issues/978)).
* Allow export of all group members' emails (no longer restricted to group leaders only) ([888](https://gitlab.com/yale-sdmp/vesta/issues/888))
* Remove date restrictions on the intent_reminder? and lock_reminder? policies for draws ([711](https://gitlab.com/yale-sdmp/vesta/issues/711))


### Fixed
* Fix AdminDashboard membership creation failure ([#971](https://gitlab.com/yale-sdmp/vesta/merge_requests/1018)).
* Fix NoMethodError thrown by AdminDashboard Draw#show ([#965](https://gitlab.com/yale-sdmp/vesta/issues/965)).
* Remove deprecated User name attribute ([#962](https://gitlab.com/yale-sdmp/vesta/issues/962)).
* Refactor code to remove unused CSS styles ([#738](https://gitlab.com/yale-sdmp/vesta/issues/738)).
* Add links to Vesta in the intent and group reminder emails. ([#931](https://gitlab.com/yale-sdmp/vesta/issues/931)).
* Fix NoMethodError caused when importing suites with no csv file chosen ([#975](https://gitlab.com/yale-sdmp/vesta/issues/975)).
* Fix broken Code Quality CI job ([#908](https://gitlab.com/yale-sdmp/vesta/issues/908)).
* Fix building names not appearing for students in suites but without rooms ([#882](https://gitlab.com/yale-sdmp/vesta/issues/882))

## v2.3.3 - 2019-04-01
### Fixed
* Update RoomAssignmentForm to only query for active draw memberships ([#956](https://gitlab.com/yale-sdmp/vesta/issues/956)).
* Fix race condition allowing for orphaned lottery assignments ([#958](https://gitlab.com/yale-sdmp/vesta/issues/958)).
* Allow leaders to be selected from the checklist of users and the dropdown in drawless group creation ([#957](https://gitlab.com/yale-sdmp/vesta/issues/957)).

## v2.3.2 - 2019-03-26
### Fixed
* Prevent users from being able to enter room assignments twice ([#950](https://gitlab.com/yale-sdmp/vesta/issues/950)).
* Fix DrawlessGroupsController not correctly redirecting if the group has a draw ([#920](https://gitlab.com/yale-sdmp/vesta/issues/920)).

## v2.3.1 - 2019-03-25
### Fixed
* Fix typos in e-mails ([#953](https://gitlab.com/yale-sdmp/vesta/issues/953)).

## v2.3.0 - 2019-03-20
### Added
* Add DrawDuplicator service object to copy suite associations in draws without user data ([#668](https://gitlab.com/yale-sdmp/vesta/issues/668)).
* Allow editing of room numbers and room type on Suites#show page ([#547](https://gitlab.com/yale-sdmp/vesta/issues/547)).
* Add emails to csvs ([#889](https://gitlab.com/yale-sdmp/vesta/issues/889)).
* Add college name to the attribute types and show page attributes ([#932](https://gitlab.com/yale-sdmp/vesta/issues/932)).

### Fixed
* Update eager loading ([#876](https://gitlab.com/yale-sdmp/vesta/issues/876)).
* Fix inactive draw_memberships from interfering with special group formation ([#941](https://gitlab.com/yale-sdmp/vesta/issues/941)).
* Make widths of lottery forms consistent across multiple sizes ([#890](https://gitlab.com/yale-sdmp/vesta/issues/890)).
* Fix archived draws appearing to be assigned to suites ([#902](https://gitlab.com/yale-sdmp/vesta/issues/902)).
* Fix issue with duplicate available suites appearing ([#952](https://gitlab.com/yale-sdmp/vesta/issues/952)).
* Fix Suite.available scope to properly return only available suites ([#948](https://gitlab.com/yale-sdmp/vesta/issues/948)).
* Fix issue with passing dates to queued e-mails ([#943](https://gitlab.com/yale-sdmp/vesta/issues/943)).
* Fix selectable validation for suites to check for archived status in draws ([#951](https://gitlab.com/yale-sdmp/vesta/issues/951)).

### Changed
* Rename group size locking to restrict size locking ([811](https://gitlab.com/yale-sdmp/vesta/issues/811)).
* Association of draw to draw_membership has been changed to have matching "active" states. ([#928](https://gitlab.com/yale-sdmp/vesta/issues/928)).
* Remove code from drawStudentsUpdate to manually add students by username ([900](https://gitlab.com/yale-sdmp/vesta/issues/900)).
* Remove stale records of DrawMemberships ([933](https://gitlab.com/yale-sdmp/vesta/issues/933)).
* Change viewing and indexing policies for Rooms and Buildings to restrict to admin and up ([937](https://gitlab.com/yale-sdmp/vesta/issues/937)).
* Fix issue with queued emails changing based on draw updates ([935](https://gitlab.com/yale-sdmp/vesta/issues/935)).

## v2.2.1 - 2019-02-20
### Added
* Add custom Administrate field EnumField ([#891](https://gitlab.com/yale-sdmp/vesta/issues/891)).

### Fixed
* Fix the display of archived group links on the student dashboard ([#907](https://gitlab.com/yale-sdmp/vesta/issues/907)).
* Fix the drawless suites query ([#901](https://gitlab.com/yale-sdmp/vesta/issues/901)).

## v2.2.0 - 2019-02-12
### Added
* Add the ability to assign lottery numbers by size ([#848](https://gitlab.com/yale-sdmp/vesta/issues/848)).
* Add admins to all bulk user emails ([#887](https://gitlab.com/yale-sdmp/vesta/issues/887)).
* Add ability to reset terms of service acceptance ([#904](https://gitlab.com/yale-sdmp/vesta/issues/904)).

### Fixed
* Scope the results view and export to only return active students in the current college ([#885](https://gitlab.com/yale-sdmp/vesta/issues/885)).
* Ensure that suites are properly treated as available after archiving old groups ([#895](https://gitlab.com/yale-sdmp/vesta/issues/895)).
* Fix the results by student view to only show active draw information ([#897](https://gitlab.com/yale-sdmp/vesta/issues/897)).
* Ensure that students not already in draws can be individually added to other draws ([#898](https://gitlab.com/yale-sdmp/vesta/issues/898)).
* Add a uniqueness constraint to draw_suites that prevents duplicate entries ([#899](https://gitlab.com/yale-sdmp/vesta/issues/899)).

## v2.1.0 - 2019-02-04
### Notes for upgrade:
### When upgrading to 2.1.0 or later you _must_ initially upgrade to 2.0.0 and run `rake db:migrate`
### to ensure that data is migrated correctly.

### Added
* Add DrawMembership join model to allow users to have many-to-many relationship with draws ([#813](https://gitlab.com/yale-sdmp/vesta/issues/813)), ([#814](https://gitlab.com/yale-sdmp/vesta/issues/814)), ([#815](https://gitlab.com/yale-sdmp/vesta/issues/815)), ([#816](https://gitlab.com/yale-sdmp/vesta/issues/816)), ([#817](https://gitlab.com/yale-sdmp/vesta/issues/817)).
* Add ability to archive draws ([#869](https://gitlab.com/yale-sdmp/vesta/issues/869)).
* Add ability to archive active special groups ([#871](https://gitlab.com/yale-sdmp/vesta/issues/871)).
* Add the ability to archive all draws, special groups, and draw memberships all at once ([#865]( https://gitlab.com/yale-sdmp/vesta/issues/865)).

### Changed
* Modify front end for user experience updates ([#875](https://gitlab.com/yale-sdmp/vesta/issues/875)).
* Make draws bypass the intent phase if intent is locked ([#881](https://gitlab.com/yale-sdmp/vesta/issues/881)).
* Update Terms of Service text ([#903](https://gitlab.com/yale-sdmp/vesta/issues/903)).

### Fixed
* Update version number appropriately for the footer ([#878](https://gitlab.com/yale-sdmp/vesta/issues/878))

## v2.0.0 - 2019-01-16
### Notes for upgrade:
### When upgrading from v1.0.8 or earlier to 2.0.0 or later you _must_ initially upgrade to v1.0.9.
### Once upgraded to v1.0.9 you must run `rails db:create_shared_schema` to create the new schema
### that will contain all users and colleges post v2.0. After that you can upgrade as normal.

### Changed
* Make sure that intent locking in a draw blocks all intent-related emails ([#542](https://gitlab.com/yale-sdmp/vesta/issues/542))
* Refactor model validations and callbacks ([#202](https://gitlab.com/yale-sdmp/vesta/issues/202)), ([#828](https://gitlab.com/yale-sdmp/vesta/issues/828)), ([#829](https://gitlab.com/yale-sdmp/vesta/issues/829)), ([#830](https://gitlab.com/yale-sdmp/vesta/issues/830)), ([#831](https://gitlab.com/yale-sdmp/vesta/issues/831)), ([#832](https://gitlab.com/yale-sdmp/vesta/issues/832)), ([#833](https://gitlab.com/yale-sdmp/vesta/issues/833)), ([#834](https://gitlab.com/yale-sdmp/vesta/issues/834)), ([#835](https://gitlab.com/yale-sdmp/vesta/issues/835)).
* Make SuiteImport more restful with create controller action ([#423](https://gitlab.com/yale-sdmp/vesta/issues/423)).
* Make DrawStudentAssignmentForm use a robust query attribute that dynamically chooses username or NetID ([#772](https://gitlab.com/yale-sdmp/vesta/issues/772)).
* Add room generation functionality to SuiteGenerator ([#119](https://gitlab.com/yale-sdmp/vesta/issues/119)).
* Updated multitenancy to allow for all users of all tenants to be held in one canonical table in one shared schema [#802](https://gitlab.com/yale-sdmp/vesta/issues/802), [#803](https://gitlab.com/yale-sdmp/vesta/issues/803), [#804](https://gitlab.com/yale-sdmp/vesta/issues/804), [#805](https://gitlab.com/yale-sdmp/vesta/issues/805), [#806](https://gitlab.com/yale-sdmp/vesta/issues/806).
* Bulk user add instructions are now auth-dependent and no longer Yale specific ([#157](https://gitlab.com/yale-sdmp/vesta/issues/157)).
* Rename DrawReport#ungrouped_students to #ungrouped_students_by_intent ([#793](https://gitlab.com/yale-sdmp/vesta/issues/793)).
* Remove login workarounds from suite_selection_spec.rb ([#122](https://gitlab.com/yale-sdmp/vesta/issues/122)).
* Make sure all relevant links are behind authorization checks ([#553](https://gitlab.com/yale-sdmp/vesta/issues/553)).
* Fix Results#export eager loading ([#794](https://gitlab.com/yale-sdmp/vesta/issues/794)).
* Refactor policies with User#leader_of? ([#417](https://gitlab.com/yale-sdmp/vesta/issues/417)).
* Include building as a column in results views([#572](https://gitlab.com/yale-sdmp/vesta/issues/572)).
* Restrict intent actions to draft or pre-lottery phases of a draw ([740](https://gitlab.com/yale-sdmp/vesta/issues/740)).
* Upgrade FactoryGirl to FactoryBot ([676](https://gitlab.com/yale-sdmp/vesta/issues/676)).
* Move emails from model callbacks to service objects ([777](https://gitlab.com/yale-sdmp/vesta/issues/777)).
* Memberships unlock when a user leaves a group ([#872](https://gitlab.com/yale-sdmp/vesta/issues/872)).

### Added
* Add flash to warn of oversubscription in suite update ([#670](https://gitlab.com/yale-sdmp/vesta/issues/670)).
* Add dependent: :destroy for group in draw model ([#687](https://gitlab.com/yale-sdmp/vesta/issues/687)).
* Remove db hit from DrawSuitesUpdate#find_suites_to_remove ([#206](https://gitlab.com/yale-sdmp/vesta/issues/206)).
* Prevent admins from assigning special groups to suites that are in a draw in suite selection([#548](https://gitlab.com/yale-sdmp/vesta/issues/548)).
* Add LotteryAssignments and Clips to the superuser dashboard ([#768](https://gitlab.com/yale-sdmp/vesta/issues/768)).
* Add separate RoomAssignments model ([#690](https://gitlab.com/yale-sdmp/vesta/issues/690)).
* Add error messages to throw_abort ([#792](https://gitlab.com/yale-sdmp/vesta/issues/792)).
* Add a new DrawStudentsController to handle actions that involve student enrollment in draws ([#620](https://gitlab.com/yale-sdmp/vesta/issues/620)).
* Add group#cleanup! ([#808](https://gitlab.com/yale-sdmp/vesta/issues/808)).
* Add button to lock all groups on the admin view for a draw ([#786](https://gitlab.com/yale-sdmp/vesta/issues/786))
* Allow users to edit their passwords ([#131](https://gitlab.com/yale-sdmp/vesta/issues/131)).
* Create separate memberships controller for invitations / requests / other membership actions ([#333](https://yale.githost.io/sdmp/rails/vesta/issues/333)).
* Add ARIA labels and update forms([#747](https://gitlab.com/yale-sdmp/vesta/issues/747)]).
* Add intent-selection phase to draws and change pre-lottery phase to group-formation phase ([#818](https://gitlab.com/yale-sdmp/vesta/issues/818)).
* Add graceful error handling when record is not found ([#328](https://gitlab.com/yale-sdmp/vesta/issues/328)).
* Adding ability to limit clipping to groups of the same size in a given draw ([#844](https://gitlab.com/yale-sdmp/vesta/issues/844)).
* Allow admins to send groups to the "back of the line" during suite selection
([#771](https://gitlab.com/yale-sdmp/vesta/issues/771))
* Add SuiteAssignment join model to allow groups to have many-to-many relationship with suites ([#861](https://gitlab.com/yale-sdmp/vesta/issues/861)).

### Fixed
* Intent and locking deadline cannot be in the past ([#600](https://gitlab.com/yale-sdmp/vesta/issues/600)).
* Loading users no longer fails because of missing class year ([#601](https://gitlab.com/yale-sdmp/vesta/issues/601)).
* Remediate all tables for accessibility ([#745](https://gitlab.com/yale-sdmp/vesta/issues/745)).
* Unmerging suites no longer fails if the merged suite had the same name as one of its constituent suites ([#790]( https://gitlab.com/yale-sdmp/vesta/issues/790)).
* Fix updating groups through the superuser dashboard ([#775](https://gitlab.com/yale-sdmp/vesta/issues/775)).
* Bulk user enrollment no longer fails silently when users exist and now flashes an error message ([#156](https://gitlab.com/yale-sdmp/vesta/issues/156)).
* Admins can add users to groups even if users have pending invitations ([#773](https://gitlab.com/yale-sdmp/vesta/issues/773)).
* Unhidden table caption is now hidden ([#800](https://gitlab.com/yale-sdmp/vesta/issues/800)).
* Fix NoMethodError in creating new user in admin dashboard ([#810](https://gitlab.com/yale-sdmp/vesta/issues/810)).
* Properly handle a failed result in IDRProfileQuerier ([#689](https://gitlab.com/yale-sdmp/vesta/issues/689)).
* Fix sorting students by draw in Administrate ([#700](https://gitlab.com/yale-sdmp/vesta/issues/700)).
* Fix simple_form buttons not being focused ([821](https://gitlab.com/yale-sdmp/vesta/issues/812)).
* Fix duplicate flash message in application([#603](https://gitlab.com/yale-sdmp/vesta/issues/603)).
* Clarify error message when trying to add a student that doesn't exist to a draw ([#490](https://gitlab.com/yale-sdmp/vesta/issues/490)).
* Fix search error for user in admin dashboard([#846](https://gitlab.com/yale-sdmp/vesta/issues/846))

## v1.0.9 - 2018-08-30
### Added
* Add a rake task that creates a shared schema in preparation for the multitenancy update ([#806](https://gitlab.com/yale-sdmp/vesta/issues/806)).

## v1.0.8 - 2018-04-09
### Fixed
* Groups of locked sizes can now finalize ([#788](https://gitlab.com/yale-sdmp/vesta/issues/788)).

### Added
* Add more attributes to the results export ([#789](https://gitlab.com/yale-sdmp/vesta/issues/789)).
* Fix room assignment nullification when groups disband ([#784](https://gitlab.com/yale-sdmp/vesta/issues/784)).

## v1.0.7 - 2018-04-05
### Changed
* Add restrictions to make sure lottery assignments don't exist without groups ([#780](https://gitlab.com/yale-sdmp/vesta/issues/780)).

### Fixed
* Make converting groups to special groups more robust ([#783](https://gitlab.com/yale-sdmp/vesta/issues/783), [#781](https://gitlab.com/yale-sdmp/vesta/issues/781)).
* Fix Draw#oversubscribed? to check only available suites  [#779](https://gitlab.com/yale-sdmp/vesta/issues/779)).

### Added
* Add suite assignment to group export for draw ([#785](https://gitlab.com/yale-sdmp/vesta/issues/785)).

## v1.0.6 - 2018-04-02
### Added
* Add an overview for suite selection ([#723](https://gitlab.com/yale-sdmp/vesta/issues/723)).
* Add accessibility link to footer ([#772](https://gitlab.com/yale-sdmp/vesta/issues/772)).

## v1.0.5 - 2018-03-30
### Added
* Add notification e-mails for group invitations and requests ([#767](https://gitlab.com/yale-sdmp/vesta/issues/767)).

### Changed
* Make UngroupedStudentsQuery sort by last name ([#756](https://gitlab.com/yale-sdmp/vesta/issues/756)).
* Add TOS Acceptance to administrate dashboard ([#760](https://gitlab.com/yale-sdmp/vesta/issues/760)).
* Rename home link in nav ([#753](https://gitlab.com/yale-sdmp/vesta/issues/753)).
* Prevent deadline information from showing after pre-lottery ([#765](https://gitlab.com/yale-sdmp/vesta/issues/765)).
* Allow admins to disband groups during selection regardless of suite availability ([#769](https://gitlab.com/yale-sdmp/vesta/issues/769)).

### Fixed
* Fix performance issues in certain views ([#764](https://gitlab.com/yale-sdmp/vesta/issues/764)).

## v1.0.4 - 2018-03-27
### Added
* Add suites table to draws#show view ([#751](https://gitlab.com/yale-sdmp/vesta/issues/751)).
* Add clips table to draws#show view ([#759](https://gitlab.com/yale-sdmp/vesta/issues/759)).

## v1.0.3 - 2018-03-26
### Changed
* Allow admins to change intent in draft draws ([#754](https://gitlab.com/yale-sdmp/vesta/issues/754)).
* Prevent suite selection e-mails from going out if admin selection is being used ([#752](https://gitlab.com/yale-sdmp/vesta/issues/752)).

### Fixed
* Fix various accessibility issues ([#742](https://gitlab.com/yale-sdmp/vesta/issues/742), [#748](https://gitlab.com/yale-sdmp/vesta/issues/748)).
* Fix broken locking deadline locking policy ([#755](https://gitlab.com/yale-sdmp/vesta/issues/755)).

### Added
* Add confirmation to Activate Draw button ([#757](https://gitlab.com/yale-sdmp/vesta/issues/757)).
* Add Edit Students and Edit Suites buttons to the draw edit page ([#758](https://gitlab.com/yale-sdmp/vesta/issues/758)).

## v1.0.2 - 2018-03-26
### Fixed
* Fix incorrect references to College.first ([#741](https://gitlab.com/yale-sdmp/vesta/issues/741)).

## v1.0.1 - 2018-03-26
### Fixed
* Fix colleges#index not sorting alphabetically ([#741](https://gitlab.com/yale-sdmp/vesta/issues/741)).
* Fix accessibility issues with group creation and flash messages ([#744](https://gitlab.com/yale-sdmp/vesta/issues/744)).
* Fix heading hierarchies for better accessibility ([#743](https://gitlab.com/yale-sdmp/vesta/issues/743)).
* Fix broken e-mail due to deserialization error ([#749](https://gitlab.com/yale-sdmp/vesta/issues/749)).

## v1.0.0 - 2018-03-19
### Changed
* Make seed script create draws in three stages ([#530](https://gitlab.com/yale-sdmp/vesta/issues/530)
* Re-enable student suite selection ([#502](https://github.com/YaleSTC/vesta/issues/502)).
* Update to Ruby v2.4.1 ([#607](https://gitlab.com/yale-sdmp/vesta/issues/607)).
* Fix intent reminder emails so they only go to students who haven't set intent ([#588](https://gitlab.com/yale-sdmp/vesta/merge_requests/599)).
* Rename :object key to :redirect_object in service object return hash ([#176](https://gitlab.com/yale-sdmp/vesta/issues/176)).
* Modularize service object class methods ([#140](https://gitlab.com/yale-sdmp/vesta/issues/140)).
* Update to Rails 5.1 ([#608](https://gitlab.com/yale-sdmp/vesta/issues/608)).
* Make suites and rooms nested resources ([#431](https://gitlab.com/yale-sdmp/vesta/issues/431)).
* DrawsController#lock_all_sizes should use Updater ([#610](https://gitlab.com/yale-sdmp/vesta/issues/610))
* Remove students and suites from Draw strong params ([#282](https://gitlab.com/yale-sdmp/vesta/issues/282)).
* Extract Group#remove_members ([#280](https://gitlab.com/yale-sdmp/vesta/isses/280))
* Refactor Draw reporting ([#619](https://gitlab.com/yale-sdmp/vesta/isses/619))
* Fix error handling in service objects ([#241](https://gitlab.com/yale-sdmp/vesta/issues/241))
* Make error handling more consistent across service objects ([#602](https://gitlab.com/yale-sdmp/vesta/issues/602))
* Clean up ReminderQueuer ([#625](https://gitlab.com/yale-sdmp/vesta/issues/625))
* Rename the 'full' status to 'closed' ([#240](https://gitlab.com/yale-sdmp/vesta/issues/240))
* Move DrawSuite actions to DrawSuites controller ([#199](https://gitlab.com/yale-sdmp/vesta/issues/199))
* Switch :try with :& ([#217](https://gitlab.com/yale-sdmp/vesta/issues/217))
* Create query objects for queries in Draw Report ([#626](https://gitlab.com/yale-sdmp/vesta/issues/626))
* Make Building > Suite > Room nesting shallow ([#618](https://gitlab.com/yale-sdmp/vesta/isses/618))
* Modify user update functionality so admins cannot demote themselves ([#529](https://gitlab.com/yale-sdmp/vesta/issues/529))
* Rename Group Finalizing to Group Locking ([#352](https://gitlab.com/yale-sdmp/vesta/issues/352))
* Add new traits to group factories to allow for more flexible testing ([#665](https://gitlab.com/yale-sdmp/vesta/issues/665)).
* Allow new students to be added to group when increasing group size ([#556](https://gitlab.com/yale-sdmp/vesta/issues/556))
* Refactor suite import to properly set room names and flag medical suites ([#658](https://gitlab.com/yale-sdmp/vesta/issues/658)).
* Add an "Allow Clipping" option for draws ([#716](https://gitlab.com/yale-sdmp/vesta/issues/716)).
* Add automatic room assignment for students assigned to singles ([#703](https://gitlab.com/yale-sdmp/vesta/issues/703)).
* Prevent changes to suites and students in a draw after the pre-lottery phase ([#704](https://gitlab.com/yale-sdmp/vesta/issues/704)).
* Force HTTPS in production environments.
* Automatically drop database schemas when destroying a college ([#730](https://gitlab.com/yale-sdmp/vesta/issues/730)).
* Remove duplication of email text and html files ([#420](https:/gitlab.com/yale-sdmp/vesta/issues/420)).

### Fixed
* Prevent non-admins from seeing the suite import form ([#576](https://gitlab.com/yale-sdmp/vesta/issues/576)).
* Pass overrides properly in seed script generators ([#616](https://gitlab.com/yale-sdmp/vesta/issues/616)).
* Fixed definition inconsistencies in policy files ([#216](https://gitlab.com/yale-sdmp/vesta/issues/216)).
* Fix n+3 query in suites summary partial ([#567](https://gitlab.com/yale-sdmp/vesta/issues/567)).
* Fix intermittent test failure in lottery number removal ([#532](https://gitlab.com/yale-sdmp/vesta/issues/532)).
* Fix seed script to persist lottery numbers ([#637](https://gitlab.com/yale-sdmp/vesta/issues/637)).
* Fix typo in confirmation message ([#630](https://gitlab.com/yale-sdmp/vesta/issues/630)).
* Fix broken draw suites migration([#638](https://gitlab.com/yale-sdmp/vesta/issues/638)).
* Fix user counts on pre-lottery draw dashboards ([#628](https://gitlab.com/yale-sdmp/vesta/issues/628)).
* Fix broken pathing in suite removal form ([#632](https://gitlab.com/yale-sdmp/vesta/issues/632)).
* Fix disband button not showing during suite selection ([#640](https://gitlab.com/yale-sdmp/vesta/issues/640)).
* Fix draw results not showing after finishing suite selection ([#631](https://gitlab.com/yale-sdmp/vesta/issues/631)).
* Correct housing sidebar counts ([#629](https://gitlab.com/yale-sdmp/vesta/issues/629)).
* Fix issues with seed script ([#657](https://gitlab.com/yale-sdmp/vesta/issues/657)).
* Update security vulnerability in YARD ([#682](https://gitlab.com/yale-sdmp/vesta/issues/682)).
* Fix searching for users in admin dashboard ([#699](https://gitlab.com/yale-sdmp/vesta/issues/699)).
* Fix config file to properly eager load files ([#708](https://gitlab.com/yale-sdmp/vesta/issues/708)).
* Fix 404 issue with font files ([#720](https://gitlab.com/yale-sdmp/vesta/issues/720)).
* Fix redirect on DrawSuite update failure ([#710](https://gitlab.com/yale-sdmp/vesta/issues/710)).
* Fix handling of students without accounts logging in via CAS ([#717](https://gitlab.com/yale-sdmp/vesta/issues/717)).
* Fix race condition in the testing suite ([#732](https://gitlab.com/yale-sdmp/vesta/issues/732)).
* Fix CORS issue with assets requested from root host ([#734](https://gitlab.com/yale-sdmp/vesta/issues/734)).
* Humanize intents for display on intent form and user page ([#735](https://gitlab.com/yale-sdmp/vesta/issues/735)).
* Prevent student intent from being modified if they are in a group ([#718](https://gitlab.com/yale-sdmp/vesta/issues/718)).
* Fix user import when not using CAS ([#736](https://gitlab.com/yale-sdmp/vesta/issues/736)).
* Fix 'Begin Locking Process for Group' button policy ([#728](https://gitlab.com/yale-sdmp/vesta/issues/728)).
* Fix minor front-end issues ([#707](https://gitlab.com/yale-sdmp/vesta/issues/707)).
* Make adding users more flexible for non-CAS uses ([#737](https://gitlab.com/yale-sdmp/vesta/issues/737)).
* Fix mislabeled accordions on draw#show ([#739](https://gitlab.com/yale-sdmp/vesta/issues/739)).

### Added
* Add suite unmerging ([#257](https://gitlab.com/yale-sdmp/vesta/issues/257)).
* Add superuser role ([#642](https://gitlab.com/yale-sdmp/vesta/issues/642)).
* Add superuser dashboard ([#604](https://gitlab.com/yale-sdmp/vesta/issues/604)).
* Allow admins to automatically resolve oversubscription ([#195](https://gitlab.com/yale-sdmp/vesta/issues/195), [#697](https://gitlab.com/yale-sdmp/vesta/issues/697), [#698](https://gitlab.com/yale-sdmp/vesta/issues/698)).
* Add multi-tenancy ([#641](https://gitlab.com/yale-sdmp/vesta/issues/641)).
* Add securely random automatic lottery number generation ([#361](https://gitlab.com/yale-sdmp/vesta/issues/361), [#698](https://gitlab.com/yale-sdmp/vesta/issues/698)).
* Add an e-mail to all on-campus students notifying them of their lottery number ([#702](https://gitlab.com/yale-sdmp/vesta/issues/702)).
* Add a terms of service page for new users ([#719](https://gitlab.com/yale-sdmp/vesta/issues/719)).
* Add Rake tasks for college setup and user management ([#726](https://gitlab.com/yale-sdmp/vesta/issues/726)).
* Allow admins to specify student roles when importing ([#731](https://gitlab.com/yale-sdmp/vesta/issues/731)).
* Add CSV export functionality for intents and lottery numbers ([#701](https://gitlab.com/yale-sdmp/vesta/issues/701)).
* Add CSV import functionality for intents ([#729](https://gitlab.com/yale-sdmp/vesta/issues/729)).
* Add version number to footer ([#510](https://gitlab.com/yale-sdmp/vesta/issues/510)).

## v0.1.8 - 2017-04-19
### Fixed
* Fix broken group confirmation e-mails ([#555](https://github.com/YaleSTC/vesta/issues/555)).
* Fix 404 page title ([#579](https://github.com/YaleSTC/vesta/issues/579)).
* Permit students to view the draw page during suite selection ([#584](https://github.com/YaleSTC/vesta/issues/584)).
* Allow admins to do group CRUD regardless of draw state ([#585](https://github.com/YaleSTC/vesta/issues/585)).
* Humanize the intent report content ([#597](https://github.com/YaleSTC/vesta/issues/597)).

### Added
* Add intent counts to the intent report ([#539](https://github.com/YaleSTC/vesta/issues/539)).

## v0.1.7 - 2017-04-05
### Added
* Add building names to suite labels where appropriate ([#561](https://github.com/YaleSTC/vesta/issues/561)).

## v0.1.6 - 2017-04-05
### Fixed
* Allow duplicate room numbers in different suites ([#261](https://github.com/YaleSTC/vesta/issues/261)).
* Allow the draw page to be viewed during the lottery ([#544](https://github.com/YaleSTC/vesta/issues/544)).
* Permit reps to view the draw page during suite selection ([#545](https://github.com/YaleSTC/vesta/issues/545)).
* Allow reps to view the group report in all draw phases. ([#546](https://github.com/YaleSTC/vesta/issues/546)).

### Added
* Add HTTP --> HTTPS redirect for all traffic when deploying to AWS Elastic
  Beanstalk ([#535](https://github.com/YaleSTC/vesta/issues/535)).

### Changed
* Prevent group disbanding during suite selection when there are still suites
  left ([#563](https://github.com/YaleSTC/vesta/issues/563)).

## v0.1.5 - 2017-03-30
### Fixed
* Fix nav bar for special group members ([#474](https://github.com/YaleSTC/vesta/issues/474)).
* Ensure that all group reports display correctly ([#487](https://github.com/YaleSTC/vesta/issues/487)).
* Ensure that NextGroupsQuery ignores groups with no lottery number set ([#504](https://github.com/YaleSTC/vesta/issues/504)).

### Added
* Create secondary draws to handle ungrouped students after suite selection ([#162](https://github.com/YaleSTC/vesta/issues/162)).

### Changed
* Allow reps to handle oversubscription and lock sizes ([#496](https://github.com/YaleSTC/vesta/issues/496)).
* Allow students to easily navigate to the draw index ([#519](https://github.com/YaleSTC/vesta/issues/519)).
* Ensure that unlocking a group removes the finalizing status ([#527](https://github.com/YaleSTC/vesta/issues/527)).
* Improve display of ungrouped and undeclared users on draw page ([#531](https://github.com/YaleSTC/vesta/issues/531)).

## v0.1.4 - 2017-03-29
### Fixed
* Allow group lottery number removal ([#486](https://github.com/YaleSTC/vesta/issues/486)).
* Remove accidental ERB closing tags from joined group e-mail ([#520](https://github.com/YaleSTC/vesta/issues/520)).

### Added
* Add printable group report for draws ([#488](https://github.com/YaleSTC/vesta/issues/488)).
* Add size lock buttons to oversubscription page ([#497](https://github.com/YaleSTC/vesta/issues/497)).

### Changed
* Remove user action buttons from the draw student summary ([#489](https://github.com/YaleSTC/vesta/issues/489)).
* Allow reps to view the draw intent report ([#495](https://github.com/YaleSTC/vesta/issues/495)).

### Removed
* Remove validation on the number of beds being greater or equal to the number
  of students from draw activation ([#494](https://github.com/YaleSTC/vesta/issues/494)).

## v0.1.3 - 2017-03-29
### Fixed
* Add several tweaks / improvements to the student experience ([#207](https://github.com/YaleSTC/vesta/issues/207)).
* Destroy pending memberships on invitation and request acceptance ([#513](https://github.com/YaleSTC/vesta/issues/513)).

## v0.1.2 - 2017-03-29
### Changed
* Downgrade Ruby to v2.3.1 ([#506](https://github.com/YaleSTC/vesta/issues/506)).

## v0.1.1 - 2017-03-29
### Fixed
* Prevent students from performing suite selection ([#501](https://github.com/YaleSTC/vesta/issues/501)).

### Changed
* Downgrade Ruby to v2.3.3 ([#493](https://github.com/YaleSTC/vesta/issues/493)).

## v0.1.0 - 2017-03-28
*Initial Release*
