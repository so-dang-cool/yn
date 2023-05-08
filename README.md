# yn 1.0

Dirt-simple yes/no prompts for your shell scripts.

## Example

```bash
if Yn 'Do you want to fight?'; then
    echo 'Have at ye, scoundrel! 🤺'
else
    echo 'Tea then? 🍵'
fi
```

## Usage

```text
$ Yn --help
USAGE:
    Yn PROMPT
    yN PROMPT

FLAGS:
    -h, --help    Display help message
    -V, --version Display version

Presents a user with a yes/no prompt, and reads one line of standard
input. To avoid ambiguity with whitespaces, the prompt must be exactly
one argument.

If the user response begins with 'y' or 'Y' the program completes with a
successful 0 exit code. If it begins with 'n' or 'N' the program
completes with a failure 1 exit code.

When the user gives any other input:
* Yn defaults to yes
* yN defaults to no
```

## Credits

BSD-3-Clause License

A side quest of [J.R. Hill](https://so.dang.cool)
