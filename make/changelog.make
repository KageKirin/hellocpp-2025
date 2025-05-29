## changelog makerules

git-cliff:
	cargo install git-cliff   

### generate CHANGELOG.md from commits
CHANGELOG.md: git-cliff
	git cliff -o CHANGELOG.md

changelog: CHANGELOG.md
