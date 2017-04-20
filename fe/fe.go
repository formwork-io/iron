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

import "bufio"
import "fmt"
import "io"
import "io/ioutil"
import "os"
import "os/exec"
import "strconv"
import "strings"
import "github.com/chzyer/readline"
import "path/filepath"
import "regexp"
import "github.com/Sirupsen/logrus"
import prefixed "github.com/x-cray/logrus-prefixed-formatter"
import "text/tabwriter"

var ironHome = "IRON_HOME"
var ironVersion = 0.9
var ironFuncs = "iron-funcs"
var ironLogLevel = "IRON_LOG_LEVEL"

// keys from .fe file
var dotfeKeyIronScripts = "ironscripts"
var dotfeKeyIronVersion = "ironversion"
var dotfeKeyIronPrompt = "ironprompt"

var padding int
var maxScriptNameLen int
var lastChoice int

var log = logrus.New()

func header() {
	msg := "iron: the fe shell\n"
	msg += "https://github.com/formwork-io/iron\n"
	msg += "This is free software with ABSOLUTELY NO WARRANTY.\n"
	fmt.Print(msg)
}

func help() {
	header()
	msg := "--\n"
	msg += "WHAT IS THIS MADNESS?!\n"
	msg += "\n"
	msg += "Even in all its glory, your codebase will inevitably make you\n"
	msg += "want to gouge your eyes out. It will demand you recite arcane\n"
	msg += "incantations. You will need to coax it to finish a simple\n"
	msg += "task. It will be best friends with your teammates and\n"
	msg += "visciously stab you behind your back when you need it most.\n"
	msg += "It will be the bicycle you forget how to ride.\n"
	msg += "\n"
	msg += "The fe shell will let you keep your eyes. You can forget the\n"
	msg += "incantations. It will do the coaxing, be your friend, and\n"
	msg += "show you where the bicycle's pedals are lest you forget.\n"
	msg += ""
	msg += "Your scripts, if you have any, are listed below. Enter the\n"
	msg += "items you want and the fe shell will execute them in order.\n"
	msg += "Should anything fail, execution stops. The last menu item\n"
	msg += "chosen will be highlighted.\n"
	msg += "\n"
	msg += "See https://github.com/formwork-io/iron for more.\n"
	msg += "--\n"
	fmt.Print(msg)
}

func checkVersion(keyValues map[string]string) {
	version := keyValues[dotfeKeyIronVersion]
	if version == "" {
		return
	}
	fVersion, err := strconv.ParseFloat(version, 64)
	panicNonNil(err)
	if ironVersion < fVersion {
		need := fmt.Sprintf("%.2f", fVersion)
		have := fmt.Sprintf("%.2f", ironVersion)
		msg := fmt.Sprintf("Iron version %s required (have %s)\n", need, have)
		fmt.Fprintf(os.Stderr, msg)
		die()
	}
}

func getPrompt(keyValues map[string]string) string {
	dfltPrompt := "iron (?|#|#?|!)» "
	prompt := keyValues[dotfeKeyIronPrompt]
	if prompt == "" {
		return dfltPrompt
	}
	prompt = strings.Trim(prompt, "\"")
	return prompt
}

func getScriptLoc(keyValues map[string]string) string {
	scriptLoc := keyValues[dotfeKeyIronScripts]
	if fi, err := os.Stat(scriptLoc); err != nil || !fi.IsDir() {
		fmt.Fprintf(os.Stderr, "%s: not a directory\n", scriptLoc)
		log.Fatal(err)
		die()
	}
	return scriptLoc
}

func collectScripts(path string) []string {
	files, err := ioutil.ReadDir(path)
	if err != nil {
		fmt.Fprintf(os.Stderr, "No scripts found.\n")
		fmt.Fprintf(os.Stderr, "See https://github.com/formwork-io/iron.")
		log.Fatal(err)
		die()
	}

	scripts := []string{}
	for _, file := range files {
		log.WithFields(logrus.Fields{
			"path": path,
			"file": file.Name(),
		}).Debug("checking")

		// TODO relocate to internal
		match, err := regexp.Match("[0-9]+-.*\\.sh", []byte(file.Name()))
		panicNonNil(err)

		if match {
			log.WithFields(logrus.Fields{
				"path": path,
				"file": file.Name(),
			}).Debug("found a script")
			scripts = append(scripts, file.Name())
		}
	}
	return scripts
}

// Function constructor - constructs new function for listing given directory
func listFiles(path string) func(string) []string {
	return func(line string) []string {
		names := make([]string, 0)
		files, _ := ioutil.ReadDir(path)
		for _, f := range files {
			names = append(names, f.Name())
		}
		return names
	}
}

var completer = readline.NewPrefixCompleter(
	readline.PcItem("home"),
	readline.PcItem("funcs"),
	readline.PcItem("version"),
	readline.PcItem("exit"),
	readline.PcItem("help"),
)

func init() {
	lastChoice = -1
	if len(os.Args) == 2 {
		switch os.Args[1] {
		case "home":
			envIronHome := os.Getenv(ironHome)
			if envIronHome == "" {
				fmt.Fprintf(os.Stderr, "%s is not set\n", ironHome)
				die()
			}
			fmt.Printf("%s\n", envIronHome)
			os.Exit(0)
		case "funcs":
			envIronHome := os.Getenv(ironHome)
			if envIronHome == "" {
				fmt.Fprintf(os.Stderr, "%s is not set\n", ironHome)
				die()
			}
			funcs := filepath.Join(envIronHome, ironFuncs)
			fmt.Printf("%s\n", funcs)
			os.Exit(0)
		case "version":
			fmt.Printf("%f\n", ironVersion)
			os.Exit(0)
		case "help":
			help()
			os.Exit(0)
		}
	}

	logLevel := os.Getenv(ironLogLevel)
	if logLevel == "" {
		logLevel = "INFO"
	}
	formatter := new(prefixed.TextFormatter)
	formatter.TimestampFormat = "2006-01-02 15:04:05"
	log.Formatter = formatter

	level, err := logrus.ParseLevel(logLevel)
	if err != nil {
		fmt.Fprintf(os.Stderr, "unrecognized log level '%s'\n", logLevel)
		die()
	}
	log.Level = level
}

func findDotfe() string {
	curwd, err := os.Getwd()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to get working directory")
		die()
	}

	curPath := filepath.Join(curwd, ".fe")
	for {
		checkPath := filepath.Join(curPath, ".fe")

		log.WithFields(logrus.Fields{
			"path": checkPath,
		}).Debug("looking for '.fe'")

		if _, err := os.Stat(checkPath); err == nil {
			log.WithFields(logrus.Fields{
				"path": checkPath,
			}).Debug("found")
			return checkPath
		}
		nextPath := filepath.Join(curPath, "/..")
		if nextPath == curPath {
			return ""
		}
		curPath = nextPath
	}
}

func scriptHeader(stanza ScriptStanza) {
	header := fmt.Sprintf("(%s)\n\n", ansiReverse(stanza.name))
	log.Info(header)
}

func warnChoice(numScripts int) {
	msgfmt := "\nMenu items are from 1 to %d.\n\n"
	msg := fmt.Sprintf(msgfmt, numScripts)
	fmt.Fprintf(os.Stderr, msg)
}

func warnFailed(stanza ScriptStanza) {
	msgfmt := "(%s failed)"
	msg := fmt.Sprintf(msgfmt, stanza.name)
	log.Warn(msg)
}

func printShortMenu(stanzas []ScriptStanza) {
	fmt.Println()
	const padding = 1
	w := tabwriter.NewWriter(os.Stdout, 0, 0, padding, ' ', 0)
	num_stanzas := len(stanzas)
	padlen := 1
	for i := 0; i < num_stanzas; i++ {
		ipadlen := padlen - ((i + 1) / 10)
		stanza := stanzas[i]
		item := strconv.Itoa(i + 1)
		name := stanza.name
		if lastChoice == i+1 {
			item = ansiReverse(item)
			name = ansiReverse(name)
		} else {
			item = ansiNormal(item)
			name = ansiNormal(name)
		}
		item = strings.Repeat(" ", ipadlen) + item
		fmt.Fprintf(w, " %s:\t%s\n", item, name)
	}
	w.Flush()
	fmt.Println()
}

func printLongMenu(stanzas []ScriptStanza) {
	fmt.Println()
	const padding = 1
	w := tabwriter.NewWriter(os.Stdout, 0, 0, padding, ' ', 0)
	num_stanzas := len(stanzas)
	padlen := 1
	for i := 0; i < num_stanzas; i++ {
		ipadlen := padlen - ((i + 1) / 10)
		stanza := stanzas[i]
		item := strconv.Itoa(i + 1)
		name := stanza.name
		help := stanza.help
		if lastChoice == i+1 {
			item = ansiReverse(item)
			name = ansiReverse(name)
			help = ansiReverse(help)
		} else {
			item = ansiNormal(item)
			name = ansiNormal(name)
			help = ansiNormal(help)
		}
		item = strings.Repeat(" ", ipadlen) + item
		fmt.Fprintf(w, " %s:\t%s\t\t\t%s\n", item, name, help)
	}
	w.Flush()
	fmt.Println()
}

func main() {
	dotfePath := findDotfe()
	if dotfePath == "" {
		failMsg := "Not an Iron tree, no '.fe' (or in any parent directories)"
		fmt.Fprintln(os.Stderr, failMsg)
		die()
	}

	dotfeHndl, err := os.Open(dotfePath)
	panicNonNil(err)

	scanner := bufio.NewScanner(dotfeHndl)
	keyVals := make(map[string]string)
	for scanner.Scan() {
		scanline := scanner.Text()
		i := -1
		for j := 0; j < len(scanline); j++ {
			if scanline[j] == ':' {
				i = j
				break
			}
		}
		if i == -1 {
			fmt.Fprintf(os.Stderr, "%s syntax error: %s\n", dotfePath, scanline)
			die()
		}

		key := scanline[0:i]
		key = strings.TrimSpace(key)
		value := scanline[i+1:]
		value = strings.TrimSpace(value)
		keyVals[key] = value
	}
	dotfeHndl.Close()
	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "error reading .fe, ", err)
		die()
	}
	checkVersion(keyVals)
	prompt := getPrompt(keyVals)
	scriptLoc := getScriptLoc(keyVals)
	scripts := collectScripts(scriptLoc)
	if len(scripts) == 0 {
		fmt.Fprintf(os.Stderr, "No scripts found.\n")
		fmt.Fprintf(os.Stderr, "See https://github.com/formwork-io/iron.\n")
		die()
	}

	paddingStr := fmt.Sprintf("%d:", len(scripts))
	padding = len(paddingStr)

	stanzas := []ScriptStanza{}
	for _, script := range scripts {
		scriptPath := filepath.Join(scriptLoc, script)
		stanza := ReadScriptStanza(scriptPath)
		log.WithFields(logrus.Fields{
			"file": script,
			"name": stanza.name,
		}).Debug("got stanza")
		stanzas = append(stanzas, stanza)
	}
	maxScriptNameLen = GetMaxScriptName(stanzas)
	header()

	printShortMenu(stanzas)

	l, err := readline.NewEx(&readline.Config{
		Prompt: prompt, // "\033[31m»\033[0m ",
		// TODO replace with env var
		HistoryFile:       filepath.Join(scriptLoc, ".fe.hst"),
		AutoComplete:      completer,
		InterruptPrompt:   "^C",
		EOFPrompt:         "exit",
		HistorySearchFold: true,
	})
	if err != nil {
		panic(err)
	}
	defer l.Close()

	for {
		line, err := l.Readline()
		log.WithFields(logrus.Fields{
			"line": line,
		}).Debug("read line")
		if IsExtendedHelp(line) {
			log.Info("you want extended help!")
		}
		if err == readline.ErrInterrupt {
			if len(line) == 0 {
				break
			}
			continue
		} else if err == io.EOF {
			break
		}

		line = strings.TrimSpace(line)
		tokens := strings.Split(line, " ")
		for _, token := range tokens {

			if IsItem(token) {
				log.Debug("isItem")
				choice, err := strconv.Atoi(token)
				if err != nil || choice > len(stanzas) {
					warnChoice(len(stanzas))
					continue
				}
				lastChoice = choice
				stanza := stanzas[choice-1]
				scriptHeader(stanza)
				// an interface would be useful here
				cmdStr := fmt.Sprintf("%s", stanza.scriptPath)
				args := []string{}
				cmd := exec.Command(cmdStr, args...)

				cmdrdr, err := cmd.StdoutPipe()
				if err != nil {
					log.Error(err)
					die()
				}

				scanner := bufio.NewScanner(cmdrdr)
				go func() {
					for scanner.Scan() {
						fmt.Printf("%s | %s\n", stanza.name, scanner.Text())
					}
				}()

				err = cmd.Start()
				if err != nil {
					log.Error(err)
					die()
				}

				err = cmd.Wait()
				if err != nil {
					warnFailed(stanza)
				}
				continue
			}

			switch {
			case token == "bye":
				goto exit
			case token == "?":
				printLongMenu(stanzas)
			case token == "":
				printShortMenu(stanzas)
			default:
				log.Info(`[7myou said[0m:`, strconv.Quote(token))
			}

		}

	}
exit:
}
