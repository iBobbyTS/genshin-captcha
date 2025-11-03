cd /Users/ibobby/Projects/genshin-captcha
npm run build
rm -rf .dist-publish && mkdir .dist-publish
cp -R dist/. .dist-publish/
cd .dist-publish
git init
git checkout -b dist
git add .
git commit -m "build: publish dist artifacts"
git remote add origin git@github.com:iBobbyTS/genshin-captcha.git
git push -f origin dist