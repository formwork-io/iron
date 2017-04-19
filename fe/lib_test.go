package main_test

import (
	. "github.com/formwork-io/iron/fe"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("Internal", func() {

	BeforeEach(func() {
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
})
