# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
if github.pr_title.include? "[WIP]"
  warn "PR is classed as Work in Progress"
end

# Warning to discourage big PRs
if git.lines_of_code > 500
    warn "Your PR has over 500 lines of code 😱 Try to break it up into separate PRs if possible 👍"
end

# Warning to encourage a PR description
if github.pr_body.length == 0
    warn "Please add a decription to your PR to make it easier to review 👌"
end

# Stop skipping some manual testing
if git.lines_of_code > 50 && !github.pr_title.include?("📱")
  warn "Needs testing on a Phone if change is non-trivial 📱"
end

# Encourage rebases instead of including merge commits
if git.commits.any? { |c| c.message =~ /^Merge branch 'master'/ }
  warn "Please rebase to get rid of the merge commits in this PR 🙏"
end

# If changes have been made in sources, encourage tests
if !git.modified_files.grep(/Sources/).empty? && git.modified_files.grep(/Tests/).empty?
    warn "Remember to write tests in case you have added a new API or fixed a bug. Feel free to ask for help if you need it 👍"
end

# Fail if release notes are not updated
changelog_updated = git.modified_files.include? "CHANGELOG.md"
fail "Any source code changes should have an entry in CHANGELOG.md." if !declared_trivial && !changelog_updated

jira.check(
  key: ["AL", "CM"],
  url: "https://applozic.atlassian.net/browse",
  fail_on_warning: false
)
