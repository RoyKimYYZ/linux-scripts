## Roy Kim git cheat sheet




# Add a local git repo to Github
# https://help.github.com/en/github/importing-your-projects-to-github/adding-an-existing-project-to-github-using-the-command-line
git init
git add .
git commit -m "my updates"
# go to github and create and get the new remote repository url
export github_repo_url=<URL>
git remote add origin remote repository $github_repo_url
git remote -v
# Verifies the new remote URL
git push origin master