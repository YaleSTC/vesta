# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
### Changed
* Make seed script create draws in three stages ([#530](https://yale.githost.io/sdmp/rails/vesta/issues/530)
* Re-enable student suite selection ([#502](https://github.com/YaleSTC/vesta/issues/502)).
* Update to Ruby v2.4.1 ([#607](https://yale.githost.io/sdmp/rails/vesta/issues/607)).
* Fix intent reminder emails so they only go to students who haven't set intent ([#588](https://yale.githost.io/sdmp/rails/vesta/merge_requests/599)).
* Rename :object key to :redirect_object in service object return hash ([#176](https://yale.githost.io/sdmp/rails/vesta/issues/176)).
* Modularize service object class methods ([#140](https://yale.githost.io/sdmp/rails/vesta/issues/140)).
* Update to Rails 5.1 ([#608](https://yale.githost.io/sdmp/rails/vesta/issues/608)).
* Make suites and rooms nested resources ([#431](https://yale.githost.io/sdmp/rails/vesta/issues/431)).
* DrawsController#lock_all_sizes should use Updater ([#610](https://yale.githost.io/sdmp/rails/vesta/issues/610))
* Remove students and suites from Draw strong params ([#282](https://yale.githost.io/sdmp/rails/vesta/issues/282)).
* Extract Group#remove_members ([#280](https://yale.githost.io/sdmp/rails/vesta/isses/280))
* Refactor Draw reporting ([#619](https://yale.githost.io/sdmp/rails/vesta/isses/619))
* Fix error handling in service objects ([#241](https://yale.githost.io/sdmp/rails/vesta/issues/241))
* Make error handling more consistent across service objects ([#602](https://yale.githost.io/sdmp/rails/vesta/issues/602))
* Clean up ReminderQueuer ([#625](https://yale.githost.io/sdmp/rails/vesta/issues/625))
* Rename the 'full' status to 'closed' ([#240](https://yale.githost.io/sdmp/rails/vesta/issues/240))
* Configure JS ([#636](https://yale.githost.io/sdmp/rails/vesta/issues/636))
* Move DrawSuite actions to DrawSuites controller ([#199](https://yale.githost.io/sdmp/rails/vesta/issues/199))
* Switch :try with :& ([#217](https://yale.githost.io/sdmp/rails/vesta/issues/217))
* Create query objects for queries in Draw Report ([#626](https://yale.githost.io/sdmp/rails/vesta/issues/626))
* Make Building > Suite > Room nesting shallow ([#618](https://yale.githost.io/sdmp/rails/vesta/isses/618))
* Modify user update functionality so admins cannot demote themselves ([#529](https://yale.githost.io/sdmp/rails/vesta/issues/529))
* Rename Group Finalizing to Group Locking ([#352](https://yale.githost.io/sdmp/rails/vesta/issues/352))
* Add new traits to group factories to allow for more flexible testing ([#665](https://yale.githost.io/sdmp/rails/vesta/issues/665)).

### Fixed
* Prevent non-admins from seeing the suite import form ([#576](https://yale.githost.io/sdmp/rails/vesta/issues/576)).
* Pass overrides properly in seed script generators ([#616](https://yale.githost.io/sdmp/rails/vesta/issues/616)).
* Fixed definition inconsistencies in policy files ([#216](https://yale.githost.io/sdmp/rails/vesta/issues/216)).
* Fix n+3 query in suites summary partial ([#567](https://yale.githost.io/sdmp/rails/vesta/issues/567)).
* Fix intermittent test failure in lottery number removal ([#532](https://yale.githost.io/sdmp/rails/vesta/issues/532)).
* Fix seed script to persist lottery numbers ([#637](https://yale.githost.io/sdmp/rails/vesta/issues/637)).
* Fix typo in confirmation message ([#630](https://yale.githost.io/sdmp/rails/vesta/issues/630)).
* Fix broken draw suites migration([#638](https://yale.githost.io/sdmp/rails/vesta/issues/638)).
* Fix user counts on pre-lottery draw dashboards ([#628](https://yale.githost.io/sdmp/rails/vesta/issues/628)).
* Fix broken pathing in suite removal form ([#632](https://yale.githost.io/sdmp/rails/vesta/issues/632)).
* Fix disband button not showing during suite selection ([#640](https://yale.githost.io/sdmp/rails/vesta/issues/640)).
* Fix draw results not showing after finishing suite selection ([#631](https://yale.githost.io/sdmp/rails/vesta/issues/631)).
* Correct housing sidebar counts ([#629](https://yale.githost.io/sdmp/rails/vesta/issues/629)).
* Fix issues with seed script ([#657](https://yale.githost.io/sdmp/rails/vesta/issues/657)).
* Update security vulnerability in YARD ([#682](https://yale.githost.io/sdmp/rails/vesta/issues/682)).

### Added
* Add suite unmerging ([#257](https://yale.githost.io/sdmp/rails/vesta/issues/257)).
* Install React.js and Webpacker ([#623](https://yale.githost.io/sdmp/rails/vesta/issues/623)).
* Add superuser role ([#642](https://yale.githost.io/sdmp/rails/vesta/issues/642)).
* Add superuser dashboard ([#604](https://yale.githost.io/sdmp/rails/vesta/issues/604)).

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
