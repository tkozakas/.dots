package env

import (
	"os"
	"runtime"
	"slices"
	"strings"
)

var (
	archDistros   = []string{"arch", "manjaro", "endeavouros"}
	debianDistros = []string{"debian", "ubuntu", "linuxmint"}
	fedoraDistros = []string{"fedora", "rhel", "centos"}
)

func DetectDistro() string {
	if runtime.GOOS != "linux" {
		return runtime.GOOS
	}
	return parseOSRelease()
}

func IsArch() bool {
	return slices.Contains(archDistros, DetectDistro())
}

func IsDebian() bool {
	return slices.Contains(debianDistros, DetectDistro())
}

func IsFedora() bool {
	return slices.Contains(fedoraDistros, DetectDistro())
}

func parseOSRelease() string {
	data, err := os.ReadFile("/etc/os-release")
	if err != nil {
		return "unknown"
	}
	return extractDistroID(string(data))
}

func extractDistroID(content string) string {
	for line := range strings.SplitSeq(content, "\n") {
		if id, found := strings.CutPrefix(line, "ID="); found {
			return strings.Trim(id, "\"")
		}
	}
	return "unknown"
}
