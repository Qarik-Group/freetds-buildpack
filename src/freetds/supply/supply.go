package supply

import (
	"io"

	"github.com/cloudfoundry/libbuildpack"
)

type Stager interface {
	//TODO: See more options at https://github.com/cloudfoundry/libbuildpack/blob/master/stager.go
	BuildDir() string
	DepDir() string
	DepsIdx() string
	DepsDir() string
	WriteProfileD(string, string) error
}

type Manifest interface {
	//TODO: See more options at https://github.com/cloudfoundry/libbuildpack/blob/master/manifest.go
	AllDependencyVersions(string) []string
	DefaultVersion(string) (libbuildpack.Dependency, error)
}

type Installer interface {
	//TODO: See more options at https://github.com/cloudfoundry/libbuildpack/blob/master/installer.go
	InstallDependency(libbuildpack.Dependency, string) error
	InstallOnlyVersion(string, string) error
}

type Command interface {
	//TODO: See more options at https://github.com/cloudfoundry/libbuildpack/blob/master/command.go
	Execute(string, io.Writer, io.Writer, string, ...string) error
	Output(dir string, program string, args ...string) (string, error)
}

type Supplier struct {
	Manifest  Manifest
	Installer Installer
	Stager    Stager
	Command   Command
	Log       *libbuildpack.Logger
}

func (s *Supplier) Run() error {
	s.Log.BeginStep("Supplying FreeTDS")

	freetds, err := s.Manifest.DefaultVersion("freetds")
	if err != nil {
		return err
	}
	if err := s.Installer.InstallDependency(freetds, s.Stager.DepDir()); err != nil {
		return err
	}

	if err := s.Stager.WriteProfileD("finalize_freetds.sh", `#!/bin/bash
DEP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# https://www.freetds.org/faq.html#SYBASE
export SYBASE=$DEP_DIR

# https://github.com/rails-sqlserver/tiny_tds/blob/master/ext/tiny_tds/extconf.rb#L38
export FREETDS_DIR=$DEP_DIR

# https://github.com/rails-sqlserver/heroku-buildpack-freetds/blob/master/bin/compile#L90
export LD_LIBRARY_PATH="${DEP_DIR}/lib:${LD_LIBRARY_PATH:-/usr/local/lib}"
export LD_RUN_PATH="${DEP_DIR}/lib:${LD_RUN_PATH:-/usr/local/lib}"
export LIBRARY_PATH="${DEP_DIR}/lib:${LIBRARY_PATH:-/usr/local/lib}"
`); err != nil {
		s.Log.Error("Unable to write profile.d: %s", err.Error())
		return err
	}

	return nil
}
