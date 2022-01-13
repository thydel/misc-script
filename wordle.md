# How to cheat at wordle

Play [wordle][] using [sed(1)][], [grep(1)][], [tr(1)][] and [make(1)][]

[wordle]:
    https://www.powerlanguage.co.uk/wordle/
    "powerlanguage.co.uk"

[sed(1)]:
    https://man7.org/linux/man-pages/man1/sed.1.html
    "man7.org"

[grep(1)]:
    https://man7.org/linux/man-pages/man1/grep.1.html
    "man7.org"

[tr(1)]:
    https://man7.org/linux/man-pages/man1/tr.1.html
    "man7.org"

[make(1)]:
    https://man7.org/linux/man-pages/man1/make.1.html
    "man7.org"

# With a little help from my friends

See [wordle.mk](wordle.mk)

# 2022-01-13

```console
thy@tde-ws:~/usr/misc-script$ wordle.mk
mkdir -p tmp/wordle
< /usr/share/dict/american-english sed -e "s/'s$//" | grep '^.....$' | tr '[:upper:]' '[:lower:]' | sort -u > tmp/wordle/five-letters
< tmp/wordle/five-letters grep -Ev '(.).*\1' > tmp/wordle/five-unique-letters
thy@tde-ws:~/usr/misc-script$ wordle.mk first
< tmp/wordle/five-unique-letters shuf -n1
amber
thy@tde-ws:~/usr/misc-script$ wordle.mk look g=a.be. e=rm
< tmp/wordle/five-letters grep a.be. | grep -v [rm]
abbey
albee
```

[Local Variables:]::
[indent-tabs-mode: nil]::
[End:]::
