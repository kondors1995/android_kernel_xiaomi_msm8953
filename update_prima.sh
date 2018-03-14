read -p "With Prima tag you whant to pull in : " tag
git pull prima $tag -X subtree=drivers/staging/prima --no-commit
git commit
