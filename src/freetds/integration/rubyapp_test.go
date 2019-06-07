package integration_test

import (
	"path/filepath"

	"github.com/cloudfoundry/libbuildpack/cutlass"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("Ruby App Integration Test", func() {
	var app *cutlass.App
	AfterEach(func() {
		if app != nil {
			// app.Destroy()
		}
		app = nil
	})

	It("app deploys", func() {
		app = cutlass.New(filepath.Join(bpDir, "fixtures", "rubyapp"))
		app.Buildpacks = []string{"freetds_buildpack", "ruby_buildpack"}
		PushAppAndConfirm(app)
		Expect(app.GetBody("/")).To(ContainSubstring("Hi, I'm an app tiny_tds gem!"))
	})
})
