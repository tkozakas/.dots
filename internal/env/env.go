package env

import (
	"os"
	"runtime"
	"strings"
)

func DetectDistro() string {
	if runtime.GOOS != "linux" {
		return runtime.GOOS
	}
	return parseOSRelease()
}

func parseOSRelease() string {
	data, err := os.ReadFile("/etc/os-release")
	if err != nil {
		return "unknown"
	}
	for _, line := range strings.Split(string(data), "\n") {
		if id, found := strings.CutPrefix(line, "ID="); found {
			return strings.Trim(id, "\"")
		}
	}
	return "unknown"
}
