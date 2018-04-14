read -p "With Prima tag you whant to pull in : " tag
git pull https://source.codeaurora.org/quic/la/platform/vendor/qcom-opensource/wlan/prima $tag -X subtree=drivers/staging/prima --no-commit
git commit
