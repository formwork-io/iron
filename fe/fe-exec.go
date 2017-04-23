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

import (
	"bufio"
	"fmt"
	"os/exec"
)

func feExec(stanza ScriptStanza) {
	name := fmt.Sprintf("%s", stanza.ScriptPath)
	args := []string{}
	cmd := exec.Command(name, args...)
	outputChan := make(chan string)
	outpipe, err := cmd.StdoutPipe()
	if err != nil {
		log.Error(err)
		die()
	}
	errpipe, err := cmd.StderrPipe()
	if err != nil {
		log.Error(err)
		die()
	}

	outScanner := bufio.NewScanner(outpipe)
	go func() {
		for outScanner.Scan() {
			outputChan <- outScanner.Text()
		}
	}()

	errScanner := bufio.NewScanner(errpipe)
	go func() {
		for errScanner.Scan() {
			outputChan <- errScanner.Text()
		}
	}()

	go func() {
		for {
			output := <-outputChan
			fmt.Printf("%s | %s\n", stanza.Name, output)
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
}
