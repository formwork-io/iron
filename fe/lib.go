// iron: the fe shell
// https://github.com/formwork-io/iron
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
package main

import "os"
import "fmt"
import "bufio"
import "path"
import "regexp"
import "strings"

var esc = ""

// ScriptStanza contains the fields that make up an Iron script.
type ScriptStanza struct {
	Name         string
	Help         string
	ExtendedHelp string
	ScriptPath   string
}

func die() {
	os.Exit(1)
}

func panicNonNil(e error) {
	if e != nil {
		panic(e)
	}
}

func ansiReverse(input string) string {
	reverse := fmt.Sprintf("%s[7m%s%s[0m", esc, input, esc)
	return reverse
}

func ansiNormal(input string) string {
	normal := fmt.Sprintf("%s[0m%s%s[0m", esc, input, esc)
	return normal
}

// IsExtendedHelp recognizes extended help syntax.
func IsExtendedHelp(input string) bool {
	pattern := "^[1-9][0-9]*\\?$"
	match, e := regexp.Match(pattern, []byte(input))
	panicNonNil(e)
	return match
}

// IsSubmenuArgcall recognizes submenu argument syntax.
func IsSubmenuArgcall(input string) bool {
	pattern := "^[1-9][0-9]*,[0-9,]*$"
	match, e := regexp.Match(pattern, []byte(input))
	panicNonNil(e)
	return match
}

// IsItem recognizes item syntax.
func IsItem(input string) bool {
	pattern := "^[1-9][0-9]*$"
	match, e := regexp.Match(pattern, []byte(input))
	panicNonNil(e)
	return match
}

func getAssignedValue(key string, input string) (string, bool) {
	keyRE := fmt.Sprintf(`%s=\"(.)*\"`, key)
	re := regexp.MustCompile(keyRE)
	match := re.FindStringSubmatch(input)
	if len(match) > 0 {
		prefix := fmt.Sprintf("%s=", key)
		second := strings.Split(match[0], prefix)[1]
		trimmed := strings.Trim(second, "\"")
		return trimmed, true
	}
	return "", false
}

// GetMaxScriptName returns the maximum script name length.
func GetMaxScriptName(stanzas []ScriptStanza) int {
	max := 0
	for _, stanza := range stanzas {
		if len(stanza.Name) > max {
			max = len(stanza.Name)
		}
	}
	return max
}

// ReadScriptStanza parses a script for the parts of the Iron script stanza.
func ReadScriptStanza(scriptPath string) ScriptStanza {
	stanza := ScriptStanza{}
	stanza.Name = path.Base(scriptPath)
	stanza.Help = "This script has no help."
	stanza.ExtendedHelp = "This script has no extended help."
	stanza.ScriptPath = scriptPath

	f, err := os.Open(scriptPath)
	defer f.Close()
	panicNonNil(err)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		text := string(scanner.Text())

		var value string
		var ok bool

		value, ok = getAssignedValue("IRON_SCRIPT_NAME", text)
		if ok {
			stanza.Name = value
			continue
		}

		value, ok = getAssignedValue("IRON_SCRIPT_HELP", text)
		if ok {
			stanza.Help = value
			continue
		}

		value, ok = getAssignedValue("IRON_SCRIPT_EXTENDED_HELP", text)
		if ok {
			stanza.ExtendedHelp = value
			continue
		}
	}

	if err = scanner.Err(); err != nil {
		panicNonNil(err)
	}

	return stanza
}
