# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
### Added
* Add an overview for suite selection ([#723](https://gitlab.com/yale-sdmp/vesta/issues/723)).

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
