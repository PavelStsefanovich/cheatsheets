# Go Course for Python Developers: Building CLI Tools

## Course Overview
This course will teach you Go fundamentals through the lens of building command-line tools, leveraging your Python knowledge to accelerate learning.

## Module 1: Go Basics & Setup

### Installation & Environment
```bash
# Install Go from https://golang.org/dl/
go version  # Check installation

# Initialize a new module
go mod init mycli
```

### Go vs Python: Key Differences
- **Compiled vs Interpreted**: Go compiles to binary, Python runs on interpreter
- **Static vs Dynamic Typing**: Go requires explicit types
- **Memory Management**: Go has garbage collection but more control than Python
- **Concurrency**: Built-in goroutines vs Python's threading/asyncio

### Basic Structure
```go
package main  // Every Go program starts with package declaration

import "fmt"  // Import standard library packages

func main() {  // Entry point (like if __name__ == "__main__")
    fmt.Println("Hello, World!")
}
```

**Python Equivalent:**
```python
# No package declaration needed
print("Hello, World!")
```

## Module 2: Variables, Types & Functions

### Variable Declaration
```go
// Explicit typing (Go style)
var name string = "John"
var age int = 30

// Type inference (more Python-like)
name := "John"
age := 30

// Multiple declarations
var (
    name string = "John"
    age  int    = 30
)
```

**Python Equivalent:**
```python
name = "John"  # Dynamic typing
age = 30
```

### Basic Types
```go
// Numbers
var i int = 42
var f float64 = 3.14

// Strings
var s string = "hello"

// Booleans
var b bool = true

// Arrays (fixed size)
var arr [3]int = [3]int{1, 2, 3}

// Slices (dynamic, like Python lists)
var slice []int = []int{1, 2, 3}
slice = append(slice, 4)  // Add element
```

### Functions
```go
// Basic function
func greet(name string) string {
    return "Hello, " + name
}

// Multiple return values (Go's killer feature)
func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("division by zero")
    }
    return a / b, nil
}

// Usage
result, err := divide(10, 2)
if err != nil {
    fmt.Println("Error:", err)
    return
}
fmt.Println("Result:", result)
```

**Python Equivalent:**
```python
def greet(name: str) -> str:
    return f"Hello, {name}"

def divide(a: float, b: float) -> tuple[float, Exception | None]:
    if b == 0:
        return 0, Exception("division by zero")
    return a / b, None
```

## Module 3: Control Flow & Error Handling

### Conditionals
```go
// If statements
if age >= 18 {
    fmt.Println("Adult")
} else if age >= 13 {
    fmt.Println("Teenager")
} else {
    fmt.Println("Child")
}

// If with initialization
if err := doSomething(); err != nil {
    fmt.Println("Error:", err)
}
```

### Loops (Go only has `for`)
```go
// Traditional for loop
for i := 0; i < 5; i++ {
    fmt.Println(i)
}

// While-style loop
i := 0
for i < 5 {
    fmt.Println(i)
    i++
}

// Range over slice (like Python's enumerate)
items := []string{"a", "b", "c"}
for index, value := range items {
    fmt.Printf("%d: %s\n", index, value)
}

// Range over map
m := map[string]int{"a": 1, "b": 2}
for key, value := range m {
    fmt.Printf("%s: %d\n", key, value)
}
```

### Error Handling Pattern
```go
// Go's idiomatic error handling
func readFile(filename string) ([]byte, error) {
    data, err := os.ReadFile(filename)
    if err != nil {
        return nil, fmt.Errorf("failed to read %s: %w", filename, err)
    }
    return data, nil
}

// Usage
data, err := readFile("config.txt")
if err != nil {
    log.Fatal(err)  // Exit program
}
// Use data...
```

## Module 4: Data Structures & Pointers

### Structs (like Python classes, but data-focused)
```go
type Person struct {
    Name string
    Age  int
    Email string
}

// Constructor pattern
func NewPerson(name string, age int) *Person {
    return &Person{
        Name: name,
        Age:  age,
        Email: strings.ToLower(name) + "@example.com",
    }
}

// Methods
func (p *Person) Greet() string {
    return fmt.Sprintf("Hi, I'm %s", p.Name)
}

// Usage
person := NewPerson("Alice", 30)
fmt.Println(person.Greet())
```

### Pointers (Don't panic! Simpler than C++)
```go
// Create pointer
var p *int
x := 42
p = &x  // & gets address

fmt.Println(*p)  // * dereferences (gets value)

// Pointers in functions (for modification)
func increment(n *int) {
    *n++
}

x := 5
increment(&x)  // x is now 6
```

#### Pointers vs Vars
```go
// var — Value
// Use when working with the value itself.
x := 10
fmt.Println(x) // prints 10

// &var — Address of Value
// Use when you need a pointer to a variable (i.e., its memory address).
p := &x       // p is *int, holds address of x
fmt.Println(p)  // prints something like 0xc00001a0a8

// *var — Dereference Pointer
// Use when you have a pointer and want to access the value it points to.
fmt.Println(*p) // prints 10 (value at address p)
*p = 20         // changes x to 20
```


### Maps & Slices
```go
// Maps (like Python dicts)
m := make(map[string]int)
m["apple"] = 5
m["banana"] = 3

// Check if key exists
value, exists := m["apple"]
if exists {
    fmt.Println("Found:", value)
}

// Slices (like Python lists)
var slice []string
slice = append(slice, "hello")
slice = append(slice, "world")

// Slice operations
fmt.Println(slice[0])        // First element
fmt.Println(slice[1:])       // From index 1 to end
fmt.Println(len(slice))      // Length
```

## Module 5: Packages & Modules

### Creating Packages
```go
// File: utils/strings.go
package utils

import "strings"

// Exported function (starts with capital letter)
func Reverse(s string) string {
    runes := []rune(s)
    for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
        runes[i], runes[j] = runes[j], runes[i]
    }
    return string(runes)
}

// Private function (starts with lowercase)
func helper() {
    // Only accessible within package
}
```

### Using Packages
```go
// File: main.go
package main

import (
    "fmt"
    "mycli/utils"  // Your local package
)

func main() {
    result := utils.Reverse("hello")
    fmt.Println(result)  // "olleh"
}
```

## Module 6: CLI Development Essentials

### Command Line Arguments
```go
package main

import (
    "fmt"
    "os"
)

func main() {
    args := os.Args[1:]  // Skip program name
    
    if len(args) == 0 {
        fmt.Println("Usage: mycli <command>")
        os.Exit(1)
    }
    
    command := args[0]
    switch command {
    case "hello":
        fmt.Println("Hello, World!")
    case "version":
        fmt.Println("v1.0.0")
    default:
        fmt.Printf("Unknown command: %s\n", command)
        os.Exit(1)
    }
}
```

### Flag Package (Built-in argument parsing)
```go
package main

import (
    "flag"
    "fmt"
    "os"
)

func main() {
    var (
        name    = flag.String("name", "World", "Name to greet")
        count   = flag.Int("count", 1, "Number of greetings")
        verbose = flag.Bool("verbose", false, "Verbose output")
    )
    flag.Parse()
    
    if *verbose {
        fmt.Printf("Greeting %s %d times\n", *name, *count)
    }
    
    for i := 0; i < *count; i++ {
        fmt.Printf("Hello, %s!\n", *name)
    }
}
```

### File Operations
```go
package main

import (
    "bufio"
    "fmt"
    "os"
)

func main() {
    // Read file
    data, err := os.ReadFile("input.txt")
    if err != nil {
        fmt.Printf("Error reading file: %v\n", err)
        os.Exit(1)
    }
    fmt.Printf("File contents: %s\n", data)
    
    // Write file
    err = os.WriteFile("output.txt", []byte("Hello, Go!"), 0644)
    if err != nil {
        fmt.Printf("Error writing file: %v\n", err)
        os.Exit(1)
    }
    
    // Read line by line
    file, err := os.Open("input.txt")
    if err != nil {
        fmt.Printf("Error opening file: %v\n", err)
        return
    }
    defer file.Close()  // Ensures file is closed
    
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        fmt.Println(scanner.Text())
    }
}
```

## Module 7: Advanced CLI Patterns

### Subcommands Structure
```go
package main

import (
    "fmt"
    "os"
)

type Command struct {
    Name        string
    Description string
    Run         func(args []string) error
}

func main() {
    commands := map[string]Command{
        "init": {
            Name:        "init",
            Description: "Initialize a new project",
            Run:         initCommand,
        },
        "build": {
            Name:        "build",
            Description: "Build the project",
            Run:         buildCommand,
        },
    }
    
    if len(os.Args) < 2 {
        showHelp(commands)
        return
    }
    
    cmdName := os.Args[1]
    cmd, exists := commands[cmdName]
    if !exists {
        fmt.Printf("Unknown command: %s\n", cmdName)
        showHelp(commands)
        os.Exit(1)
    }
    
    if err := cmd.Run(os.Args[2:]); err != nil {
        fmt.Printf("Error: %v\n", err)
        os.Exit(1)
    }
}

func initCommand(args []string) error {
    fmt.Println("Initializing project...")
    return nil
}

func buildCommand(args []string) error {
    fmt.Println("Building project...")
    return nil
}

func showHelp(commands map[string]Command) {
    fmt.Println("Available commands:")
    for _, cmd := range commands {
        fmt.Printf("  %s\t%s\n", cmd.Name, cmd.Description)
    }
}
```

### Environment Variables & Configuration
```go
package main

import (
    "fmt"
    "os"
    "strconv"
)

type Config struct {
    APIKey  string
    Debug   bool
    Timeout int
}

func loadConfig() Config {
    config := Config{
        APIKey:  getEnv("API_KEY", ""),
        Debug:   getEnvBool("DEBUG", false),
        Timeout: getEnvInt("TIMEOUT", 30),
    }
    
    if config.APIKey == "" {
        fmt.Println("Warning: API_KEY not set")
    }
    
    return config
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

func getEnvBool(key string, defaultValue bool) bool {
    if value := os.Getenv(key); value != "" {
        if parsed, err := strconv.ParseBool(value); err == nil {
            return parsed
        }
    }
    return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
    if value := os.Getenv(key); value != "" {
        if parsed, err := strconv.Atoi(value); err == nil {
            return parsed
        }
    }
    return defaultValue
}
```

## Module 8: Testing & Best Practices

### Unit Testing
```go
// File: utils_test.go
package main

import "testing"

func TestReverse(t *testing.T) {
    tests := []struct {
        input    string
        expected string
    }{
        {"hello", "olleh"},
        {"", ""},
        {"a", "a"},
        {"abcde", "edcba"},
    }
    
    for _, test := range tests {
        result := Reverse(test.input)
        if result != test.expected {
            t.Errorf("Reverse(%q) = %q; want %q", 
                test.input, result, test.expected)
        }
    }
}
```

### Go Best Practices
1. **Error Handling**: Always check errors, don't ignore them
2. **Naming**: Use clear, descriptive names. Exported names start with capital letters
3. **Gofmt**: Always format your code with `go fmt`
4. **Package Organization**: Keep packages focused and cohesive
5. **Documentation**: Comment exported functions and types
6. **Context**: Use context.Context for cancellation and timeouts

### Code Style
```go
// Good: Clear function with error handling
func processFile(filename string) error {
    file, err := os.Open(filename)
    if err != nil {
        return fmt.Errorf("failed to open %s: %w", filename, err)
    }
    defer file.Close()
    
    // Process file...
    return nil
}

// Good: Clear struct with documentation
// User represents a system user with basic information.
type User struct {
    ID       int    `json:"id"`
    Username string `json:"username"`
    Email    string `json:"email"`
}
```

## Module 9: Building & Distribution

### Build Commands
```bash
# Build for current platform
go build -o mycli main.go

# Build for different platforms
GOOS=linux GOARCH=amd64 go build -o mycli-linux main.go
GOOS=windows GOARCH=amd64 go build -o mycli.exe main.go
GOOS=darwin GOARCH=amd64 go build -o mycli-mac main.go

# Build with version info
go build -ldflags "-X main.version=1.0.0" -o mycli main.go
```

### Project Structure
```
mycli/
├── cmd/
│   ├── root.go      # Root command
│   ├── init.go      # Init subcommand
│   └── build.go     # Build subcommand
├── pkg/
│   ├── config/      # Configuration handling
│   └── utils/       # Utility functions
├── internal/        # Private packages
├── go.mod          # Module definition
├── go.sum          # Dependency checksums
├── main.go         # Entry point
└── README.md
```

## Module 10: Practical Exercise - Text Processing CLI

Let's build a complete CLI tool that processes text files:

```go
package main

import (
    "bufio"
    "flag"
    "fmt"
    "os"
    "regexp"
    "strings"
)

type Options struct {
    InputFile  string
    OutputFile string
    Pattern    string
    Replace    string
    LineCount  bool
    WordCount  bool
}

func main() {
    opts := parseFlags()
    
    if err := processFile(opts); err != nil {
        fmt.Printf("Error: %v\n", err)
        os.Exit(1)
    }
}

func parseFlags() Options {
    var opts Options
    
    flag.StringVar(&opts.InputFile, "input", "", "Input file path")
    flag.StringVar(&opts.OutputFile, "output", "", "Output file path")
    flag.StringVar(&opts.Pattern, "pattern", "", "Pattern to search for")
    flag.StringVar(&opts.Replace, "replace", "", "Replacement text")
    flag.BoolVar(&opts.LineCount, "lines", false, "Count lines")
    flag.BoolVar(&opts.WordCount, "words", false, "Count words")
    
    flag.Parse()
    
    if opts.InputFile == "" {
        fmt.Println("Usage: textcli -input <file> [options]")
        flag.PrintDefaults()
        os.Exit(1)
    }
    
    return opts
}

func processFile(opts Options) error {
    file, err := os.Open(opts.InputFile)
    if err != nil {
        return fmt.Errorf("failed to open input file: %w", err)
    }
    defer file.Close()
    
    var output *os.File
    if opts.OutputFile != "" {
        output, err = os.Create(opts.OutputFile)
        if err != nil {
            return fmt.Errorf("failed to create output file: %w", err)
        }
        defer output.Close()
    } else {
        output = os.Stdout
    }
    
    scanner := bufio.NewScanner(file)
    lineCount := 0
    wordCount := 0
    
    for scanner.Scan() {
        line := scanner.Text()
        lineCount++
        wordCount += len(strings.Fields(line))
        
        // Apply pattern replacement if specified
        if opts.Pattern != "" && opts.Replace != "" {
            re, err := regexp.Compile(opts.Pattern)
            if err != nil {
                return fmt.Errorf("invalid pattern: %w", err)
            }
            line = re.ReplaceAllString(line, opts.Replace)
        }
        
        fmt.Fprintln(output, line)
    }
    
    if err := scanner.Err(); err != nil {
        return fmt.Errorf("error reading file: %w", err)
    }
    
    // Print statistics if requested
    if opts.LineCount {
        fmt.Printf("Lines: %d\n", lineCount)
    }
    if opts.WordCount {
        fmt.Printf("Words: %d\n", wordCount)
    }
    
    return nil
}
```

## Summary & Next Steps

You now have the foundation to build CLI tools in Go! Key takeaways:

1. **Static typing** helps catch errors early
2. **Error handling** is explicit and thorough
3. **Structs and methods** provide organization
4. **Packages** enable code reuse
5. **Built-in tooling** (`go fmt`, `go test`, `go build`) streamlines development

### Practice Projects:
1. **File organizer**: Sort files into directories by extension
2. **Log analyzer**: Parse and analyze log files
3. **API client**: Make HTTP requests and format responses
4. **Task manager**: Simple TODO CLI with persistence

### Advanced Topics to Explore:
- Goroutines and channels (concurrency)
- HTTP servers and clients
- Database integration
- Third-party CLI frameworks (Cobra, urfave/cli)
- Configuration management (Viper)

The Go community values simplicity, clarity, and reliability. Focus on writing clear, well-tested code that handles errors gracefully, and you'll be building professional-quality CLI tools in no time!
