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

var ESC = ""

type ScriptStanza struct {
	name         string
	help         string
	extendedHelp string
	scriptPath   string
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
	reverse := fmt.Sprintf("%s[7m%s%s[0m", ESC, input, ESC)
	return reverse
}

func ansiNormal(input string) string {
	normal := fmt.Sprintf("%s[0m%s%s[0m", ESC, input, ESC)
	return normal
}

func isExtendedHelp(input string) bool {
	pattern := "^[1-9][0-9]*\\?$"
	match, e := regexp.Match(pattern, []byte(input))
	panicNonNil(e)
	return match
}

func isSubmenuArgcall(input string) bool {
	pattern := "^[1-9][0-9]*,[0-9,]*$"
	match, e := regexp.Match(pattern, []byte(input))
	panicNonNil(e)
	return match
}

func isItem(input string) bool {
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

func getPadding(scripts []string) int {
	paddingStr := fmt.Sprintf(" %d:")
	padding := len(paddingStr)
	return padding
}

func getMaxScriptName(stanzas []ScriptStanza) int {
	max := 0
	for _, stanza := range stanzas {
		if len(stanza.name) > max {
			max = len(stanza.name)
		}
	}
	return max
}

func readScriptStanza(scriptPath string) ScriptStanza {
	stanza := ScriptStanza{}
	stanza.name = path.Base(scriptPath)
	stanza.help = "This script has no help."
	stanza.extendedHelp = "This script has no extended help."
	stanza.scriptPath = scriptPath

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
			stanza.name = value
			continue
		}

		value, ok = getAssignedValue("IRON_SCRIPT_HELP", text)
		if ok {
			stanza.help = value
			continue
		}

		value, ok = getAssignedValue("IRON_SCRIPT_EXTENDED_HELP", text)
		if ok {
			stanza.extendedHelp = value
			continue
		}
	}

	if err = scanner.Err(); err != nil {
		panicNonNil(err)
	}

	return stanza
}
