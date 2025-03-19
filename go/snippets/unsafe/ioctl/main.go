package main

import (
	"fmt"
	"log"
	"os"
	"runtime"
	"unsafe"

	"golang.org/x/sys/unix"
)

func main() {
	if runtime.GOOS != "linux" {
		panic("Linux only.")
	}
	f, err := os.Open("/dev/null")
	if err != nil {
		log.Fatalf("Failed to open file: %v", err)
	}

	var cid uint32
	if err := ioctlPtr(int(f.Fd()), unix.IOCTL_VM_SOCKETS_GET_LOCAL_CID, uintptr(unsafe.Pointer(&cid))); err != nil {
		log.Fatalf("Failed to get local CID: %v", err)

		fmt.Printf("CID: %d\n", cid)
	}
}
// https://www.youtube.com/watch?v=SY-TTmdSrXs
// https://github.com/dominikh/go-tools/issues/1063
// correct: pointer arg is unsafe.Pointer.
func ioctlPtr(fd int, req int, arg uintptr) (err error) {
	_, _, e1 := unix.Syscall(unix.SYS_IOCTL, uintptr(fd), uintptr(req), uintptr(arg))
	if e1 != 0 {
		err = e1
	}
	return
}

// incorrect: pointer arg is uintptr.
func ioctl(fd int, req uint, arg uintptr) (err error) {
	_, _, e1 := unix.Syscall(unix.SYS_IOCTL, uintptr(fd), uintptr(req), uintptr(arg))
	if e1 != 0 {
		err = e1
	}
	return
}
