package main_test

import "os"
import "path"
import "path/filepath"
import . "github.com/formwork-io/iron/fe"
import . "github.com/onsi/ginkgo"
import . "github.com/onsi/gomega"

var _ = Describe("Lib", func() {
	var examples string

	BeforeEach(func() {
		cwd, err := os.Getwd()
		if err != nil {
			panic(err)
		}
		examples = path.Join(cwd, "..", "examples")
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
			It("parses name and help", func() {
				example := filepath.Join(examples, "01-test-success.sh")
				stanza := ReadScriptStanza(example)
				Expect(stanza.Name).To(Equal("test-success"))
				Expect(stanza.Help).To(Equal("Mimic a successful script."))
			})
		})
	})
})
