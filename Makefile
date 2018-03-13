dev:
	gulp dev

prod:
	gulp prod

release:
	rm -r dist
	python setup.py sdist
	python setup.py bdist_wheel
