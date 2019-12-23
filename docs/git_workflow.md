# Git Workflow

This project will use Vincent Driessen's [GitFlow](https://nvie.com/posts/a-successful-git-branching-model/) as the branching model for this project.
There are [good explainers](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) for  this  model online, but a quick summary is below. 

## Branches

The main branches used in this model are:

* `master`: This branch is what is currently deployed to production systems.
* `develop`: long-running branch containing changes that have been finished since last release
* `feature/<feature-name>`: series of short-lived branches where most development takes place
* `release/<release-id>`: short-lived branches which contain release candidates for higher-level testing and final preparation for release
* `hotfix/<hotfix-name>`: branches scion off `master` for immediate changes which should not go through the normal software development lifecycle.

## Common Development Workflow

Most work on this repository should follow this workflow:

1. Checkout `develop` and pull all changes from the GitHub repository.
2. `git checkout -b feature/<feature_name>` will start a new branch at the current point on the develop branch.
  Note that `<feature_name>` should be short and descriptive.
  The name does not need to be unique across time, but there cannot be two branches with the same name at the same time.
3. Make changes on the feature branch.
  This include creating new files, altering files, or removing files.
4. Submit a Pull Request on GitHub for the branch once feature development is complete.
  The Pull Request should attempt to merge the feature branch into `develop`.
5. Repository maintainers will complete the pull request workflow by performing a code review.
6. Once the code reviews are complete, and reviewers have approved changes, the PR's author (feature writer) will merge and delete the feature branch.

## Release Workflow

In preparing for a new release to production, the workflow is:

1. Identify a feature set which is ready for release.
2. Checkout a new `release/*` branch.
  This acts as a code freeze, and more importantly a feature freeze for the release.
3. Run any extended tests (such as system and integration tests, which may require human effort to run) targeting the `release` branch
4. If any changes are necessary, they can be made directly to the `release`  branch.
5. Once the release is approved, merge the `release` branch to `master` (again, through a PR).
  Do not delete the release branch.
6. If there were any changes on the `release` branch, merge the release branch back to `develop`.
  If there are conflicts between `develop` and `release`, the conflict _must_ be resolved by accepting the `release` version.
7. Once `develop` contains all changes that have been merged to `master`, the `release` branch can be deleted.

## Git-Flow Diagram:

This diagram was created by Vincent Driessen, the model's author, who licensed it under [`Creative Commons BY-SA`](https://creativecommons.org/licenses/by-sa/2.0/)

![git-flow diagram by Vincent Driessen](git-flow.png)

## Important Notes

* Feature branches should be short lived (on the order of a few days).
  If the feature cannot be completed in a few days, it's possible that the scope of the feature is too large, and needs to be segmented further.
* Hotfix branches work  very similar to release branches, but use `master` as their source, rather than `develop`.
  Like release branches, they must be merged back into `develop`, with the `hotfix` code taking priority in any conflicts.
