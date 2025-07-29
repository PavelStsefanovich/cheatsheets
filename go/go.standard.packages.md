# Go Standard Library Packages

## Core Language & Runtime

### `fmt`
**Purpose**: Formatted I/O operations (printing, scanning, string formatting)
```go
fmt.Println("Hello, World!")
fmt.Printf("Name: %s, Age: %d\n", name, age)
fmt.Sprintf("Formatted string: %v", value)
```

### `errors`
**Purpose**: Error creation and manipulation
```go
err := errors.New("something went wrong")
fmt.Errorf("failed to process %s: %w", filename, err)
```

### `context`
**Purpose**: Request-scoped values, cancellation, and timeouts
```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
```

### `reflect`
**Purpose**: Runtime reflection - examining types and values at runtime
```go
t := reflect.TypeOf(myStruct)
v := reflect.ValueOf(myStruct)
```

### `unsafe`
**Purpose**: Low-level memory operations (use with extreme caution)
```go
// Converting between pointer types (rarely used)
```

## Data Types & Collections

### `strings`
**Purpose**: String manipulation and operations
```go
strings.Contains("hello world", "world")
strings.Split("a,b,c", ",")
strings.ToUpper("hello")
strings.TrimSpace("  hello  ")
```

### `strconv`
**Purpose**: String conversions to/from other data types
```go
i, err := strconv.Atoi("123")
s := strconv.Itoa(123)
f, err := strconv.ParseFloat("3.14", 64)
```

### `bytes`
**Purpose**: Byte slice manipulation (similar to strings but for []byte)
```go
bytes.Contains(data, []byte("pattern"))
bytes.Split(data, []byte(","))
buf := bytes.NewBuffer([]byte{})
```

### `sort`
**Purpose**: Sorting slices and user-defined collections
```go
sort.Strings([]string{"c", "a", "b"})
sort.Ints([]int{3, 1, 2})
sort.Slice(people, func(i, j int) bool { return people[i].Age < people[j].Age })
```

### `container/list`
**Purpose**: Doubly linked list implementation
```go
l := list.New()
l.PushBack("first")
l.PushFront("second")
```

### `container/heap`
**Purpose**: Heap data structure operations
```go
// Used with custom types implementing heap.Interface
```

## File System & I/O

### `os`
**Purpose**: Operating system interface (files, environment, processes)
```go
file, err := os.Open("file.txt")
os.Getenv("HOME")
os.Args // command line arguments
os.Exit(1)
```

### `io`
**Purpose**: Basic I/O primitives and interfaces
```go
io.Copy(dst, src)
io.ReadAll(reader)
// Defines Reader, Writer, Closer interfaces
```

### `io/fs`
**Purpose**: File system interfaces (Go 1.16+)
```go
fs.WalkDir(fsys, ".", func(path string, d fs.DirEntry, err error) error {
    // Process each file/directory
})
```

### `bufio`
**Purpose**: Buffered I/O operations
```go
scanner := bufio.NewScanner(file)
for scanner.Scan() {
    line := scanner.Text()
}
```

### `path/filepath`
**Purpose**: File path manipulation (OS-specific)
```go
filepath.Join("home", "user", "documents")
filepath.Abs("./file.txt")
filepath.Walk(".", walkFunc)
```

### `path`
**Purpose**: URL path manipulation (forward slashes only)
```go
path.Join("api", "v1", "users")
path.Base("/path/to/file.txt") // returns "file.txt"
```

### `embed`
**Purpose**: Embedding files into Go binaries (Go 1.16+)
```go
//go:embed static/*
var staticFiles embed.FS
```

## Networking & HTTP

### `net/http`
**Purpose**: HTTP client and server implementations
```go
// Server
http.HandleFunc("/", handler)
http.ListenAndServe(":8080", nil)

// Client
resp, err := http.Get("https://api.example.com")
```

### `net`
**Purpose**: Network I/O, including TCP, UDP, Unix sockets
```go
conn, err := net.Dial("tcp", "localhost:8080")
listener, err := net.Listen("tcp", ":8080")
```

### `net/url`
**Purpose**: URL parsing and manipulation
```go
u, err := url.Parse("https://example.com/path?query=value")
values := url.Values{}
values.Set("key", "value")
```

## Data Encoding & Formats

### `encoding/json`
**Purpose**: JSON encoding and decoding
```go
json.Marshal(data)
json.Unmarshal(jsonData, &struct)
json.NewEncoder(writer).Encode(data)
```

### `encoding/xml`
**Purpose**: XML encoding and decoding
```go
xml.Marshal(data)
xml.Unmarshal(xmlData, &struct)
```

### `encoding/csv`
**Purpose**: CSV file reading and writing
```go
reader := csv.NewReader(file)
records, err := reader.ReadAll()
```

### `encoding/base64`
**Purpose**: Base64 encoding and decoding
```go
encoded := base64.StdEncoding.EncodeToString(data)
decoded, err := base64.StdEncoding.DecodeString(encoded)
```

### `encoding/hex`
**Purpose**: Hexadecimal encoding and decoding
```go
hex.EncodeToString([]byte("hello"))
hex.DecodeString("68656c6c6f")
```

## Time & Date

### `time`
**Purpose**: Time and date operations, parsing, formatting
```go
now := time.Now()
time.Sleep(5 * time.Second)
t, err := time.Parse("2006-01-02", "2023-12-25")
formatted := now.Format("2006-01-02 15:04:05")
```

## Concurrency

### `sync`
**Purpose**: Synchronization primitives (mutexes, wait groups)
```go
var mu sync.Mutex
var wg sync.WaitGroup
var once sync.Once
```

### `sync/atomic`
**Purpose**: Atomic memory operations
```go
atomic.AddInt64(&counter, 1)
atomic.LoadInt64(&value)
```

## Text Processing

### `text/template`
**Purpose**: Text template processing
```go
tmpl := template.Must(template.New("test").Parse("Hello, {{.Name}}!"))
tmpl.Execute(os.Stdout, data)
```

### `html/template`
**Purpose**: HTML template processing with auto-escaping
```go
tmpl := template.Must(template.ParseFiles("template.html"))
tmpl.Execute(writer, data)
```

### `regexp`
**Purpose**: Regular expressions
```go
matched, err := regexp.MatchString(`\d+`, "123")
re := regexp.MustCompile(`(\d+)`)
matches := re.FindAllString(text, -1)
```

## Testing

### `testing`
**Purpose**: Unit testing and benchmarking framework
```go
func TestSomething(t *testing.T) {
    if result != expected {
        t.Errorf("got %v, want %v", result, expected)
    }
}
```

### `testing/iotest`
**Purpose**: Utilities for testing I/O operations
```go
// Provides readers/writers that introduce errors for testing
```

## Math & Algorithms

### `math`
**Purpose**: Mathematical functions and constants
```go
math.Sqrt(16)
math.Max(10, 20)
math.Pi
math.Ceil(3.2)
```

### `math/rand`
**Purpose**: Random number generation
```go
rand.Intn(100)
rand.Float64()
rand.Seed(time.Now().UnixNano())
```

### `crypto/rand`
**Purpose**: Cryptographically secure random number generation
```go
bytes := make([]byte, 32)
rand.Read(bytes)
```

## Cryptography & Security

### `crypto/md5`
**Purpose**: MD5 hash algorithm (avoid for security-critical applications)
```go
hash := md5.Sum(data)
```

### `crypto/sha256`
**Purpose**: SHA-256 hash algorithm
```go
hash := sha256.Sum256(data)
```

### `crypto/tls`
**Purpose**: TLS/SSL implementation
```go
config := &tls.Config{InsecureSkipVerify: true}
conn, err := tls.Dial("tcp", "example.com:443", config)
```

## Command Line & Flags

### `flag`
**Purpose**: Command-line flag parsing
```go
var name = flag.String("name", "World", "a name to say hello to")
flag.Parse()
fmt.Printf("Hello, %s!\n", *name)
```

### `os/exec`
**Purpose**: Running external commands
```go
cmd := exec.Command("ls", "-la")
output, err := cmd.Output()
```

## Compression

### `compress/gzip`
**Purpose**: Gzip compression and decompression
```go
writer := gzip.NewWriter(file)
reader, err := gzip.NewReader(file)
```

### `compress/zip`
**Purpose**: ZIP archive reading and writing
```go
reader, err := zip.OpenReader("archive.zip")
```

## Database

### `database/sql`
**Purpose**: Generic interface for SQL databases
```go
db, err := sql.Open("mysql", "user:password@/dbname")
rows, err := db.Query("SELECT * FROM users")
```

### `database/sql/driver`
**Purpose**: Database driver interface (for driver implementers)
```go
// Used by database driver authors
```

## Logging

### `log`
**Purpose**: Simple logging package
```go
log.Println("This is a log message")
log.Fatal("This will exit the program")
log.SetPrefix("APP: ")
```

### `log/slog` (Go 1.21+)
**Purpose**: Structured logging
```go
slog.Info("User logged in", "user_id", 123, "ip", "192.168.1.1")
```

## Image Processing

### `image`
**Purpose**: Basic image types and interfaces
```go
img, format, err := image.Decode(file)
bounds := img.Bounds()
```

### `image/jpeg`, `image/png`, `image/gif`
**Purpose**: Specific image format encoding/decoding
```go
jpeg.Decode(file)
png.Encode(writer, img)
```

## Runtime & Debug

### `runtime`
**Purpose**: Go runtime system interaction
```go
runtime.GOMAXPROCS(4)
runtime.GC()
runtime.NumGoroutine()
```

### `runtime/debug`
**Purpose**: Debugging and runtime diagnostics
```go
debug.PrintStack()
debug.SetGCPercent(50)
```

## Archive & Tar

### `archive/tar`
**Purpose**: TAR archive format reading and writing
```go
reader := tar.NewReader(file)
writer := tar.NewWriter(file)
```

### `archive/zip`
**Purpose**: ZIP archive operations
```go
reader, err := zip.OpenReader("file.zip")
```

## Most Commonly Used Packages for CLI Development

For building command-line tools, you'll most frequently use:

1. **`os`** - File operations, environment variables, command-line args
2. **`flag`** - Command-line flag parsing
3. **`fmt`** - Output formatting and printing
4. **`strings`** - String manipulation
5. **`io`** - Reading/writing data
6. **`bufio`** - Buffered file reading
7. **`path/filepath`** - File path operations
8. **`encoding/json`** - JSON processing
9. **`regexp`** - Pattern matching
10. **`strconv`** - String conversions
11. **`time`** - Date/time operations
12. **`log`** - Simple logging
13. **`os/exec`** - Running external commands
14. **`context`** - Handling cancellation and timeouts

These packages form the foundation of most Go applications and provide robust, well-tested functionality for common programming tasks.
