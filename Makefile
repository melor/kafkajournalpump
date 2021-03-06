short_ver = 1.0.0
long_ver = $(shell git describe --long 2>/dev/null || echo $(short_ver)-0-unknown-g`git describe --always`)

all: py-egg

PYTHON ?= python3
PYLINT_DIRS = kafkajournalpump/

test: pylint unittest

unittest:
	$(PYTHON) -m pytest -vv test/

pylint:
	$(PYTHON) -m pylint.lint --rcfile .pylintrc $(PYLINT_DIRS)

coverage:
	$(PYTHON) -m pytest $(PYTEST_ARG) --cov-report term-missing --cov kafkajournalpump test/

clean:
	$(RM) -r *.egg-info/ build/ dist/
	$(RM) ../kafkajournalpump_* test-*.xml

deb:
	cp debian/changelog.in debian/changelog
	dch -v $(long_ver) "Automatically built package"
	dpkg-buildpackage -A -uc -us

rpm:
	git archive --output=kafkajournalpump-rpm-src.tar.gz --prefix=kafkajournalpump/ HEAD
	rpmbuild -bb kafkajournalpump.spec \
		--define '_sourcedir $(shell pwd)' \
		--define 'major_version $(short_ver)' \
		--define 'minor_version $(subst -,.,$(subst $(short_ver)-,,$(long_ver)))'
	$(RM) kafkajournalpump-rpm-src.tar.gz

build-dep-fed:
	sudo yum -y install \
		python-kafka pytest python3-pytest pylint python3-pylint \
		systemd-python3

build-dep-deb:
	sudo apt-get install \
		build-essential devscripts dh-systemd \
		python-all python-setuptools python3-systemd python3-kafka

pep8:
	$(PYTHON) -m pep8 --ignore=E501,E123 $(PYLINT_DIRS)
