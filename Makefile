all: rebuild

preview: rebuild
	./hakyllbox preview

deploy: rebuild
	find _site/ -type d -exec chmod go+x {} \;
	chmod -R go+r _site
	rsync -avz --delete _site/* milkbox.net:milkbox

rebuild: hakyllbox
	./hakyllbox rebuild

hakyllbox: hakyllbox.hs
	ghc --make hakyllbox

clean:
	rm -f hakyllbox hakyllbox.hi hakyllbox.o

