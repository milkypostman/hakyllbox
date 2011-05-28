all: preview

preview: rebuild
	./hakyllbox preview

deploy: rebuild
	rsync -avz --delete _site/ milkbox.net:webapps/hakyllbox

rebuild: hakyllbox
	./hakyllbox rebuild

hakyllbox: hakyllbox.hs
	ghc --make hakyllbox
