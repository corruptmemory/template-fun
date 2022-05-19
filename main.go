package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"text/template"

	"github.com/jessevdk/go-flags"
	"github.com/mitchellh/go-homedir"
)

type Args struct {
	TemplateFile string `short:"f" long:"template-file" required:"true" description:"The file containing the template we want to use"`
}

// A quick and dirty template cache.  Not strictly needed, but could be useful in
// other contexts.
type templateCache map[string]*template.Template

func (t templateCache) processTemplateFile(file string, args any, target *bytes.Buffer) (err error) {
	bts, err := ioutil.ReadFile(file)
	if err != nil {
		return
	}

	var tmpl *template.Template
	if tmp, ok := t[file]; ok {
		tmpl = tmp
	} else {
		tmpl, err = template.New(file).Parse(string(bts))
		if err != nil {
			return
		}
		t[file] = tmpl
	}

	return tmpl.Execute(target, args)
}

type templateArgs struct {
	Name  string
	Email string
}

var examples = []templateArgs{
	{"Blono Fuzbar", "blono@fuzbar.tv"},
	{"Florb Nubu", "nubu.florb@gmail.com"},
	{"Guy McGuyFace", "guy@guyface.com"},
}

func main() {
	var args Args
	var parser = flags.NewParser(&args, flags.Default)
	var err error
	if _, err = parser.Parse(); err != nil {
		switch flagsErr := err.(type) {
		case *flags.Error:
			if flagsErr.Type == flags.ErrHelp {
				os.Exit(0)
			}
			log.Printf("Error with command line argument: %v", err)
			os.Exit(1)
		default:
			log.Printf("Error with command line argument: %v", err)
			os.Exit(1)
		}
	}

	args.TemplateFile, err = homedir.Expand(args.TemplateFile)
	if err != nil {
		panic(err)
	}
	cache := templateCache{}
	target := bytes.Buffer{}
	err = cache.processTemplateFile(args.TemplateFile, examples, &target)
	if err != nil {
		panic(err)
	}

	fmt.Print(target.String())
}
