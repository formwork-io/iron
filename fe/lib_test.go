package main_test

import "os"
import "path"
import . "github.com/formwork-io/iron/fe"
import . "github.com/onsi/ginkgo"
import . "github.com/onsi/gomega"

var _ = Describe("Internal", func() {
	var examples string

	BeforeEach(func() {
		cwd, err := os.Getwd();
		if err != nil {
			panic(err)
		}
		examples = path.Join(cwd, "..", "examples")
	})

	Describe("Extended help", func() {
		Context("With a single digit", func() {
			It("should match", func() {
				Expect(IsExtendedHelp("1?")).To(BeTrue())
			})
		})
	})

	Describe("Submenu argcalls", func() {
		Context("With a single argument", func() {
			It("should match", func() {
				Expect(IsSubmenuArgcall("1,1")).To(BeTrue())
			})
		})
	})

	Describe("Items", func() {
		Context("With a single digit", func() {
			It("should match", func() {
				Expect(IsItem("1")).To(BeTrue())
			})
		})
		Context("With double digits", func() {
			It("should match", func() {
				Expect(IsItem("11")).To(BeTrue())
			})
		})
	})

	Describe("Get longest script name", func() {
		Context("With a single script", func() {
			It("finds the only script", func() {
				stanza := ScriptStanza{}
				stanza.Name = "foobar"
				stanzas := []ScriptStanza{stanza}
				Expect(GetMaxScriptName(stanzas)).To(Equal(6))
			})
		})
	})

	Describe("Reading scripts", func() {
		Context("Using examples", func() {
			It("parses example one", func() {
			})
		})
	})
})
