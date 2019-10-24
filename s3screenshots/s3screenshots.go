// Lightweight binary wrapper to run:
// ./s3screenshots.sh
// with Full Disk Access
// To enable Security + Privacy overrides in Catalina
// See: 
// https://n8henrie.com/2018/11/how-to-give-full-disk-access-to-a-binary-in-macos-mojave/
package main

import (
    "log"
    "os"
    "os/exec"
    "path/filepath"
)

func main() {
    ex, err := os.Executable()
    if err != nil {
        log.Fatal(err)
    }
    dir := filepath.Dir(ex)
    script := filepath.Join(dir, "s3screenshots.sh")
    cmd := exec.Command(script)
    if err := cmd.Run(); err != nil {
        log.Fatal(err)
    }
}
